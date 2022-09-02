data "azurerm_billing_enrollment_account_scope" "this" {
  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}

resource "azurerm_subscription" "this" {
  for_each = { for subscription in var.subscriptions :
    subscription.name => subscription
  }
  subscription_name = each.value.name
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.this.id
}

output "subscription_id" {
  value = values(azurerm_subscription.this).*.subscription_id
}

output "subscription_name" {
  value = values(azurerm_subscription.this).*.subscription_name
}
