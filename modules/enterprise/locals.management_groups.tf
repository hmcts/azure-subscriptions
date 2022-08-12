locals {
  # TODO look at this which way we want to go
  strict_subscription_association = false

  # basically just adds the id to the map and allows us to make minor adjustments if we want to fields
  management_groups = {
    for key, value in var.management_groups :
    key => {
      id                         = key
      display_name               = value.display_name
      parent_management_group_id = value.parent_management_group_id
      subscription_ids           = local.strict_subscription_association ? value.subscription_ids : null
    }
  }

  azurerm_management_group_level_1 = {
    for key, value in local.management_groups :
    key => value
    if value.parent_management_group_id == var.root_parent_id
  }
  azurerm_management_group_level_2 = {
    for key, value in local.management_groups :
    key => value
    if contains(keys(azurerm_management_group.level_1), value.parent_management_group_id)
  }
  azurerm_management_group_level_3 = {
    for key, value in local.management_groups :
    key => value
    if contains(keys(azurerm_management_group.level_2), value.parent_management_group_id)
  }
  azurerm_management_group_level_4 = {
    for key, value in local.management_groups :
    key => value
    if contains(keys(azurerm_management_group.level_3), value.parent_management_group_id)
  }
  azurerm_management_group_level_5 = {
    for key, value in local.management_groups :
    key => value
    if contains(keys(azurerm_management_group.level_4), value.parent_management_group_id)
  }
  azurerm_management_group_level_6 = {
    for key, value in local.management_groups :
    key => value
    if contains(keys(azurerm_management_group.level_5), value.parent_management_group_id)
  }
}
