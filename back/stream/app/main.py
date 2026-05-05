import asyncio
import grpc.aio  # Changed from grpc
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
    'model_uri': os.environ.get('MODEL_URI', ''),
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
    summary_instruction = request.args.get('summaryInstruction', '')
    logging.info(f"Language: {lang}, summaryInstruction: {bool(summary_instruction)}")

    channel = None

    try:
        # Establish async gRPC connection to Yandex SpeechKit
        cred = grpc.ssl_channel_credentials()
        channel = grpc.aio.secure_channel(STT_GRPC_ENDPOINT, cred)
        stub = stt_service_pb2_grpc.RecognizerStub(channel)

        # Async generator for sending audio chunks to API
        async def audio_generator():
            # Send initial config
            recognition_model = stt_pb2.RecognitionModelOptions(
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

            session_kwargs = {
                'recognition_model': recognition_model,
            }

            # Add summarization if instruction and model_uri are provided
            if summary_instruction and config['model_uri']:
                session_kwargs['summarization_options'] = stt_pb2.SummarizationOptions(
                    summarization_model_uri=config['model_uri'],
                    instruction=summary_instruction,
                )
                logging.info("Summarization enabled for this session")

            recognize_options = stt_pb2.StreamingOptions(**session_kwargs)
            yield stt_pb2.StreamingRequest(session_options=recognize_options)

            # Receive audio chunks from WebSocket and forward to API
            try:
                async for data in ws:
                    if isinstance(data, str):
                        if data == 'END':
                            logging.info("Received END signal")
                            break
                    else:
                        # Binary audio data
                        yield stt_pb2.StreamingRequest(chunk=stt_pb2.AudioChunk(data=data))
            except Exception as e:
                logging.error(f"Error in audio_generator: {e}")

        # Start async streaming recognition
        call = stub.RecognizeStreaming(
            audio_generator(),
            metadata=(('authorization', f'Api-Key {config["api_key_secret"]}'),)
        )

        # Process recognition results
        async for response in call:
            try:
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
                elif event_type == 'summarization':
                    summarization = response.summarization
                    result['summarization'] = {
                        'results': [],
                    }
                    if hasattr(summarization, 'results'):
                        for item in summarization.results:
                            result['summarization']['results'].append({
                                'response': item.response if hasattr(item, 'response') else '',
                            })
                    if hasattr(summarization, 'content_usage'):
                        cu = summarization.content_usage
                        result['summarization']['content_usage'] = {
                            'input_text_tokens': cu.input_text_tokens if hasattr(cu, 'input_text_tokens') else 0,
                            'completion_tokens': cu.completion_tokens if hasattr(cu, 'completion_tokens') else 0,
                            'total_tokens': cu.total_tokens if hasattr(cu, 'total_tokens') else 0,
                        }
                    logging.info(f"Summarization result received")

                await ws.send(json.dumps(result))

            except Exception as e:
                logging.error(f"Error processing response: {e}")

    except grpc.aio.AioRpcError as e:
        logging.error(f"gRPC error: code={e.code()}, details={e.details()}")
        try:
            await ws.send(json.dumps({
                'type': 'error',
                'message': f'Recognition error: {e.details()}'
            }))
        except:
            pass
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
        if channel:
            await channel.close()
        logging.info("WebSocket connection closed")

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=int(os.environ['PORT']), motd=False, access_log=False)
