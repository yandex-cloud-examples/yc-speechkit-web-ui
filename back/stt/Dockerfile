FROM python:3.10-slim

WORKDIR /app
COPY /app /app

RUN pip install --no-cache-dir -r requirements.txt

CMD [ "python", "main.py" ]