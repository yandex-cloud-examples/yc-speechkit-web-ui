# TTS
resource "yandex_serverless_container" "tts" {
  name               = "speechbench-tts-${random_string.default.result}"
  memory             = 1024
  cores              = 1
  execution_timeout  = "300s"
  service_account_id = yandex_iam_service_account.main.id

  secrets {
    id = "${yandex_lockbox_secret.secret-api.id}"
    version_id = "${yandex_lockbox_secret_version.secret-api-v1.id}"
    key = "secret_key"
    environment_variable = "API_SECRET"
  }

  secrets {
    id                   = yandex_lockbox_secret.secret-aws.id
    version_id           = yandex_lockbox_secret_version.secret-aws-v1.id
    key                  = "access_key"
    environment_variable = "S3_KEY"
  }

  secrets {
    id                   = yandex_lockbox_secret.secret-aws.id
    version_id           = yandex_lockbox_secret_version.secret-aws-v1.id
    key                  = "secret_key"
    environment_variable = "S3_SECRET"
  }

  image {
      url = "cr.yandex/sol/speechkit-workbench/tts-service:1.0.1"
      environment = {
          S3_BUCKET = yandex_storage_bucket.front.bucket
      }
  }
}
# STT
resource "yandex_serverless_container" "stt" {
  name               = "speechbench-stt-${random_string.default.result}"
  memory             = 1024
  cores              = 1
  execution_timeout  = "300s"
  service_account_id = yandex_iam_service_account.main.id

  secrets {
    id = "${yandex_lockbox_secret.secret-api.id}"
    version_id = "${yandex_lockbox_secret_version.secret-api-v1.id}"
    key = "secret_key"
    environment_variable = "API_SECRET"
  }

  secrets {
    id                   = yandex_lockbox_secret.secret-aws.id
    version_id           = yandex_lockbox_secret_version.secret-aws-v1.id
    key                  = "access_key"
    environment_variable = "S3_KEY"
  }

  secrets {
    id                   = yandex_lockbox_secret.secret-aws.id
    version_id           = yandex_lockbox_secret_version.secret-aws-v1.id
    key                  = "secret_key"
    environment_variable = "S3_SECRET"
  }

  image {
      url = "cr.yandex/sol/speechkit-workbench/stt-service:1.0.1"
      environment = {
          S3_BUCKET = yandex_storage_bucket.front.bucket
      }
  }
}

# API gateway
resource "yandex_api_gateway" "api-gw" {
  name = "speechbench-api-gw-${random_string.default.result}"
  spec = <<-EOT
    openapi: 3.0.0
    info:
      title: SpeechKit Workbench API
      version: 1.0.0

    x-yc-apigateway:
      cors:
        origin: '*'
        methods: '*'
        allowedHeaders: '*'

    paths:
      /tts:
        post:
          x-yc-apigateway-integration:
            type: serverless_containers
            container_id: "${yandex_serverless_container.tts.id}"
            service_account_id: "${yandex_iam_service_account.invoker.id}"
        options:
          x-yc-apigateway-integration:
            type: serverless_containers
            container_id: "${yandex_serverless_container.tts.id}"
            service_account_id: "${yandex_iam_service_account.invoker.id}"
      /stt:
        post:
          x-yc-apigateway-integration:
            type: serverless_containers
            container_id: "${yandex_serverless_container.stt.id}"
            service_account_id: "${yandex_iam_service_account.invoker.id}"
        options:
          x-yc-apigateway-integration:
            type: serverless_containers
            container_id: "${yandex_serverless_container.stt.id}"
            service_account_id: "${yandex_iam_service_account.invoker.id}"
      /operation:
        get:
          x-yc-apigateway-integration:
            type: serverless_containers
            container_id: "${yandex_serverless_container.stt.id}"
            service_account_id: "${yandex_iam_service_account.invoker.id}"
        options:
          x-yc-apigateway-integration:
            type: serverless_containers
            container_id: "${yandex_serverless_container.stt.id}"
            service_account_id: "${yandex_iam_service_account.invoker.id}"
      /presign:
        get:
          x-yc-apigateway-integration:
            type: serverless_containers
            container_id: "${yandex_serverless_container.stt.id}"
            service_account_id: "${yandex_iam_service_account.invoker.id}"
        options:
          x-yc-apigateway-integration:
            type: serverless_containers
            container_id: "${yandex_serverless_container.stt.id}"
            service_account_id: "${yandex_iam_service_account.invoker.id}"
  EOT
}