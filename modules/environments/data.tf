data "azuread_group" "acr" {
  name = "DTS ACR Access Administrators"
}

data "azuread_group" "dns_contributor" {
  display_name = "DTS Public DNS Contributor (env:${lower(var.environment)})"
}