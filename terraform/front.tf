# Object storage bucket
resource "yandex_storage_bucket" "front" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "speechbench-${random_string.default.result}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  depends_on = [
    yandex_iam_service_account_static_access_key.sa-static-key,
    yandex_resourcemanager_folder_iam_member.sa-storage-editor,
  ]
}

resource "yandex_storage_object" "index" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  
  bucket = yandex_storage_bucket.front.bucket
  key    = "index.html"
  source = "../front/index.html"
  source_hash = filemd5("../front/index.html")

  depends_on = [
    yandex_iam_service_account_static_access_key.sa-static-key,
    yandex_resourcemanager_folder_iam_member.sa-storage-editor,
  ]
}

resource "yandex_storage_object" "error" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  
  bucket = yandex_storage_bucket.front.bucket
  key    = "error.html"
  source = "../front/error.html"
  source_hash = filemd5("../front/error.html")

  depends_on = [
    yandex_iam_service_account_static_access_key.sa-static-key,
    yandex_resourcemanager_folder_iam_member.sa-storage-editor,
  ]
}

resource "yandex_storage_object" "script" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  
  bucket = yandex_storage_bucket.front.bucket
  key    = "script.js"
  source_hash = filemd5("../front/script.js.tpl")
  content = templatefile("../front/script.js.tpl",
    {
      api_gw   = "https://${yandex_api_gateway.api-gw.domain}",
    }
  )

  depends_on = [
    yandex_iam_service_account_static_access_key.sa-static-key,
    yandex_resourcemanager_folder_iam_member.sa-storage-editor,
  ]
}