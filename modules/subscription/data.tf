data "azurerm_client_config" "current" {}

data "azuread_group" "ops_mgmt" {
  display_name = "DTS Operations (env:mgmt)"
}

data "azuread_group" "aks_global_admin" {
  display_name = "dcd_group_aks_admin_global_v2"
}

data "azuread_group" "dts_operations" {
  display_name = "DTS Operations (env:${var.environment})"
}

data "azuread_group" "dts_owners" {
  display_name = "DTS Owners (sub:${azurerm_subscription.this.subscription_name})"
}
