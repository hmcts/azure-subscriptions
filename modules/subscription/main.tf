data "azurerm_billing_enrollment_account_scope" "this" {
  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}

resource "azurerm_subscription" "this" {
  subscription_name = var.name
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.this.id
}

output "subscription_id" {
  value = azurerm_subscription.this.subscription_id
}

output "subscription_name" {
  value = azurerm_subscription.this.subscription_name
}

module "tags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=DTSPO-9743/azure-enterprise"
  environment = var.environment
  product     = var.product
  builtFrom   = var.builtFrom
}
