output "custom_roles" {
  value = { for k, v in azurerm_role_definition.custom_role_definitions : k => v }
}