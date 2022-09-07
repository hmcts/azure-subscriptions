resource "azuread_group" "groups" {
  for_each                = local.groups
  display_name            = each.value.name
  description             = each.value.description
  prevent_duplicate_names = false # to be changed, set to false to ensure successful plan before state migration
  security_enabled        = true

  members = each.value.members
}