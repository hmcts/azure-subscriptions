output "custom_roles" {
  value = var.create_custom_roles == true ? azurerm_role_definition.custom_role_definitions : data.azurerm_role_definition.custom_role_definitions
}
