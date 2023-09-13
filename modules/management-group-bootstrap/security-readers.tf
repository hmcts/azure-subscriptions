# resource "azuread_group" "security_readers" {
#   for_each = var.groups


#   display_name            = "DTS Security Readers (mg:${each.value.id})"
#   prevent_duplicate_names = true
#   security_enabled        = true
# }

# resource "azurerm_role_assignment" "security_readers" {
#   for_each = var.groups

#   principal_id         = azuread_group.security_readers[each.value.id].object_id
#   scope                = "/providers/Microsoft.Management/managementGroups/${each.value.id}"
#   role_definition_name = "Security Reader"
# }
