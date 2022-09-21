resource "azurerm_role_assignment" "local_groups" {
  for_each             = local.groups
  scope                = "/subscriptions/${azurerm_subscription.this.subscription_id}"
  role_definition_name = each.key
  principal_id         = azuread_group.groups[each.key].id
}

resource "azurerm_role_assignment" "local_role_assignments" {
  for_each             = local.role_assignments
  scope                = each.value.scope
  role_definition_name = each.key
  principal_id         = each.value.principal_id
}