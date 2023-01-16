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

locals {
  custom_role_assignments = [
    "Application Gateway Backend Health Reader"
  ]
}


resource "azurerm_role_assignment" "custom_role_assignments_readers" {
  for_each = {for group_key, group_value in var.groups : { for role in local.custom_role_assignments : group_key => role }}

  principal_id       = azuread_group.readers[each.key].object_id
  scope              = "/providers/Microsoft.Management/managementGroups/${each.key}"
  role_definition_id = var.custom_roles[each.value].principal_id
}
