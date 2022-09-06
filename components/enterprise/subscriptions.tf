locals {
  cft                = { for k, v in var.cft_subscriptions : k => merge(tomap({ group = "cft" }), v) }
  cft_sandbox        = { for k, v in var.cft_sandbox_subscriptions : k => merge(tomap({ group = "cft_sandbox" }), v) }
  cft_non_production = { for k, v in var.cft_non_production_subscriptions : k => merge(tomap({ group = "cft_non_production" }), v) }
  cft_production     = { for k, v in var.cft_production_subscriptions : k => merge(tomap({ group = "cft_production" }), v) }

  sds                = { for k, v in var.sds_subscriptions : k => merge(tomap({ group = "sds" }), v) }
  sds_sandbox        = { for k, v in var.sds_sandbox_subscriptions : k => merge(tomap({ group = "sds_sandbox" }), v) }
  sds_non_production = { for k, v in var.sds_non_production_subscriptions : k => merge(tomap({ group = "sds_non_production" }), v) }
  sds_production     = { for k, v in var.sds_production_subscriptions : k => merge(tomap({ group = "sds_production" }), v) }

  crime = { for k, v in var.crime_subscriptions : k => merge(tomap({ group = "crime" }), v) }

  heritage                = { for k, v in var.heritage_subscriptions : k => merge(tomap({ group = "heritage" }), v) }
  heritage_sandbox        = { for k, v in var.heritage_sandbox_subscriptions : k => merge(tomap({ group = "heritage_sandbox" }), v) }
  heritage_non_production = { for k, v in var.heritage_non_production_subscriptions : k => merge(tomap({ group = "heritage_non_production" }), v) }
  heritage_production     = { for k, v in var.heritage_production_subscriptions : k => merge(tomap({ group = "heritage_production" }), v) }

  security = { for k, v in var.security_subscriptions : k => merge(tomap({ group = "security" }), v) }

  platform                = { for k, v in var.platform_subscriptions : k => merge(tomap({ group = "platform" }), v) }
  platform_sandbox        = { for k, v in var.platform_sandbox_subscriptions : k => merge(tomap({ group = "platform_sandbox" }), v) }
  platform_non_production = { for k, v in var.platform_non_production_subscriptions : k => merge(tomap({ group = "platform_non_production" }), v) }
  platform_production     = { for k, v in var.platform_production_subscriptions : k => merge(tomap({ group = "platform_production" }), v) }

  subscriptions = merge(
    local.cft,
    local.cft_sandbox,
    local.cft_non_production,
    local.cft_production,

    local.sds,
    local.sds_sandbox,
    local.sds_non_production,
    local.sds_production,

    local.crime,

    local.heritage,
    local.heritage_sandbox,
    local.heritage_non_production,
    local.heritage_production,

    local.security,

    local.platform,
    local.platform_sandbox,
    local.platform_non_production,
    local.platform_production,
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