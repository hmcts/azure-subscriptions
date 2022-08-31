resource "azuredevops_serviceendpoint_azurerm" "endpointazure" {
  project_id            = "PlatformOperations"
  service_endpoint_name = var.subscription_name
  credentials {
    serviceprincipalid  = azuread_service_principal.sp.application_id
    serviceprincipalkey = azuread_application_password.token.value
  }
  azurerm_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id   = var.subscription_id
  azurerm_subscription_name = var.subscription_name
}