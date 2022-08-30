module "bootstrap" {
  for_each = toset(var.cft_non_production_subscriptions)

  source = "../../modules/bootstrap"
  name   = each.value

  storage_account_name = join("", ["c", each.value, "sa"])
  resource_group_name = join("-", ["azure-control", var.env, "rg"])
  env = "nonprod"
}
