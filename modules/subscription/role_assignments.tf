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

resource "azurerm_role_assignment" "local_custom_role_assignments" {
  for_each           = { for k, v in var.custom_roles : k => v if contains(keys(local.custom_role_assignments), k) }
  scope              = "/subscriptions/${azurerm_subscription.this.subscription_id}"
  role_definition_id = "/subscriptions/${azurerm_subscription.this.subscription_id}/${each.value.role_definition_resource_id}"
  principal_id       = local.custom_role_assignments[each.key].principal_id
}
