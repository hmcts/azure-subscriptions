resource "azuread_group" "storage_blob_data_contributor" {
  for_each = var.groups


  display_name            = "DTS Storage Blob Data Contributor (mg:${each.value.id})"
  prevent_duplicate_names = true
  security_enabled        = true
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  for_each = var.groups

  principal_id         = azuread_group.storage_blob_data_contributor[each.value.id].object_id
  scope                = "/providers/Microsoft.Management/managementGroups/${each.value.id}"
  role_definition_name = "Storage Blob Data Contributor"
}