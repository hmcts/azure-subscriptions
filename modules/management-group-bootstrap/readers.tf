resource "azuread_group" "readers" {
  for_each = var.groups


  display_name            = "DTS Readers (mg:${each.value.id})"
  prevent_duplicate_names = true
  security_enabled        = true
}

resource "azurerm_role_assignment" "readers" {
  for_each = var.groups

  principal_id         = azuread_group.readers[each.value.id].object_id
  scope                = "/providers/Microsoft.Management/managementGroups/${each.value.id}"
  role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "custom_role_assignments_readers" {
  for_each = {
    for association in local.group_assignment_product_readers : "${association[0]} - ${association[1]}" => {
      group = association[0]
      role  = association[1]
  } }

  principal_id       = azuread_group.readers[each.value.group].object_id
  scope              = "/providers/Microsoft.Management/managementGroups/${each.value.group}"
  role_definition_id = var.custom_roles[each.value.role].id
}
