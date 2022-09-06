locals {
  cft_non_production = { for k, v in var.cft_non_production_subscriptions : k => merge(tomap({ group = "cft_non_production" }), v) }
  cft_sandbox        = { for k, v in var.cft_sandbox_subscriptions : k => merge(tomap({ group = "cft_sandbox" }), v) }

  subscriptions = merge(
    local.cft_sandbox,
    local.cft_non_production
  )
}

module "subscription" {
  for_each = local.subscriptions

  source                         = "../../modules/subscription"
  name                           = each.key
  value                          = each.value
  environment                    = each.value.environment
  common_tags = module.tags.common_tags[each.key]

  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}

module "acme" {
  for_each = local.subscriptions
  source = "git::https://github.com/hmcts/terraform-module-acme-function.git?ref=DTSPO-9743/ops-bootstrap"

  location                       = var.location
  env                            = each.value.environment
  dns_contributor_group_id       = data.azuread_group.dns_contributor.id
  common_tags                    = module.tags.common_tags[each.key]
  product                        = var.product
  subscription_id                = module.subscription[each.key].subscription_id
  acme_storage_account_repl_type = var.acme_storage_account_repl_type
}

module "tags" {
  for_each = local.subscriptions
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=DTSPO-9743/azure-enterprise"
  environment = each.value.environment
  product     = var.product
  builtFrom   = var.builtFrom
}