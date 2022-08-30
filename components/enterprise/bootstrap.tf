module "bootstrap" {
  for_each = toset(var.cft_non_production_subscriptions)

  source = "../../modules/bootstrap"

  storage_account_name = join("", ["c", substr(replace(each.value, "-", ""), 0, 8), substr(replace(each.value, "-", ""), 24, 12), "sa"])
  resource_group_name  = join("-", ["azure-control", var.env, "rg"])
  tags                 = module.tags.common_tags
}
