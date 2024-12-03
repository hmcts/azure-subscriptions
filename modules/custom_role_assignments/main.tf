resource "azurerm_role_assignment" "custom_role_assignments" {
  for_each           = { for k, v in var.custom_roles : k => v if contains(keys(local.custom_role_assignments), k) }
  scope              = "/subscriptions/${var.subscription_id}"
  role_definition_id = "/subscriptions/${var.subscription_id}${each.value.id}"
  principal_id       = local.custom_role_assignments[each.key].principal_id
}
