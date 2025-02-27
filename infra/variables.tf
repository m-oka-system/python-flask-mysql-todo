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
    name                            = string
    address_prefixes                = list(string)
    default_outbound_access_enabled = bool
  }))
  default = {
    pe = {
      name                            = "pe"
      address_prefixes                = ["10.0.0.0/24"]
      default_outbound_access_enabled = true
    }
    app = {
      name                            = "app"
      address_prefixes                = ["10.0.1.0/24"]
      default_outbound_access_enabled = true
    }
    db = {
      name                            = "db"
      address_prefixes                = ["10.0.2.0/24"]
      default_outbound_access_enabled = true
    }
    vm = {
      name                            = "vm"
      address_prefixes                = ["10.0.3.0/24"]
      default_outbound_access_enabled = false
    }
    bastion = {
      name                            = "AzureBastionSubnet"
      address_prefixes                = ["10.0.4.0/24"]
      default_outbound_access_enabled = true
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
    bastion = {
      name = "bastion"
    }
  }
}

variable "bastion_security_rules" {
  type = map(object({
    priority                   = number
    protocol                   = string
    destination_port_range     = string       # 複数ポートを指定する場合は null
    destination_port_ranges    = list(string) # 単一ポートを指定する場合は null
    source_address_prefix      = string
    destination_address_prefix = string
    direction                  = string
    access                     = string
    source_port_range          = string
  }))
  default = {
    AllowHttpsInbound = {
      priority                   = 120
      protocol                   = "Tcp"
      destination_port_range     = "443"
      destination_port_ranges    = null
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      direction                  = "Inbound"
      access                     = "Allow"
      source_port_range          = "*"
    }
    AllowGatewayManagerInbound = {
      priority                   = 130
      protocol                   = "Tcp"
      destination_port_range     = "443"
      destination_port_ranges    = null
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
      direction                  = "Inbound"
      access                     = "Allow"
      source_port_range          = "*"
    }
    AllowAzureLoadBalancerInbound = {
      priority                   = 140
      protocol                   = "Tcp"
      destination_port_range     = "443"
      destination_port_ranges    = null
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      direction                  = "Inbound"
      access                     = "Allow"
      source_port_range          = "*"
    }
    AllowBastionHostCommunication = {
      priority                   = 150
      protocol                   = "*"
      destination_port_range     = null
      destination_port_ranges    = ["8080", "5701"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      direction                  = "Inbound"
      access                     = "Allow"
      source_port_range          = "*"
    }
    DenyAllInbound = {
      priority                   = 4096
      protocol                   = "*"
      destination_port_range     = "*"
      destination_port_ranges    = null
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      direction                  = "Inbound"
      access                     = "Deny"
      source_port_range          = "*"
    }
    AllowSshRdpOutbound = {
      priority                   = 100
      protocol                   = "*"
      destination_port_range     = null
      destination_port_ranges    = ["22", "3389"]
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
      direction                  = "Outbound"
      access                     = "Allow"
      source_port_range          = "*"
    }
    AllowAzureCloudOutbound = {
      priority                   = 110
      protocol                   = "Tcp"
      destination_port_range     = "443"
      destination_port_ranges    = null
      source_address_prefix      = "*"
      destination_address_prefix = "AzureCloud"
      direction                  = "Outbound"
      access                     = "Allow"
      source_port_range          = "*"
    }
    AllowBastionCommunication = {
      priority                   = 120
      protocol                   = "*"
      destination_port_range     = null
      destination_port_ranges    = ["8080", "5701"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      direction                  = "Outbound"
      access                     = "Allow"
      source_port_range          = "*"
    }
    AllowHttpOutbound = {
      priority                   = 130
      protocol                   = "*"
      destination_port_range     = "80"
      destination_port_ranges    = null
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
      direction                  = "Outbound"
      access                     = "Allow"
      source_port_range          = "*"
    }
    DenyAllOutbound = {
      priority                   = 4096
      protocol                   = "*"
      destination_port_range     = "*"
      destination_port_ranges    = null
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      direction                  = "Outbound"
      access                     = "Deny"
      source_port_range          = "*"
    }
  }
}
