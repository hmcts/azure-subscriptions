module "subscriptions" {

  source        = "../../modules/subscription"
  subscriptions = var.subscriptions

  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}