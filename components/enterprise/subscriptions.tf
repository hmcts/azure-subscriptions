module "cft_non_production_subscriptions" {
  for_each = toset(var.cft_non_production_subscriptions)

  source = "../../modules/subscription"
  name   = each.value

  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}
