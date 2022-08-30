data "azurerm_billing_enrollment_account_scope" "this" {
  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}

resource "azurerm_subscription" "this" {
  subscription_name = var.name
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.this.id
}

output "subscription_name" {
  value = azurerm_subscription.this.subscription_name
}
