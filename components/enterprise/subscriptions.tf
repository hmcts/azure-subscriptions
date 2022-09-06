<<<<<<< HEAD
module "cft_non_production_subscriptions" {
  for_each = var.cft_non_production_subscriptions

  source = "../../modules/subscription"

  name        = each.key
  environment = each.value.env
  product     = var.product
  builtFrom   = var.builtFrom
  deploy_acme = local.deploy_acme
  acme_storage_account_repl_type = local.acme_storage_account_repl_type
=======
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
>>>>>>> main

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