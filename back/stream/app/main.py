import asyncio
import grpc
import json
import logging
import os
from sanic import Sanic
from sanic.response import json as sanic_json
from sanic_cors import CORS

import yandex.cloud.ai.stt.v3.stt_pb2 as stt_pb2
import yandex.cloud.ai.stt.v3.stt_service_pb2_grpc as stt_service_pb2_grpc

# Configuration - Logging
logging.getLogger().setLevel(logging.INFO)

# Variables
config = {
    'api_key_secret': os.environ['API_SECRET'],
}

STT_GRPC_ENDPOINT = "stt.api.cloud.yandex.net:443"

# Application
app = Sanic(__name__)
CORS(app)

@app.after_server_start
async def after_server_start(app, loop):
    print(f"Stream service listening at port {os.environ['PORT']}")

@app.websocket('/stream')
async def stream_recognize(request, ws):
    logging.info("WebSocket connection established")
    
    # Get language from query parameter (default: ru-RU)
    lang = request.args.get('lang', 'ru-RU')
    logging.info(f"Language: {lang}")
    
    try:
        # Establish gRPC connection to Yandex SpeechKit
        cred = grpc.ssl_channel_credentials()
        channel = grpc.secure_channel(STT_GRPC_ENDPOINT, cred)
        stub = stt_service_pb2_grpc.RecognizerStub(channel)
        
        # Queue for audio chunks
        audio_queue = asyncio.Queue()
        
        # Generator for sending audio chunks to API
        async def audio_generator():
            # Send initial config
            recognize_options = stt_pb2.StreamingOptions(
                recognition_model=stt_pb2.RecognitionModelOptions(
                    audio_format=stt_pb2.AudioFormatOptions(
                        raw_audio=stt_pb2.RawAudio(
                            audio_encoding=stt_pb2.RawAudio.LINEAR16_PCM,
                            sample_rate_hertz=16000,
                            audio_channel_count=1
                        )
                    ),
                    text_normalization=stt_pb2.TextNormalizationOptions(
                        text_normalization=stt_pb2.TextNormalizationOptions.TEXT_NORMALIZATION_ENABLED,
                        profanity_filter=True,
                        literature_text=False
                    ),
                    language_restriction=stt_pb2.LanguageRestrictionOptions(
                        restriction_type=stt_pb2.LanguageRestrictionOptions.WHITELIST,
                        language_code=[lang]
                    ),
                    audio_processing_type=stt_pb2.RecognitionModelOptions.REAL_TIME
                )
            )
            yield stt_pb2.StreamingRequest(session_options=recognize_options)
            
            # Receive audio chunks from queue and forward to API
            while True:
                data = await audio_queue.get()
                if data is None:  # End signal
                    break
                yield stt_pb2.StreamingRequest(chunk=stt_pb2.AudioChunk(data=data))
        
        # Task to receive audio from WebSocket
        async def receive_audio():
            try:
                while True:
                    data = await ws.recv()
                    if isinstance(data, str):
                        if data == 'END':
                            logging.info("Received END signal")
                            await audio_queue.put(None)
                            break
                    else:
                        # Binary audio data
                        await audio_queue.put(data)
            except Exception as e:
                logging.error(f"Error receiving audio: {e}")
                await audio_queue.put(None)
        
        # Task to send recognition results
        async def send_results():
            try:
                # Start streaming recognition
                responses = stub.RecognizeStreaming(
                    audio_generator(),
                    metadata=(('authorization', f'Api-Key {config["api_key_secret"]}'),)
                )
                
                # Send recognition results back to browser
                for response in responses:
                    event_type = response.WhichOneof('Event')
                    result = {
                        'type': event_type,
                        'alternatives': []
                    }
                    
                    if event_type == 'partial' and len(response.partial.alternatives) > 0:
                        result['alternatives'] = [a.text for a in response.partial.alternatives]
                    elif event_type == 'final':
                        result['alternatives'] = [a.text for a in response.final.alternatives]
                    elif event_type == 'final_refinement':
                        result['alternatives'] = [a.text for a in response.final_refinement.normalized_text.alternatives]
                    elif event_type == 'eou_update':
                        result['eou_update'] = True
                    elif event_type == 'status_code':
                        result['status_code'] = response.status_code.code_type
                    
                    await ws.send(json.dumps(result))
                    
            except grpc.RpcError as e:
                logging.error(f"gRPC error: code={e.code()}, details={e.details()}")
                await ws.send(json.dumps({
                    'type': 'error',
                    'message': f'Recognition error: {e.details()}'
                }))
            except Exception as e:
                logging.error(f"Error in send_results: {e}")
                await ws.send(json.dumps({
                    'type': 'error',
                    'message': str(e)
                }))
        
        # Run both tasks concurrently
        await asyncio.gather(
            receive_audio(),
            send_results()
        )
        
    except Exception as e:
        logging.error(f"WebSocket error: {e}")
        try:
            await ws.send(json.dumps({
                'type': 'error',
                'message': str(e)
            }))
        except:
            pass
    finally:
        logging.info("WebSocket connection closed")

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=int(os.environ['PORT']), motd=False, access_log=False)
