resource "azuredevops_serviceendpoint_azurerm" "endpoint" {
  project_id            = var.project_id
  service_endpoint_name = azurerm_subscription.this.subscription_name
  credentials {
    serviceprincipalid  = azuread_service_principal.sp.client_id
    serviceprincipalkey = azuread_application_password.token.value
  }
  azurerm_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id   = azurerm_subscription.this.subscription_id
  azurerm_subscription_name = azurerm_subscription.this.subscription_name
}
