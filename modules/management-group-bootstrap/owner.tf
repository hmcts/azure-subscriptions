# resource "azuread_group" "owners" {
#   for_each = var.groups

#   display_name            = "DTS Owners (mg:${each.value.id})"
#   prevent_duplicate_names = true
#   security_enabled        = true
# }

# resource "azurerm_role_assignment" "owners" {
#   for_each = var.groups

#   principal_id         = azuread_group.owners[each.value.id].object_id
#   scope                = "/providers/Microsoft.Management/managementGroups/${each.value.id}"
#   role_definition_name = "Owner"
# }
