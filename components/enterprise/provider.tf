terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.2"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "microsoft/azuredevops" {}

data "azurerm_client_config" "core" {}
