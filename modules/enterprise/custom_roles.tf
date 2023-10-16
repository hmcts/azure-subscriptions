resource "azurerm_role_definition" "custom_role_definitions" {
  for_each = local.custom_roles

  name        = each.key
  description = each.value.description
  scope       = each.value.scope

  permissions {
    actions = each.value.actions
  }

  depends_on = [
    azurerm_management_group.level_1,
    azurerm_management_group.level_2,
    azurerm_management_group.level_3,
    azurerm_management_group.level_4,
    azurerm_management_group.level_5,
    azurerm_management_group.level_6
  ]
}
