output "bucket" {
  value = "https://${yandex_storage_bucket.front.bucket}.website.yandexcloud.net"
}

output "api-gw" {
  value = "https://${yandex_api_gateway.api-gw.id}.apigw.yandexcloud.net"
}