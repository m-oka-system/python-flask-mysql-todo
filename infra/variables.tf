variable "environment_name" {
  type = string
}

variable "location" {
  type = string
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

variable "mysql" {
  type = object({
    administrator_login          = string
    sku_name                     = string
    version                      = string
    zone                         = string
    backup_retention_days        = number
    geo_redundant_backup_enabled = bool
    storage = object({
      auto_grow_enabled = bool
      iops              = number
      size_gb           = number
    })
  })
  default = {
    administrator_login          = "sqladmin"
    sku_name                     = "B_Standard_B1ms"
    version                      = "8.0.21"
    zone                         = "1"
    backup_retention_days        = 7
    geo_redundant_backup_enabled = false
    storage = {
      auto_grow_enabled = true
      iops              = 360
      size_gb           = 20
    }
  }
}

variable "mysql_database" {
  type = map(string)
  default = {
    name      = "MyDatabase"
    charset   = "utf8mb4"
    collation = "utf8mb4_0900_ai_ci"
  }
}
