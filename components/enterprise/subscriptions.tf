module "tags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=DTSPO-9743/azure-enterprise"
  environment = var.env
  product     = var.product
  builtFrom   = var.builtFrom
}

module "cft_non_production_subscriptions" {
  for_each = toset(var.cft_non_production_subscriptions)

  source = "../../modules/subscription"

  name                = each.value
  resource_group_name = join("-", ["azure-control", var.env, "rg"])
  tags                = module.tags.common_tags
  env                 = var.env

  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}