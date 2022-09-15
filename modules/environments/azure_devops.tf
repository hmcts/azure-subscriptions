# resource "azuredevops_project" "PlatformOperations" {
#   name               = "PlatformOperations"
#   visibility         = "private"
#   work_item_template = "Agile"
#   description        = "The Platform Operations team provides the creation, support, maintenance and enhancement of our Platform services and associated pipelines, with a focus on automation and self-service.  This enables project development and enduring product teams to deliver quality digital products rapidly, supporting the business as well as supporting and enhancing live services to citizens and internal staff."
#   features = {
#     "artifacts" = "disabled"
#     "boards"    = "enabled"
#     "pipelines" = "enabled"
#     "repositories"     = "disabled"
#     "testplans" = "disabled"
#   }
# }

resource "azuredevops_serviceendpoint_azurerm" "endpoint" {
  count                 = var.pipeline_environment == "prod" ? 1 : 0
  project_id            = var.project_id
  service_endpoint_name = "OPS-APPROVAL-GATE-${upper(var.env)}-ENVS"
  credentials {
    serviceprincipalid  = azuread_service_principal.sp.application_id
    serviceprincipalkey = azuread_application_password.token.value
  }
  azurerm_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id   = var.env == "ptl" ? data.azurerm_subscriptions.service_endpoint_subscription[0].subscriptions[1].subscription_id : data.azurerm_subscriptions.service_endpoint_subscription[0].subscriptions[0].subscription_id
  azurerm_subscription_name = var.env == "ptl" ? data.azurerm_subscriptions.service_endpoint_subscription[0].subscriptions[1].display_name : data.azurerm_subscriptions.service_endpoint_subscription[0].subscriptions[0].display_name
}
