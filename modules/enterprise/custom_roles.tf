resource "azurerm_role_definition" "custom_role_definitions" {
  for_each = var.create_custom_roles == true ? local.custom_roles : []

  name        = each.key
  description = each.value.description
  scope       = each.value.scope

  permissions {
    actions = each.value.actions
  }
}

data "azurerm_role_definition" "custom_role_definitions" {
  for_each = var.create_custom_roles == false ? local.custom_roles : []

  name  = each.key
  scope = each.value.scope
}
