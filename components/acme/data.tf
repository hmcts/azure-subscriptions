data "azurerm_subscriptions" "subscription" {
  for_each = { for k, v in local.subscriptions : k => v if try(v.deploy_acme, false) }
  # Environment service connections are associated to the SDS subscriptions
  # because they need to be associated to at least one even if you are using a different one
  display_name_prefix = each.key
}

# data "azuread_group" "group" {
#   display_name     = "DTS Platform Operations"
#   security_enabled = true
# }