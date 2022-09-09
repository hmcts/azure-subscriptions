locals {
  vh = { for k, v in var.vh_subscriptions : k => merge(tomap({ group = "hmcts" }), v) }

  subscriptions = merge(
    local.vh,
  )
}

module "subscription" {
  for_each = local.subscriptions

  source = "../../modules/subscription"
  name   = each.key
  value  = each.value

  billing_account_name    = var.billing_account_name
  enrollment_account_name = "TODO"
}
