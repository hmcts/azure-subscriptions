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
  environment             = try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))
  billing_account_name    = var.billing_account_name
  enrollment_account_name = "323609"
  deploy_acme             = try(each.value.deploy_acme, false)
}

# module "tags" {
#   for_each     = local.subscriptions
#   source       = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
#   environment  = try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))
#   product      = var.product
#   builtFrom    = var.builtFrom
#   expiresAfter = var.expiresAfter
# }
