module "acme" {
  count  = var.deploy_acme ? 1 : 0
  source = "git::https://github.com/hmcts/terraform-module-acme-function.git?ref=DTSPO-9743/ops-bootstrap"

  location                       = var.location
  env                            = lower(var.environment)
  dns_contributor_group_id       = data.azuread_group.dns_contributor.id
  common_tags                    = module.tags.common_tags
  product                        = var.product
  subscription_id                = azurerm_subscription.this.subscription_id
  acme_storage_account_repl_type = var.acme_storage_account_repl_type
}