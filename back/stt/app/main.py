import boto3
import io
import logging
import os
import requests
import uuid
import json

from botocore.exceptions import ClientError
from sanic import Sanic, response
from sanic.request import Request
from sanic_cors import CORS, cross_origin

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

url_operations_api = "https://operation.api.cloud.yandex.net/operations/"
url_transcribe_api = "https://transcribe.api.cloud.yandex.net/speech/stt/v2/longRunningRecognize"
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

    print(rate)
    print(lang)

    if (key.lower().endswith(".mp3")):
        file_type = "mp3"
    elif (key.lower().endswith(".ogg")):
        file_type = "ogg"
    elif (key.lower().endswith(".wav")):
        file_type = "wav"
    else:
        return response.json({"error": "Unsupported file type"}, status=400)

    url = create_presigned_url('get_object', key)
    result = create_recognition_task(url, file_type, lang, rate)

    return response.json({"message": "Operation created successfully", "operation": result['id']})
    
@app.get("/operation")
async def operation_status(request):
    operation_id = request.args.get("operationId")
    if not operation_id:
        return response.json({"error": "Missing operation parameter"}, status=400)

    is_done = await check_operation_status(operation_id)

    if not (is_done['done']):
        logging.info("Operation in progress: {}".format(operation_id))
        return response.json({"message": "Operation in progress", "operation": operation_id, "done": "false"})
    
    complete_data = {
        "message": "Operation is complete",
        "operation": operation_id,
        "done": "true",
        "result": is_done["response"]
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
        
    key = f"uploads/{uuid.uuid4()}{file_extension}"  # You can adjust the path and file extension

    presigned_url = create_presigned_url('put_object', key)

    return response.json({'url': presigned_url, 'file_name': file_name, 'key': key})

# Check operation status
async def check_operation_status(operation_id):
    try:
        result = requests.get(url_operations_api+operation_id, headers=request_header)
        result.raise_for_status()
    except requests.exceptions.HTTPError as e:
        logging.error("Operation status check failed: {}".format(e))
    except requests.exceptions.RequestException as e:
        logging.error("Operation status check failed: {}".format(e))
    
    print(result.json())
    return result.json()

# Create presigned URL
def create_presigned_url(action, object, expiration = 3600):
    if action == "get_object":
        try:
            response = s3.generate_presigned_url(action,
                Params={
                    'Bucket': config['s3_bucket'],
                    'Key': object
                },
                ExpiresIn = expiration
            )
        except ClientError as e:
            logging.error("Generate presigned URL failed: {}".format(e))
            return None
        return response
    elif action == "put_object":
        try:
            response = s3.generate_presigned_url(action,
                Params={
                    'Bucket': config['s3_bucket'],
                    'Key': object,
                    'ContentType': 'binary/octet-stream'
                },
                ExpiresIn = expiration
            )
        except ClientError as e:
            logging.error("Generate presigned URL failed: {}".format(e))
            return None
        return response
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

# Function - Create recognition task
def create_recognition_task(url, file_type, lang, rate = 48000):
    request_body = {}
    if (file_type == "mp3"):
        request_body = {
            "config": {
                "specification": {
                    "audioEncoding": "MP3",
                    "languageCode": lang
                }
            },
            "audio": {
                "uri": url
            }
        }
    elif (file_type == "wav"):
        request_body = {
            "config": {
                "specification": {
                    "audioEncoding": "LINEAR16_PCM",
                    "sampleRateHertz": rate,
                    "languageCode": lang
                }
            },
            "audio": {
                "uri": url
            }
        }
    elif (file_type == "ogg"):
        request_body = {
            "config": {
                "specification": {
                    "audioEncoding": "OGG_OPUS",
                    "languageCode": lang
                }
            },
            "audio": {
                "uri": url
            }
        }
    
    try:
        print("request_header")
        print(request_header)
        print("request_body")
        print(request_body)
        response = requests.post(url_transcribe_api, headers=request_header, json=request_body)
        response.raise_for_status()
    except requests.exceptions.HTTPError as e:
        logging.error("Transcribe request failed: {}".format(e))
    except requests.exceptions.RequestException as e:
        logging.error("Transcribe request failed: {}".format(e))
    else:
        request_data = response.json()
    
        if(request_data['id']):
            logging.info("Operation {}".format(request_data['id']))
            logging.info("Operation has been created for {}".format(url))
            return request_data
        else: 
            logging.error("Operation ID is missing in the response")
            return {"Status": "None"}

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=int(os.environ['PORT']), motd=False, access_log=False)