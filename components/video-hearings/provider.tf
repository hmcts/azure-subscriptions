terraform {
  required_version = "1.10.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "core" {}
