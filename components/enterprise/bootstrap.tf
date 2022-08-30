module "tags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=DTSPO-9743/azure-enterprise"
  environment = var.env
  product     = var.product
  builtFrom   = var.builtFrom
}

module "bootstrap" {
  for_each = toset(var.cft_non_production_subscriptions)

  source = "../../modules/bootstrap"

  name                = join("", ["c", substr(replace(module.cft_non_production_subscriptions[each.value].subscription_id, "-", ""), 0, 8), substr(replace(module.cft_non_production_subscriptions[each.value].subscription_id, "-", ""), 24, 12)])
  resource_group_name = join("-", ["azure-control", var.env, "rg"])
  tags                = module.tags.common_tags
  subscription_name   = module.cft_non_production_subscriptions[each.value]
}
