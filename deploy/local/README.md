# Local Deployment with Docker Compose

This directory contains configuration for running the SpeechKit Web UI locally using Docker Compose.

## Prerequisites

- Docker and Docker Compose installed
- Yandex Cloud account with SpeechKit API access
- API key with the following roles:
  - `ai.speechkit-stt.user`
  - `ai.speechkit-tts.user`
  - `ai.languageModels.user` (optional, for summarization)
- S3-compatible storage (Yandex Object Storage) with:
  - Bucket created
  - Static access key (access key ID and secret key)

## Setup

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` file with your credentials:**
   ```bash
   # Yandex Cloud API Key
   API_SECRET=AQVNxxxxxxxxxxxxxxxxxxxxxxxxx

   # S3 Configuration
   S3_BUCKET=my-speechkit-bucket
   S3_KEY=YCAJExxxxxxxxxxxxxxxxx
   S3_SECRET=YCOxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

   # Optional: YandexGPT Model URI for summarization
   MODEL_URI=gpt://b1gxxxxxxxxxxxxxxxxxx/yandexgpt-5.1
   ```

3. **Build and start the services:**
   ```bash
   docker-compose up --build
   ```

   Or run in detached mode:
   ```bash
   docker-compose up -d --build
   ```

## Access the Application

Once the containers are running, open your browser and navigate to:

```
http://localhost:8080
```

## Architecture

The local deployment consists of three services:

1. **TTS Service** (port 8081)
   - Handles text-to-speech synthesis requests
   - Communicates with Yandex SpeechKit TTS API
   - Stores generated audio files in S3

2. **STT Service** (port 8082)
   - Handles speech-to-text recognition requests
   - Communicates with Yandex SpeechKit STT API
   - Provides speaker and conversation analysis
   - Optional: Uses YandexGPT for summarization

3. **Nginx** (port 8080)
   - Serves the static frontend
   - Proxies API requests to TTS and STT services
   - Handles CORS headers

## Service Endpoints

- Frontend: `http://localhost:8080`
- TTS API: `http://localhost:8080/tts`
- STT API: `http://localhost:8080/stt`
- Operation Status: `http://localhost:8080/operation`
- Presign URL: `http://localhost:8080/presign`

## Stopping the Services

```bash
docker-compose down
```

To also remove volumes:
```bash
docker-compose down -v
```

## Troubleshooting

### Check service logs:
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs tts
docker-compose logs stt
docker-compose logs nginx
```

### Follow logs in real-time:
```bash
docker-compose logs -f
```

### Rebuild after code changes:
```bash
docker-compose up --build
```

### Common Issues

1. **Port already in use:**
   - Change the port mapping in `docker-compose.yml`
   - Example: `"8090:80"` instead of `"8080:80"`

2. **API authentication errors:**
   - Verify your `API_SECRET` is correct
   - Ensure the API key has the required roles

3. **S3 connection errors:**
   - Check `S3_BUCKET`, `S3_KEY`, and `S3_SECRET` values
   - Verify the bucket exists and is accessible

4. **Frontend not loading:**
   - Check nginx logs: `docker-compose logs nginx`
   - Verify the frontend files are in `../../front/`

## Development

### Modify frontend:
Edit files in `../../front/` directory. Changes will be reflected immediately (no rebuild needed).

### Modify backend:
Edit files in `../../back/tts/` or `../../back/stt/` directories. Rebuild the containers:
```bash
docker-compose up --build
```

### Update nginx configuration:
Edit `nginx.conf` and restart nginx:
```bash
docker-compose restart nginx
```

## Production Deployment

For production deployment to Yandex Cloud, see the Terraform configuration in `../terraform/`.
