module "tags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=DTSPO-9743/azure-enterprise"
  environment = var.env
  product     = var.product
  builtFrom   = var.builtFrom
}

module "bootstrap" {
  for_each = toset(var.cft_non_production_subscriptions)

  source = "../../modules/bootstrap"

  resource_group_name  = join("-", ["azure-control", var.env, "rg"])
  tags                 = module.tags.common_tags
}
