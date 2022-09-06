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
  features {}
}

data "azurerm_client_config" "core" {}
