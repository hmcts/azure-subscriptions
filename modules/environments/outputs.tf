output "dns_contributor_group_id" {
  value = azuread_group.groups["DNS Zone Contributor"].object_id
}

output "dts_operations_group_id" {
  value = azuread_group.groups["DTS Operations"].object_id
}
