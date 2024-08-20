terraform {
  required_version = "1.9.5"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.10.0"
    }
  }
}