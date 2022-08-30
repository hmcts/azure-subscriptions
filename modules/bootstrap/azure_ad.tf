resource "azuread_group" "group" {
  for_each = local.groups
  display_name            = each.key.name
  description             = each.key.description
  prevent_duplicate_names = true
  security_enabled        = true
}