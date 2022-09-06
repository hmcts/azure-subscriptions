data "azurerm_client_config" "current" {}

data "azuread_group" "ops_mgmt" {
  display_name = "DTS Operations (env:mgmt)"
}

data "azuread_group" "ops_env" {
  display_name = join("", ["DTS Operations (env:", lower(var.value.environment), ")"])
}

data "azuread_group" "dns_contributor" {
  display_name = "DTS Public DNS Contributor (env:${lower(var.value.environment)})"
}