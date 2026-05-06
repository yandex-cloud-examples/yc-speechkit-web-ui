variable "folder_id" {
    description = "Yandex Cloud folder-id"
}

variable "cloud_id" {
    description = "Yandex Cloud cloud-id"
}

variable "zone" {
    description = "Yandex Cloud region"
    default = "ru-central1-a"
}

variable "provider_key_file" {
    description = "Yandex Cloud provider key file"
    default = "./key.json"
}