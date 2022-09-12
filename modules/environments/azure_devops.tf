resource "azuredevops_serviceendpoint_azurerm" "endpoint" {
  count                 = var.pipeline_environment == "prod" && var.env != "ptl" ? 1 : 0
  project_id            = "PlatformOperations"
  service_endpoint_name = "OPS-APPROVAL-GATE-${upper(var.env)}-ENVS"
  credentials {
    serviceprincipalid  = azuread_service_principal.sp.application_id
    serviceprincipalkey = azuread_application_password.token.value
  }
  azurerm_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscriptions.sds[0].subscriptions[0].subscription_id
  azurerm_subscription_name = data.azurerm_subscriptions.sds[0].subscriptions[0].display_name
}

resource "azuredevops_serviceendpoint_azurerm" "endpoint_ptl" {
  count                 = var.pipeline_environment == "prod" && var.env == "ptl" ? 1 : 0
  project_id            = "PlatformOperations"
  service_endpoint_name = "OPS-APPROVAL-GATE-${upper(var.env)}-ENVS"
  credentials {
    serviceprincipalid  = azuread_service_principal.sp.application_id
    serviceprincipalkey = azuread_application_password.token.value
  }
  azurerm_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscriptions.sds[0].subscriptions[1].subscription_id
  azurerm_subscription_name = data.azurerm_subscriptions.sds[0].subscriptions[1].display_name
}
