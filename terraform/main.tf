# Function Source
resource "random_string" "default" {
  length  = 4
  upper   = false
  lower   = true
  numeric = true
  special = false
}

# Service account main
resource "yandex_iam_service_account" "main" {
  folder_id       = var.folder_id
  name            = "speechbench-sa-${random_string.default.result}"
  description     = "speechbench-sa-${random_string.default.result}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-stt-user" {
  folder_id       = var.folder_id
  member          = "serviceAccount:${yandex_iam_service_account.main.id}"
  role            = "ai.speechkit-stt.user"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-tts-user" {
  folder_id       = var.folder_id
  member          = "serviceAccount:${yandex_iam_service_account.main.id}"
  role            = "ai.speechkit-tts.user"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-lockbox-payload" {
  folder_id       = var.folder_id
  member          = "serviceAccount:${yandex_iam_service_account.main.id}"
  role            = "lockbox.payloadViewer"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-storage-editor" {
  folder_id       = var.folder_id
  member          = "serviceAccount:${yandex_iam_service_account.main.id}"
  role            = "storage.editor"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-cr-puller" {
  folder_id       = var.folder_id
  member          = "serviceAccount:${yandex_iam_service_account.main.id}"
  role            = "container-registry.images.puller"
}

# Service account invoker
resource "yandex_iam_service_account" "invoker" {
  folder_id       = var.folder_id
  name            = "speechbench-sa-invoker-${random_string.default.result}"
  description     = "speechbench-sa-invoker-${random_string.default.result}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-invoker" {
  folder_id       = var.folder_id
  member          = "serviceAccount:${yandex_iam_service_account.invoker.id}"
  role            = "serverless-containers.containerInvoker"
}

# API key
resource "yandex_iam_service_account_api_key" "sa-api-key" {
  service_account_id = yandex_iam_service_account.main.id
  description        = "speechbench-sa-${random_string.default.result} API key"
}

# Static access key
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.main.id
  description        = "speechbench-sa-${random_string.default.result} static key"
}

# Lockbox
resource "yandex_lockbox_secret" "secret-api" {
  name = "speechbench-api-${random_string.default.result}"

  depends_on = [
    yandex_resourcemanager_folder_iam_member.sa-lockbox-payload,
  ]
}

resource "yandex_lockbox_secret_version" "secret-api-v1" {
  secret_id = yandex_lockbox_secret.secret-api.id
  entries {
    key        = "secret_key"
    text_value = yandex_iam_service_account_api_key.sa-api-key.secret_key
  }
}

resource "yandex_lockbox_secret" "secret-aws" {
  name = "speechbench-aws-${random_string.default.result}"
}

resource "yandex_lockbox_secret_version" "secret-aws-v1" {
  secret_id = yandex_lockbox_secret.secret-aws.id
  entries {
    key        = "access_key"
    text_value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  }
  entries {
    key        = "secret_key"
    text_value = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  }
}