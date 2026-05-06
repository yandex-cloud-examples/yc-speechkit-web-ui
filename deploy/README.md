# С помощью Terraform в Yandex Cloud

<img
  src="../images/diagram.png"
  alt="SpeechKit Web UI"
  title="SpeechKit Web UI"
  style="display: inline-block; margin: 0 auto; max-width: 400px">

Данный модуль создает следующие ресурсы:

1. Бакет Object Storage
2. Объекты в бакете для работы статичного веб-сайта
2. Два контейнера Serverless Containers
3. API-шлюз
4. Сервисные учетные записи для работы контейнеров
5. Статичный ключ и API-ключ
7. Секрет в [Lockbox](https://cloud.yandex.ru/services/lockbox) для безопасного хранения ключей

В провайдере Terraform используется аутентификация через `key.json` файл. Для развертывания решения, необходима роль `admin` в каталоге, так как создаются сервисные учетные записи и выдаются роли.

При необходимости, измените аутентификацию на [токен](https://cloud.yandex.ru/ru/docs/iam/concepts/authorization/iam-token).

## Установка

Чтобы запустить данный модуль, создайте файл с переменными `private.auto.tfvars` и сохраните в него folder_id и cloud_id вашего облака и каталога:
```
cloud_id  = "b1g3xxxxxx"
folder_id = "b1g7xxxxxx
```

Также [создайте](https://yandex.cloud/ru/docs/iam/operations/authorized-key/create) авторизованный ключ `key.json` и сохраните в папку `deploy/terraform`, рядом с другими .tf файлами.

После этого, можно установить модуль Terraform:
```
cd deploy/terraform
terraform init
terraform apply
```

## Использование

После установки, будут отображены следующие Outputs:

```
api-gw = "https://d5dclvvxxx.apigw.yandexcloud.net"
bucket = "https://speechbench-xxx.website.yandexcloud.net"
```

Необходимо открыть ссылку bucket в веб-браузере.
В веб-приложении есть две вкладки, соответствующие возможностям TTS и STT.
Первый запрос может занимает больше времени, так как в этот момент запускается контейнер в первый раз.

Результаты синтеза сохраняются в бакет, в директории `audio`, а последнее полученное аудио, в случае успеха, доступно для прослушивания на веб-сайте.

Аудиофайлы, отправленные на распознавание, сохраняются в директории `upload`. Результаты распознавания выводятся в веб-интерфейсе: в виде JSON ответа, и в виде просуммированного ключа `text` из JSON ответа, для каждого из аудио-каналов.

## Удаление

Перед удалением, не забудьте очистить созданный бакет (иначе процесс удаления прервется):
```
cd deploy/terraform
terraform destroy
```

# Локально с помошью docker compose

> Потоковый режим распознавания работает только при развертывании через docker compose, так как необходима поддержка WebSockets.

## Пререквизиты

- Docker и Docker Compose
- Сервисный аккаунт в Yandex Cloud с ролями:
  - `ai.speechkit-stt.user`
  - `ai.speechkit-tts.user`
  - `ai.languageModels.user` (для суммаризации)
- S3 бакет
- Сервисный аккаунт с ролью `storage.editor` в бакете и статичный ключ

## Установка

## Setup

1. **Скопировать `.env` файл**
   ```bash
   cp .env.example .env
   ```

2. **Заполнить `.env` реквизитами:**
   ```bash
   # Yandex Cloud API Key
   API_SECRET=AQVNxxxxxxxxxxxxxxxxxxxxxxxxx

   # S3 бакет и ключ
   S3_BUCKET=my-speechkit-bucket
   S3_KEY=YCAJExxxxxxxxxxxxxxxxx
   S3_SECRET=YCOxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

   # Опционально: Модель для суммаризации
   MODEL_URI=gpt://b1gxxxxxxxxxxxxxxxxxx/yandexgpt-5.1
   ```

3. **Запустить:**
   ```bash
   cd deploy/local
   docker-compose up --build
   ```

   Либо в detach режиме:
   ```bash
   cd deploy/local
   docker-compose up -d --build
   ```

## Работа с приложением

Откройте брайзер и перейдите по адресу:

```
http://localhost:8080
```

## Остановка

```bash
docker-compose down
```