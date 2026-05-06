# Using Terraform in Yandex Cloud

<img
  src="../images/diagram.png"
  alt="SpeechKit Web UI"
  title="SpeechKit Web UI"
  style="display: inline-block; margin: 0 auto; max-width: 400px">

This module creates the following resources:

1. An Object Storage bucket
2. Objects in the bucket for hosting a static website
3. Two Serverless Containers
4. An API Gateway
5. Service accounts for running the containers
6. A static access key and an API key
7. A secret in [Lockbox](https://cloud.yandex.com/services/lockbox) for secure key storage

The Terraform provider uses authentication through a `key.json` file. To deploy the solution, the `admin` role in the folder is required, since service accounts are created and IAM roles are assigned.

If necessary, you can switch authentication to use an [IAM token](https://yandex.cloud/en/docs/iam/concepts/authorization/iam-token).

## Installation

To run this module, create a variables file named `private.auto.tfvars` and save your cloud and folder IDs in it:

```hcl
cloud_id  = "b1g3xxxxxx"
folder_id = "b1g7xxxxxx"
```

Also, [create](https://yandex.cloud/en/docs/iam/operations/authorized-key/create) an authorized key `key.json` and save it into the `deploy/terraform` directory alongside the other `.tf` files.

After that, you can deploy the Terraform module:

```bash
cd deploy/terraform
terraform init
terraform apply
```

## Usage

After deployment, the following outputs will be displayed:

```hcl
api-gw = "https://d5dclvvxxx.apigw.yandexcloud.net"
bucket = "https://speechbench-xxx.website.yandexcloud.net"
```

Open the `bucket` URL in your web browser.

The web application contains two tabs corresponding to TTS and STT functionality.

The first request may take longer because the container is started for the first time.

Speech synthesis results are stored in the bucket under the `audio` directory. The latest successfully generated audio file is also available for playback directly from the website.

Audio files uploaded for recognition are stored in the `upload` directory. Recognition results are displayed in the web interface both as:
- the raw JSON response;
- and as the summarized `text` field extracted from the JSON response for each audio channel.

## Removal

Before destroying the infrastructure, make sure to empty the created bucket (otherwise the destroy process will fail):

```bash
cd deploy/terraform
terraform destroy
```

# Running Locally with Docker Compose

> Streaming recognition mode only works when deployed via Docker Compose because WebSocket support is required.

## Prerequisites

- Docker and Docker Compose
- A service account in Yandex Cloud with the following roles:
  - `ai.speechkit-stt.user`
  - `ai.speechkit-tts.user`
  - `ai.languageModels.user` (for summarization)
- An S3 bucket
- A service account with the `storage.editor` role for the bucket and a static access key

## Installation

### Setup

1. **Copy the `.env` file**
   ```bash
   cp .env.example .env
   ```

2. **Fill in the `.env` credentials:**
   ```bash
   # Yandex Cloud API Key
   API_SECRET=AQVNxxxxxxxxxxxxxxxxxxxxxxxxx

   # S3 bucket and access keys
   S3_BUCKET=my-speechkit-bucket
   S3_KEY=YCAJExxxxxxxxxxxxxxxxx
   S3_SECRET=YCOxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

   # Optional: Summarization model
   MODEL_URI=gpt://b1gxxxxxxxxxxxxxxxxxx/yandexgpt-5.1
   ```

3. **Start the application:**
   ```bash
   cd deploy/local
   docker-compose up --build
   ```

   Or run it in detached mode:
   ```bash
   cd deploy/local
   docker-compose up -d --build
   ```

## Working with the Application

Open your browser and navigate to:

```text
http://localhost:8080
```

## Stopping the Application

```bash
docker-compose down
```