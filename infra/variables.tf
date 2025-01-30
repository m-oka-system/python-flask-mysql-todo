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
    zone                         = "2"
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

variable "key_vault" {
  type = object({
    sku_name                   = string
    enable_rbac_authorization  = bool
    purge_protection_enabled   = bool
    soft_delete_retention_days = number
  })
  default = {
    sku_name                   = "standard"
    enable_rbac_authorization  = true
    purge_protection_enabled   = false
    soft_delete_retention_days = 7
  }
}

variable "vnet" {
  type = map(list(string))
  default = {
    address_space = ["10.0.0.0/16"]
  }
}

variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  default = {
    pe = {
      name             = "pe"
      address_prefixes = ["10.0.0.0/24"]
    }
    app = {
      name             = "app"
      address_prefixes = ["10.0.1.0/24"]
    }
    db = {
      name             = "db"
      address_prefixes = ["10.0.2.0/24"]
    }
    vm = {
      name             = "vm"
      address_prefixes = ["10.0.3.0/24"]
    }
    bastion = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.0.4.0/24"]
    }
  }
}

variable "network_security_groups" {
  type = map(object({
    name = string
  }))
  default = {
    pe = {
      name = "pe"
    }
    app = {
      name = "app"
    }
    db = {
      name = "db"
    }
    vm = {
      name = "vm"
    }
  }
}
