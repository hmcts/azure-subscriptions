module "subscription" {
  for_each = local.subscriptions

  source      = "../../modules/subscription"
  name        = each.key
  value       = each.value
  common_tags = module.tags[each.key].common_tags

  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}

module "acme" {
  for_each = { for k, v in local.subscriptions : k => v if try(v.deploy_acme, false) == true }

  source = "git::https://github.com/hmcts/terraform-module-acme-function.git?ref=DTSPO-9743/ops-bootstrap"

  location                       = var.location
  env                            = each.value.environment
  common_tags                    = module.tags[each.key].common_tags
  product                        = var.product
  resource_group_name            = module.environment[each.value.environment].resource_group_name
  resource_group_id              = module.environment[each.value.environment].resource_group_id
  asp_id                         = module.environment[each.value.environment].asp_id
  subscription_id                = module.subscription[each.key].subscription_id.subscription_id
  acme_storage_account_repl_type = try(each.value.acme_storage_account_repl_type, "ZRS")
}

module "tags" {
  for_each    = local.subscriptions
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=DTSPO-9743/azure-enterprise"
  environment = each.value.environment
  product     = var.product
  builtFrom   = var.builtFrom
}