data "azuread_group" "acr" {
  display_name = "DTS ACR Access Administrators"
}

# data "azuread_group" "dns_contributor" {
#   display_name = "DTS Public DNS Contributor (env:${lower(var.env)})"
# }

# data "azuread_group" "ops_env" {
#   display_name = join("", ["DTS Operations (env:", lower(var.env), ")"])
# }

data "azurerm_client_config" "current" {}