data "azurerm_role_definition" "custom_role_definitions" {
  for_each = local.custom_roles

  name  = each.key
  scope = each.value.scope
}
