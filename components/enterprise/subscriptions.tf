module "subscription" {
  for_each = local.subscriptions

  source      = "../../modules/subscription"
  name        = each.key
  value       = each.value
  common_tags = module.tags[each.key].common_tags
  environment = try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))

  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}

# module "acme" {
#   for_each = { for k, v in local.subscriptions : k => v if try(v.deploy_acme, false) }

#   source = "git::https://github.com/hmcts/terraform-module-acme-function.git?ref=master"

#   location                       = var.location
#   env                            = try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))
#   common_tags                    = module.tags[each.key].common_tags
#   dns_contributor_group_id       = module.environment[try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))].dns_contributor_group_id
#   product                        = var.product
#   resource_group_name            = module.environment[try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))].resource_group_name
#   resource_group_id              = module.environment[try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))].resource_group_id
#   asp_id                         = module.environment[try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))].asp_id
#   subscription_id                = module.subscription[each.key].subscription_id.subscription_id
#   acme_storage_account_repl_type = try(each.value.acme_storage_account_repl_type, "ZRS")
# }

module "tags" {
  for_each    = local.subscriptions
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))
  product     = try(each.value.product, replace(regex("cft_|sds_", [each.value.group][0]), local.regex_first_section_underscore, "$1-platform"), replace(regex("security", [each.value.group][0]), local.regex_string, "soc"), replace([each.value.group][0], local.regex_first_section_underscore, "$1"))
  builtFrom   = var.builtFrom
}
