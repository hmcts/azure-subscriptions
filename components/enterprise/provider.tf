terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.2"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.2.2"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azuredevops" {
  org_service_url       = var.org_url
  personal_access_token = var.personal_access_token
}

data "azurerm_client_config" "core" {}
