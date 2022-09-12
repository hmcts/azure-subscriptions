data "azuread_group" "acr" {
  display_name = "DTS ACR Access Administrators"
}

data "azurerm_client_config" "current" {}

data "azurerm_subscriptions" "sds" {
  count               = var.pipeline_environment == "prod"
  display_name_prefix = var.display_name_prefix
}