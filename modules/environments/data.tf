data "azuread_group" "acr" {
  display_name = "DTS ACR Access Administrators"
}

data "azurerm_client_config" "current" {}

data "azurerm_subscriptions" "service_endpoint_subscription" {
  count = var.add_service_connection_to_ado == true ? 1 : 0
  # Environment service connections are associated to the SDS subscriptions
  # because they need to be associated to at least one even if you are using a different one
  display_name_prefix = "DTS-SHAREDSERVICES"
}

