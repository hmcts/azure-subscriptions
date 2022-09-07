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

data "azurerm_subscriptions" "sds" {
  count               = var.pipeline_environment == "prod" || var.env != "ptl" || var.env != "ptlsbox" ? 1 : 0
  display_name_prefix = "DTS-SHAREDSERVICES-${var.env}"
}

data "azurerm_subscriptions" "sds_ptl" {
  count               = var.pipeline_environment == "prod" || var.env == "ptl" ? 1 : 0
  display_name_prefix = "DTS-SHAREDSERVICESPTL"
}

data "azurerm_subscriptions" "sds_ptlsbox" {
  count               = var.pipeline_environment == "prod" || var.env == "ptlsbox" ? 1 : 0
  display_name_prefix = "DTS-SHAREDSERVICESPTL-SBOX"
}