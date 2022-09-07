resource "azuread_group" "groups" {
  for_each                = local.groups
  display_name            = each.value.name
  description             = each.value.description
  prevent_duplicate_names = false # to be changed, set to false to ensure successful plan before state migration
  security_enabled        = true

  members = each.value.members
}

resource "azuread_group_member" "acr" {
  group_object_id  = data.azuread_group.acr.object_id
  member_object_id = azuread_group.groups["DTS Operations"].object_id
}

resource "azuread_group_member" "dns_zone_contributor" {
  group_object_id  = azuread_group.groups["DTS Zone Contributor"].object_id
  member_object_id = azuread_group.groups["DTS Operations"].object_id
}