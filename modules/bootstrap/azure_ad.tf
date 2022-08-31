resource "azuread_group" "group" {
  for_each                = local.groups
  display_name            = each.value.name
  description             = each.value.description
  prevent_duplicate_names = true
  security_enabled        = true
}

resource "azurerm_role_assignment" "local_groups" {
  for_each             = local.groups
  scope                = var.scope
  role_definition_name = each.key
  principal_id         = azuread_group.group[each.key].id
}

resource "azurerm_role_assignment" "local_role_assignments" {
  for_each             = local.role_assignments
  scope                = each.value.scope
  role_definition_name = each.key
  principal_id         = each.value.principal_id
}