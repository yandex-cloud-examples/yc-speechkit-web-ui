FROM python:3.10-slim

WORKDIR /app
COPY /app /app

RUN chmod +x /app/ffmpeg
ENV PATH="/app:${PATH}"

RUN pip install --no-cache-dir -r requirements.txt

CMD [ "python", "main.py" ]