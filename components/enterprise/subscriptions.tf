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

  source = "../../modules/subscription"
  name   = each.key
  value  = each.value

  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}
