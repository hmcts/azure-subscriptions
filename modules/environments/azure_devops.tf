resource "azuredevops_serviceendpoint_azurerm" "endpoint" {
  count                 = length(data.azurerm_subscriptions.sds.subscriptions[0].subscription_id) == 0 ? 0 : 1
  project_id            = "PlatformOperations"
  service_endpoint_name = "OPS-APPROVAL-GATE-${upper(var.env)}-ENVS"
  credentials {
    serviceprincipalid  = azuread_service_principal.sp.application_id
    serviceprincipalkey = azuread_application_password.token.value
  }
  azurerm_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscriptions.sds.subscriptions[0].subscription_id
  azurerm_subscription_name = data.azurerm_subscriptions.sds.subscriptions[0].display_name
}