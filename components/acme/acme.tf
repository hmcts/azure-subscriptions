module "acme" {
  for_each = { for k, v in local.subscriptions : k => v if try(v.deploy_acme, false) }

  source = "git::https://github.com/hmcts/terraform-module-acme-function.git?ref=DTSPO-9746/acme-kv"

  location                       = var.location
  env                            = try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))
  common_tags                    = module.tags[each.key].common_tags
  platform_operations_object_id  = "e7ea2042-4ced-45dd-8ae3-e051c6551789"
  dns_contributor_group_id       = "6c2d130e-ba66-408a-bdf9-f426a9730923"
  product                        = var.product
  subscription_id                = [for elem in data.azurerm_subscriptions.subscription.subscriptions[*] : elem.subscription_id if elem.display_name == each.key]
  acme_storage_account_repl_type = "ZRS"
}

module "tags" {
  for_each    = local.subscriptions
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))
  product     = try(each.value.product, replace(regex("cft_|sds_", [each.value.group][0]), local.regex_first_section_underscore, "$1-platform"), replace(regex("security", [each.value.group][0]), local.regex_string, "soc"), replace([each.value.group][0], local.regex_first_section_underscore, "$1"))
  builtFrom   = var.builtFrom
}