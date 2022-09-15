output "asp_id" {
  value = azurerm_service_plan.asp.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

output "dns_contributor_group_id" {
  value = azuread_group.groups["DNS Zone Contributor"].object_id
}

output "dts_operations_group_id" {
  value = azuread_group.groups["DTS Operations"].object_id
}
