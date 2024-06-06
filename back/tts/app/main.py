import boto3
import grpc
import io
import json
import logging
import os
import pydub
import uuid

from datetime import datetime

from botocore.exceptions import ClientError

import yandex.cloud.ai.tts.v3.tts_pb2 as tts_pb2
import yandex.cloud.ai.tts.v3.tts_service_pb2_grpc as tts_service_pb2_grpc

from sanic import Sanic
from sanic.response import text
from sanic_cors import CORS, cross_origin

# Global - Logging
logging.getLogger().setLevel(logging.INFO)

# Global - Variables
config = {
    'api_key_secret'  : os.environ['API_SECRET'],
    'request_api'     : "tts.api.cloud.yandex.net:443",
    's3_bucket'       : os.environ['S3_BUCKET'],
    's3_key'          : os.environ['S3_KEY'],
    's3_secret'       : os.environ['S3_SECRET'],
} 

# State - Setting up S3 client
s3 = boto3.client('s3',
    endpoint_url            = 'https://storage.yandexcloud.net',
    aws_access_key_id       = config['s3_key'],
    aws_secret_access_key   = config['s3_secret'] 
)

# Web app
app = Sanic(__name__)
CORS(app)

@app.after_server_start
async def after_server_start(app, loop):
    print(f"App listening at port {os.environ['PORT']}")

@app.post("/tts")
async def start(request):
    request_json = request.json
    print(f"Received JSON: {request_json}")

    text_value        = request_json.get("text", "Empty")
    voice_value       = request_json.get("voice", "alexander")
    role_value        = request_json.get("role", "good")
    speed_value_raw   = request_json.get("speed")
    speed_value       = check_speed(speed_value_raw)
    unsafe_mode_value = request_json.get("unsafe", False)

    audio = synthesize(text_value, voice_value, role_value, speed_value, unsafe_mode_value)

    filename = f"audio-{uuid.uuid4()}.wav"

    with open(f"/app/{filename}", 'wb') as fp:
        audio.export(fp, format='wav')
    
    status = upload_file_to_s3(f"/app/{filename}",f"audio/{filename}")
    print("status {}".format(status))

    if (status):
        print(f"audio/{filename}")
        return text(f"https://{config['s3_bucket']}.website.yandexcloud.net/audio/{filename}", status=200)
    else:
        print("error")
        return text("Error processing audio", status=500) 

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=int(os.environ['PORT']), motd=False, access_log=False)

# Function - Check speed
def check_speed(input_value):
    if isinstance(input_value, (int, float)):
        return float(input_value)
    elif isinstance(input_value, str):
        numeric_part = ''.join(filter(lambda x: x.isdigit() or x == '.', input_value))
        try:
            return float(numeric_part)
        except ValueError:
            print("Incorrect value")
            return 1.1
    else:
        print("Unsupported type.")
        return 1.1

# Function - Synthesize
def synthesize(text_value, voice_value, role_value, speed_value, unsafe_mode_value) -> pydub.AudioSegment: 

    if role_value == "none":
        request = tts_pb2.UtteranceSynthesisRequest(
            text=text_value,
            output_audio_spec=tts_pb2.AudioFormatOptions(
                container_audio=tts_pb2.ContainerAudio(
                    container_audio_type=tts_pb2.ContainerAudio.WAV
                )
            ),
            hints=[
            tts_pb2.Hints(voice = voice_value),
            tts_pb2.Hints(speed = speed_value),
            ],
            loudness_normalization_type=tts_pb2.UtteranceSynthesisRequest.LUFS,
            unsafe_mode=unsafe_mode_value
        )
    else:
        request = tts_pb2.UtteranceSynthesisRequest(
            text=text_value,
            output_audio_spec=tts_pb2.AudioFormatOptions(
                container_audio=tts_pb2.ContainerAudio(
                    container_audio_type=tts_pb2.ContainerAudio.WAV
                )
            ),
            hints=[
            tts_pb2.Hints(voice = voice_value),
            tts_pb2.Hints(role  = role_value),
            tts_pb2.Hints(speed = speed_value),
            ],
            loudness_normalization_type=tts_pb2.UtteranceSynthesisRequest.LUFS,
            unsafe_mode=unsafe_mode_value
        )

    cred = grpc.ssl_channel_credentials()
    channel = grpc.secure_channel(config['request_api'], cred)
    stub = tts_service_pb2_grpc.SynthesizerStub(channel)

    it = stub.UtteranceSynthesis(
        request, 
        metadata=(
            ('authorization', 'Api-Key {}'.format(config['api_key_secret'])),
        )
    )

    try:
        audio = io.BytesIO()
        for response in it:
            audio.write(response.audio_chunk.data)
        audio.seek(0)
        return pydub.AudioSegment.from_wav(audio)
    except grpc._channel._Rendezvous as err:
        print(f'Error code {err._state.code}, message: {err._state.details}')
        raise err
    
# Function - Upload to S3
def upload_file_to_s3(file_path, object_name):
    """
    Upload a file to an S3 bucket.

    :param bucket_name: Bucket to upload to
    :param file_path: File to upload
    :param object_name: S3 object name. If not specified, file_path is used
    """
    # Upload the file
    try:
        response = s3.upload_file(file_path, config['s3_bucket'], object_name)
        print(response)
    except Exception as e:
        print(f"Error uploading file: {e}")
        return False
    return True