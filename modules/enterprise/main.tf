resource "azurerm_management_group" "level_1" {
  for_each = local.azurerm_management_group_level_1

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"
  subscription_ids           = each.value.subscription_ids
}

module "level_1_bootstrap" {
  source = "../management-group-bootstrap"
  groups = local.azurerm_management_group_level_1

  depends_on = [azurerm_management_group.level_1]
}

resource "azurerm_management_group" "level_2" {
  for_each = local.azurerm_management_group_level_2

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"
  subscription_ids           = each.value.subscription_ids

  depends_on = [azurerm_management_group.level_1]

}

module "level_2_bootstrap" {
  source = "../management-group-bootstrap"
  groups = local.azurerm_management_group_level_2

  depends_on = [azurerm_management_group.level_2]
}

resource "azurerm_management_group" "level_3" {
  for_each = local.azurerm_management_group_level_3

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"
  subscription_ids           = each.value.subscription_ids

  depends_on = [azurerm_management_group.level_2]
}

module "level_3_bootstrap" {
  source = "../management-group-bootstrap"
  groups = local.azurerm_management_group_level_3

  depends_on = [azurerm_management_group.level_3]
}

resource "azurerm_management_group" "level_4" {
  for_each = local.azurerm_management_group_level_4

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"
  subscription_ids           = each.value.subscription_ids

  depends_on = [azurerm_management_group.level_3]
}

module "level_4_bootstrap" {
  source = "../management-group-bootstrap"
  groups = local.azurerm_management_group_level_4

  depends_on = [azurerm_management_group.level_4]
}

resource "azurerm_management_group" "level_5" {
  for_each = local.azurerm_management_group_level_5

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"
  subscription_ids           = each.value.subscription_ids

  depends_on = [azurerm_management_group.level_4]
}

module "level_5_bootstrap" {
  source = "../management-group-bootstrap"
  groups = local.azurerm_management_group_level_5

  depends_on = [azurerm_management_group.level_5]
}

resource "azurerm_management_group" "level_6" {
  for_each = local.azurerm_management_group_level_6

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"
  subscription_ids           = each.value.subscription_ids

  depends_on = [azurerm_management_group.level_5]
}

module "level_6_bootstrap" {
  source = "../management-group-bootstrap"
  groups = local.azurerm_management_group_level_6

  depends_on = [azurerm_management_group.level_6]
}