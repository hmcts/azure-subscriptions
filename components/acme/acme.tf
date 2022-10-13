module "acme" {
  for_each = { for k, v in local.subscriptions : k => v if k == data.azurerm_subscription.current.display_name && try(v.deploy_acme, false) }
  source = "git::https://github.com/hmcts/terraform-module-acme-function.git?ref=DTSPO-9746/acme-kv"

  providers = { 
    azurerm = azurerm[each.key]
  }

  location                       = var.location
  env                            = try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))
  common_tags                    = module.tags[each.key].common_tags
  product                        = var.product
  subscription_id                = data.azurerm_client_config.current.subscription_id
  acme_storage_account_repl_type = "ZRS"
}

module "tags" {
  for_each    = local.subscriptions
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = try(each.value.environment, lower(replace([each.key][0], local.regex_last_section_hyphen, "$1")))
  product     = try(each.value.product, replace(regex("cft_|sds_", [each.value.group][0]), local.regex_first_section_underscore, "$1-platform"), replace(regex("security", [each.value.group][0]), local.regex_string, "soc"), replace([each.value.group][0], local.regex_first_section_underscore, "$1"))
  builtFrom   = var.builtFrom
}