locals {
  tags = { azd-env-name : var.environment_name }
}

# ------------------------------------------------------------------------------------------------------
# Resource Group
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "rg_name" {
  name          = var.environment_name
  resource_type = "azurerm_resource_group"
  random_length = 0
  clean_input   = true
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg_name.result
  location = var.location

  tags = local.tags
}

# ------------------------------------------------------------------------------------------------------
# App Service
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "asp_name" {
  name          = var.environment_name
  resource_type = "azurerm_app_service_plan"
  random_length = 0
  clean_input   = true
}

resource "azurecaf_name" "webapp_name" {
  name          = var.environment_name
  resource_type = "azurerm_app_service"
  random_length = 0
  clean_input   = true
}

resource "azurerm_service_plan" "asp" {
  name                = azurecaf_name.asp_name.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  os_type             = var.app_service_plan.os_type
  sku_name            = var.app_service_plan.sku_name

  tags = local.tags
}

resource "azurerm_linux_web_app" "webapp" {
  name                          = azurecaf_name.webapp_name.result
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
resource "azurecaf_name" "mysql_name" {
  name          = var.environment_name
  resource_type = "azurerm_mysql_server"
  random_length = 0
  clean_input   = true
}

resource "random_password" "password" {
  count       = 1
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  special     = false
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                         = azurecaf_name.mysql_name.result
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
