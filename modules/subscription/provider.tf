terraform {
  required_version = "1.6.1"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.7.0"
    }
  }
}