data "azuread_group" "acr" {
  display_name = "DTS ACR Access Administrators"
}

data "azurerm_client_config" "current" {}

data "azurerm_subscriptions" "service_endpoint_subscription" {
  count               = var.pipeline_environment == "prod" ? 1 : 0
  display_name_prefix = "DTS-SHAREDSERVICES"
}

