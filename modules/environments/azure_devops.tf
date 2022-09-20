resource "azuredevops_serviceendpoint_azurerm" "endpoint" {
  count                 = var.pipeline_environment == "prod" ? 1 : 0
  project_id            = var.project_id
  service_endpoint_name = "OPS-APPROVAL-GATE-${upper(var.env)}-ENVS"
  credentials {
    serviceprincipalid  = azuread_service_principal.sp.application_id
    serviceprincipalkey = azuread_application_password.token.value
  }
  azurerm_spn_tenantid      = data.azurerm_client_config.current.tenant_id

  # current data resource only supports searching for subscriptions by prefix and not for an exact match which creates issues when multiple subscriptions contain the same string e.g. `DTS-SHAREDSERIVCESPTL` and `DTS-SHAREDSERVICESPTL-SBOX`. See https://github.com/hashicorp/terraform-provider-azurerm/issues/18462
  azurerm_subscription_id   = var.env == "ptl" ? data.azurerm_subscriptions.service_endpoint_subscription[0].subscriptions[1].subscription_id : data.azurerm_subscriptions.service_endpoint_subscription[0].subscriptions[0].subscription_id
  azurerm_subscription_name = var.env == "ptl" ? data.azurerm_subscriptions.service_endpoint_subscription[0].subscriptions[1].display_name : data.azurerm_subscriptions.service_endpoint_subscription[0].subscriptions[0].display_name
}
