terraform {
  required_version = ">= 1.9.5"
  required_providers {
    azurerm = {
      version = "4.18.0"
      source  = "hashicorp/azurerm"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "azurerm" {
  # サブスクリプション ID (環境変数 ARM_SUBSCRIPTION_ID を設定していない場合は必要)
  # subscription_id = "00000000-0000-0000-0000-000000000000"

  # リソースプロバイダーの自動登録を無効にする
  resource_provider_registrations = "none"

  # リソースプロバイダーの登録を手動で行う
  resource_providers_to_register = [
    "Microsoft.Advisor",
    "Microsoft.DBforMySQL",
    "Microsoft.KeyVault",
    "Microsoft.Network",
    "Microsoft.Web",
  ]
  features {
    key_vault {
      # Azure Key Vault の論理削除を無効にする
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      # リソースグループ内にリソースがあっても削除する
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "random_integer" "num" {
  min = 10000
  max = 99999
}
