import boto3
import grpc
import io
import logging
import os
import requests
import uuid
import json

from botocore.exceptions import ClientError
from google.protobuf.json_format import MessageToDict

from sanic import Sanic, response
from sanic.request import Request
from sanic_cors import CORS, cross_origin

import yandex.cloud.ai.stt.v3.stt_pb2 as stt_pb2
import yandex.cloud.ai.stt.v3.stt_service_pb2 as stt_service_pb2
import yandex.cloud.ai.stt.v3.stt_service_pb2_grpc as stt_service_pb2_grpc

# Configuration - Logging
logging.getLogger().setLevel(logging.INFO)

# Variables
config = {
    's3_bucket'       : os.environ['S3_BUCKET'],
    's3_key'          : os.environ['S3_KEY'],
    's3_secret'       : os.environ['S3_SECRET'],
    'api_key_secret'  : os.environ['API_SECRET']
}

suffixes = (".mp3", ".wav", ".ogg")

STT_GRPC_ENDPOINT = "stt.api.cloud.yandex.net:443"
url_operations_api = "https://operation.api.cloud.yandex.net/operations/"
request_header = {'Authorization': 'Api-Key {}'.format(config['api_key_secret'])}

# State - Setting up S3 client
s3 = boto3.client('s3',
    endpoint_url            = 'https://storage.yandexcloud.net',
    aws_access_key_id       = config['s3_key'],
    aws_secret_access_key   = config['s3_secret'] 
)

# Application
app = Sanic(__name__)
app.config.REQUEST_MAX_SIZE = 1024 * 1024 * 1024
CORS(
    app,
    resources={
        r"/*": {
            "origins": "*",
            "allow_headers": ["*"],
            "expose_headers": ["ETag"],
            "methods": ["GET", "POST", "PUT", "OPTIONS"],
        }
    },
    automatic_options=True
)

@app.after_server_start
async def after_server_start(app, loop):
    print(f"App listening at port {os.environ['PORT']}")

@app.post("/stt")
async def upload_file(request: Request):

    data = request.json
    key = data.get('key', None)

    if not key:
        return response.json({'error': 'No key provided'}, status=400)
    
    lang = data.get('lang', 'auto')
    rate = data.get('rate', 48000)

    print(f"rate: {rate}, lang: {lang}")

    if key.lower().endswith(".mp3"):
        container_type = stt_pb2.ContainerAudio.MP3
    elif key.lower().endswith(".ogg"):
        container_type = stt_pb2.ContainerAudio.OGG_OPUS
    elif key.lower().endswith(".wav"):
        container_type = stt_pb2.ContainerAudio.WAV
    else:
        return response.json({"error": "Unsupported file type"}, status=400)

    url = create_presigned_url('get_object', key)
    operation_id = create_recognition_task(url, container_type, lang, rate)

    if not operation_id:
        return response.json({"error": "Failed to create recognition task"}, status=500)

    return response.json({"message": "Operation created successfully", "operation": operation_id})
    
@app.get("/operation")
async def operation_status(request):
    operation_id = request.args.get("operationId")
    if not operation_id:
        return response.json({"error": "Missing operation parameter"}, status=400)

    is_done = await check_operation_status(operation_id)

    if not is_done.get('done', False):
        logging.info("Operation in progress: {}".format(operation_id))
        return response.json({"message": "Operation in progress", "operation": operation_id, "done": "false"})
    
    # Operation is done — fetch results via v3 GetRecognition gRPC
    results = get_recognition_results(operation_id)

    complete_data = {
        "message": "Operation is complete",
        "operation": operation_id,
        "done": "true",
        "result": {
            "chunks": results
        }
    }

    upload_results(complete_data, operation_id)

    return response.json(complete_data)

@app.get("/presign")
async def get(request):
    file_name = request.args.get("fileName")
    _, file_extension = os.path.splitext(file_name)

    if not file_name:
        return response.json({"error": "Missing operation parameter"}, status=400)

    if file_extension.lower() not in ['.wav', '.mp3', '.ogg']:
        return response.json({"error": "Unsupported file type"}, status=400)
        
    key = f"uploads/{uuid.uuid4()}{file_extension}"

    presigned_url = create_presigned_url('put_object', key)

    return response.json({'url': presigned_url, 'file_name': file_name, 'key': key})

# Check operation status via REST (reuse existing operations API)
async def check_operation_status(operation_id):
    try:
        result = requests.get(url_operations_api + operation_id, headers=request_header)
        result.raise_for_status()
    except requests.exceptions.HTTPError as e:
        logging.error("Operation status check failed: {}".format(e))
        return {}
    except requests.exceptions.RequestException as e:
        logging.error("Operation status check failed: {}".format(e))
        return {}
    
    print(result.json())
    return result.json()

