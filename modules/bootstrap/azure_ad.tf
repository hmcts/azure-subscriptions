resource "azuread_group" "group" {
  for_each                = local.groups
  display_name            = each.value.name
  description             = each.value.description
  prevent_duplicate_names = true
  security_enabled        = true
}

resource "azurerm_role_assignment" "role" {
  for_each             = local.groups
  scope                = var.subscription_id
  role_definition_name = each.key
  principal_id         = azuread_group.group.id
}