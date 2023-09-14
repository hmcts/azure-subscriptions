terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.22.0"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}

  client_id       = "25c5cb78-93f1-415e-a4d7-b269d0b24ff9"
  client_secret   = "zpw8Q~Kn~rAKIvCfe1rS6WpN-CWHWLZtYNIMha.E"
  tenant_id       = "531ff96d-0ae9-462a-8d2d-bec7c0b42082"
  subscription_id = "ae75b9fb-7d34-4112-82ff-64bd3855ce27"
}

provider "azuredevops" {}

data "azurerm_client_config" "core" {}