# Create presigned URL
def create_presigned_url(action, object, expiration=3600):
    if action == "get_object":
        try:
            resp = s3.generate_presigned_url(action,
                Params={
                    'Bucket': config['s3_bucket'],
                    'Key': object
                },
                ExpiresIn=expiration
            )
        except ClientError as e:
            logging.error("Generate presigned URL failed: {}".format(e))
            return None
        return resp
    elif action == "put_object":
        try:
            resp = s3.generate_presigned_url(action,
                Params={
                    'Bucket': config['s3_bucket'],
                    'Key': object,
                    'ContentType': 'binary/octet-stream'
                },
                ExpiresIn=expiration
            )
        except ClientError as e:
            logging.error("Generate presigned URL failed: {}".format(e))
            return None
        return resp
    else:
        logging.error("Generate presigned URL failed: No action received")
        return None

# Function - Save to bucket
def upload_results(data, key):
    try:
        s3.put_object(Bucket=config['s3_bucket'], Key=f"results/{key}.json", Body=json.dumps(data))
        logging.info("Results were saved: {}".format(key))
        return True
    except ClientError as e:
        logging.error("Object upload failed: {}".format(e))
        return None

# Helper - create gRPC channel and metadata
def _create_grpc_channel():
    cred = grpc.ssl_channel_credentials()
    channel = grpc.secure_channel(STT_GRPC_ENDPOINT, cred)
    metadata = [('authorization', 'Api-Key {}'.format(config['api_key_secret']))]
    return channel, metadata

# Function - Create recognition task via v3 gRPC AsyncRecognizer.RecognizeFile
def create_recognition_task(presigned_url, container_type, lang, rate=48000):
    channel, metadata = _create_grpc_channel()
    stub = stt_service_pb2_grpc.AsyncRecognizerStub(channel)

    # Build language restriction
    if lang and lang != 'auto':
        language_restriction = stt_pb2.LanguageRestrictionOptions(
            restriction_type=stt_pb2.LanguageRestrictionOptions.WHITELIST,
            language_code=[lang]
        )
    else:
        language_restriction = None

    # Build audio format — use container audio for mp3/ogg/wav
    audio_format = stt_pb2.AudioFormatOptions(
        container_audio=stt_pb2.ContainerAudio(
            container_audio_type=container_type
        )
    )

    # Build recognition model options
    recognition_model = stt_pb2.RecognitionModelOptions(
        model='general',
        audio_format=audio_format,
        text_normalization=stt_pb2.TextNormalizationOptions(
            text_normalization=stt_pb2.TextNormalizationOptions.TEXT_NORMALIZATION_ENABLED,
            literature_text=True
        ),
        audio_processing_type=stt_pb2.RecognitionModelOptions.FULL_DATA,
    )

    if language_restriction:
        recognition_model.language_restriction.CopyFrom(language_restriction)

    recognize_request = stt_pb2.RecognizeFileRequest(
        uri=presigned_url,
        recognition_model=recognition_model,
    )

    try:
        logging.info("Sending RecognizeFile request via gRPC v3")
        operation = stub.RecognizeFile(recognize_request, metadata=metadata)
        logging.info("Operation created: {}".format(operation.id))
        return operation.id
    except grpc.RpcError as e:
        logging.error(f"gRPC RecognizeFile failed: code={e.code()}, details={e.details()}")
        return None

# Function - Get recognition results via v3 gRPC AsyncRecognizer.GetRecognition
def get_recognition_results(operation_id):
    channel, metadata = _create_grpc_channel()
    stub = stt_service_pb2_grpc.AsyncRecognizerStub(channel)

    request = stt_service_pb2.GetRecognitionRequest(operation_id=operation_id)

    results = []
    try:
        logging.info("Fetching recognition results for operation: {}".format(operation_id))
        for response_msg in stub.GetRecognition(request, metadata=metadata):
            # Convert each StreamingResponse to a dict
            chunk = MessageToDict(response_msg, preserving_proto_field_name=True)

            # Extract channel tag and alternatives from final_refinement or final
            entry = {}
            channel_tag = chunk.get('channel_tag', '')

            if 'final_refinement' in chunk:
                refinement = chunk['final_refinement']
                if 'normalized_text' in refinement:
                    alternatives = refinement['normalized_text'].get('alternatives', [])
                    entry = {
                        'channelTag': channel_tag,
                        'alternatives': [{'text': alt.get('text', '')} for alt in alternatives]
                    }

            if entry:
                results.append(entry)

    except grpc.RpcError as e:
        logging.error(f"gRPC GetRecognition failed: code={e.code()}, details={e.details()}")

    return results

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=int(os.environ['PORT']), motd=False, access_log=False)
