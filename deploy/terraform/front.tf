# Object storage bucket
resource "yandex_storage_bucket" "front" {
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
}

resource "yandex_storage_object" "index" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  
  bucket = yandex_storage_bucket.front.bucket
  key    = "index.html"
  source = "../../front/index.html"
  source_hash = filemd5("../../front/index.html")
}

resource "yandex_storage_object" "error" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  
  bucket = yandex_storage_bucket.front.bucket
  key    = "error.html"
  source = "../../front/error.html"
  source_hash = filemd5("../../front/error.html")
}

resource "yandex_storage_object" "script" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  
  bucket = yandex_storage_bucket.front.bucket
  key    = "script.js"
  source_hash = filemd5("../../front/script.js.tpl")
  content = templatefile("../../front/script.js.tpl",
    {
      api_gw   = "https://${yandex_api_gateway.api-gw.domain}",
    }
  )
}

resource "yandex_storage_object" "style" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  
  bucket       = yandex_storage_bucket.front.bucket
  key          = "style.css"
  source       = "../../front/style.css"
  source_hash  = filemd5("../../front/style.css")
  content_type = "text/css"
}
