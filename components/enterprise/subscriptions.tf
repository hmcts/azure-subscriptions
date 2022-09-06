module "cft_non_production_subscriptions" {
  for_each = var.cft_non_production_subscriptions

  source = "../../modules/subscription"

  name        = each.key
  environment = each.value.env
  product     = var.product
  builtFrom   = var.builtFrom
  deploy_acme = local.deploy_acme
  acme_storage_account_repl_type = local.acme_storage_account_repl_type

  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}

module "cft_sandbox_subscriptions" {
  for_each = var.cft_sandbox_subscriptions

  source = "../../modules/subscription"

  name        = each.key
  environment = each.value.env
  product     = var.product
  builtFrom   = var.builtFrom
  deploy_acme = local.deploy_acme
  acme_storage_account_repl_type = local.acme_storage_account_repl_type

  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}