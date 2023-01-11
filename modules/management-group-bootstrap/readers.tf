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

resource "azurerm_role_assignment" "app_gateway_backend_health_reader" {
  for_each = var.groups

  principal_id         = azuread_group.readers[each.value.id].object_id
  scope                = "/providers/Microsoft.Management/managementGroups/${each.value.id}"
  role_definition_id   = "159469f4-6e46-4b09-aa73-8e2f243aa784"
}