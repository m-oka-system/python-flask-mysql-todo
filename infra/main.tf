locals {
  tags = { azd-env-name : var.environment_name }
}

# ------------------------------------------------------------------------------------------------------
# Resource Group
# ------------------------------------------------------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.environment_name}"
  location = var.location

  tags = local.tags
}

# ------------------------------------------------------------------------------------------------------
# App Service
# ------------------------------------------------------------------------------------------------------
resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.environment_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  os_type             = var.app_service_plan.os_type
  sku_name            = var.app_service_plan.sku_name

  tags = local.tags
}

resource "azurerm_linux_web_app" "webapp" {
  name                          = "app-${var.environment_name}-${random_integer.num.result}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  service_plan_id               = azurerm_service_plan.asp.id
  https_only                    = true
  public_network_access_enabled = true

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "DB_HOST"                        = azurerm_mysql_flexible_server.mysql.fqdn
    "DB_USER"                        = azurerm_mysql_flexible_server.mysql.administrator_login
    "DB_PASSWORD"                    = random_password.password[0].result
    "DB_NAME"                        = azurerm_mysql_flexible_database.db.name
  }

  site_config {
    application_stack {
      python_version = var.app_service.python_version
    }
  }

  tags = merge(local.tags, { azd-service-name : "web" })
}

# ------------------------------------------------------------------------------------------------------
# Azure Database for MySQL Flexible Server
# ------------------------------------------------------------------------------------------------------
resource "random_password" "password" {
  count       = 1
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  special     = false
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                         = "mysql-${var.environment_name}-${random_integer.num.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = var.location
  administrator_login          = var.mysql.administrator_login
  administrator_password       = random_password.password[0].result
  sku_name                     = var.mysql.sku_name
  version                      = var.mysql.version
  zone                         = var.mysql.zone
  backup_retention_days        = var.mysql.backup_retention_days
  geo_redundant_backup_enabled = var.mysql.geo_redundant_backup_enabled

  storage {
    auto_grow_enabled = var.mysql.storage.auto_grow_enabled
    iops              = var.mysql.storage.iops
    size_gb           = var.mysql.storage.size_gb
  }

  tags = local.tags
}

resource "azurerm_mysql_flexible_database" "db" {
  name                = var.mysql_database.name
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = var.mysql_database.charset
  collation           = var.mysql_database.collation
}

resource "azurerm_mysql_flexible_server_firewall_rule" "firewall_rule" {
  name                = "AllowAllAzureServicesAndResourcesWithinAzureIps"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# ------------------------------------------------------------------------------------------------------
# Azure Key Vault
# ------------------------------------------------------------------------------------------------------
resource "azurerm_key_vault" "key_vault" {
  name                       = "kv-${var.environment_name}-${random_integer.num.result}"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  sku_name                   = var.key_vault.sku_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization  = var.key_vault.enable_rbac_authorization
  purge_protection_enabled   = var.key_vault.purge_protection_enabled
  soft_delete_retention_days = var.key_vault.soft_delete_retention_days

  tags = local.tags
}

# ------------------------------------------------------------------------------------------------------
# Virtual Network
# ------------------------------------------------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.environment_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  address_space       = var.vnet.address_space

  tags = local.tags
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = "snet-${each.value.name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
}

# ------------------------------------------------------------------------------------------------------
# Network Security Group
# ------------------------------------------------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.network_security_groups
  name                = "nsg-${each.value.name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each                  = var.network_security_groups
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
