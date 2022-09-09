locals {
  vh = { for k, v in var.vh_subscriptions : k => merge(tomap({ group = "hmcts" }), v) }

  subscriptions = merge(
    local.vh,
  )
}

module "subscription" {
  for_each = local.subscriptions

  source                  = "../../modules/subscription"
  name                    = each.key
  value                   = each.value
  common_tags             = module.tags[each.key].common_tags
  environment             = try(each.value.environment, (lower(replace([each.key][0], "/.*-([A-Za-z]+).*/", "$1"))))
  billing_account_name    = var.billing_account_name
  enrollment_account_name = "TODO"
}

module "tags" {
  for_each    = local.subscriptions
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=DTSPO-9743/azure-enterprise"
  environment = try(each.value.environment, (lower(replace([each.key][0], "/.*-([A-Za-z]+).*/", "$1"))))
  product     = var.product
  builtFrom   = var.builtFrom
}
