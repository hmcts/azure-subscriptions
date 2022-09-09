locals {
  cft = { for k, v in var.cft_subscriptions : k => merge(tomap({ group = "cft" }), v) }

  subscriptions = merge(
    local.cft,
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
