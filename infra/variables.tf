variable "environment_name" {
  type = string
}

variable "location" {
  type    = string
  default = "japaneast"
}

variable "app_service_plan" {
  type = map(string)
  default = {
    sku_name = "B1"
    os_type  = "Linux"
  }
}

variable "app_service" {
  type = map(string)
  default = {
    python_version = "3.12"
  }
}
