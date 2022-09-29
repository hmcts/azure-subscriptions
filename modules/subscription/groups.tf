resource "azuread_group" "groups" {
  for_each                = local.groups
  display_name            = each.value.name
  description             = each.value.description
  prevent_duplicate_names = true
  security_enabled        = true
}

resource "azuread_group_member" "members" {
  for_each         = local.groups
  group_object_id  = azuread_group.groups[each.key].object_id
  member_object_id = each.value.members
}