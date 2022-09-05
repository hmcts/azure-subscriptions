data "azurerm_billing_enrollment_account_scope" "this" {
  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
}

resource "azurerm_subscription" "this" {
  alias             = var.name
  subscription_name = try(var.value.display_name, var.name)
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.this.id
}

output "subscription_id" {
  value = {
    group           = var.value.group
    subscription_id = azurerm_subscription.this.subscription_id
  }
}
