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

  role_assignments = distinct(flatten([
    for group in var.groups : [
      for role in var.custom_roles : {
        group = group.id
        role  = role
      } if contains(keys(local.custom_role_assignments), k)
  ]]))
}


resource "azurerm_role_assignment" "custom_role_assignments_readers" {
  for_each = { for k, v in local.role_assignments : "${k}-${v.group}" => v }


  principal_id       = azuread_group.readers[each.value.group].object_id
  scope              = "/providers/Microsoft.Management/managementGroups/${each.value.group}"
  role_definition_id = var.custom_roles[each.value.role].role_definition_id
}
