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
  for_each           = local.custom_role_assignments
  scope              = each.value.scope
  role_definition_id = azurerm_role_definition.app_gateway_backend_health_reader.id
  principal_id       = each.value.principal_id

}