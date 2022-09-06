resource "azuread_group" "groups" {
  for_each                = local.groups
  display_name            = each.value.name
  description             = each.value.description
  prevent_duplicate_names = true
  security_enabled        = true

  members = each.value.members
}

# resource "azuread_group_member" "acr" {
#   group_object_id  = data.azuread_group.acr.object_id
#   member_object_id = azuread_group.groups["DTS Operations"].object_id
# }