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

# provider "azurerm" {
#   features {}
#   subscription_id = module.subscription.subscription_id
#   alias           = "subscription"
# }

# provider "azurerm" {
#   features {}
#   subscription_id = "ed302caf-ec27-4c64-a05e-85731c3ce90e"
#   alias           = "dnszone"
# }

provider "azuredevops" {}

data "azurerm_client_config" "core" {}

data "azuread_group" "dns_contributor" {
  display_name = "DTS Public DNS Contributor (env:${lower(var.env)})"
}