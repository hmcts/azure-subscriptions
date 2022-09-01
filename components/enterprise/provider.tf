terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.2"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.1.8"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/hmcts"
  personal_access_token = data.azurerm_key_vault_secret.ado_token.value
}

data "azurerm_client_config" "core" {}

data "azurerm_key_vault" "infra_vault" {
  name                = "infra-vault-${var.env}"
  resource_group_name = "cnp-core-infra"
}

data "azurerm_key_vault_secret" "ado_token" {
  name         = "azure-devops-token"
  key_vault_id = data.azurerm_key_vault.infra_vault.id
}
