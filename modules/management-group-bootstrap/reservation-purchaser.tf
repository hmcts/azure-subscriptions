resource "azuread_group" "reservation_purchaser" {
  for_each = var.groups


  display_name            = "DTS Reservation Purchaser (mg:${each.value.id})"
  prevent_duplicate_names = true
  security_enabled        = true
}

resource "azurerm_role_assignment" "reservation_purchaser" {
  for_each = var.groups

  principal_id         = azuread_group.reservation_purchaser[each.value.id].object_id
  scope                = "/providers/Microsoft.Management/managementGroups/${each.value.id}"
  role_definition_name = "Reservation Purchaser"
}
