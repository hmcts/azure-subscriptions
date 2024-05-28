terraform {
  required_version = "1.6.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.76.0"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azuredevops" {
  org_service_url = "https://dev.azure.com/hmcts"
  client_id       = "10936009-a112-4733-bb2a-94ee240b79ff" # azure-devops-sp
  tenant_id       = "531ff96d-0ae9-462a-8d2d-bec7c0b42082"
  client_secret   = data.azurerm_key_vault_secret.example.value
}

data "azurerm_key_vault_secret" "example" {
  name         = "azure-devops-sp-token"
  key_vault_id = "/subscriptions/1c4f0704-a29e-403d-b719-b90c34ef14c9/resourceGroups/cnp-core-infra/providers/Microsoft.KeyVault/vaults/infra-vault-nonprod"
}
data "azurerm_client_config" "core" {}
