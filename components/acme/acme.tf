module "acme" {
  for_each = { for k, v in local.subscriptions : k => v if try(v.deploy_acme, false) }

  source = "git::https://github.com/hmcts/terraform-module-acme-function.git?ref=master"

  location                       = var.location
  env                            = try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))
  common_tags                    = module.tags[each.key].common_tags
  dns_contributor_group_id       = module.environment[try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))].dns_contributor_group_id
  product                        = var.product
  resource_group_name            = module.environment[try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))].resource_group_name
  resource_group_id              = module.environment[try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))].resource_group_id
  asp_id                         = module.environment[try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))].asp_id
  subscription_id                = module.subscription[each.key].subscription_id.subscription_id
  acme_storage_account_repl_type = try(each.value.acme_storage_account_repl_type, "ZRS")
}