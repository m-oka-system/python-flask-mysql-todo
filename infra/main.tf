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
  name                = azurecaf_name.webapp_name.result
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
    "DB_HOST"     = ""
    "DB_NAME"     = ""
    "DB_USER"     = ""
    "DB_PASSWORD" = ""
    "DB_PORT"     = ""
  }

  site_config {
    application_stack {
      python_version = var.app_service.python_version
    }
  }

  tags = local.tags
}
