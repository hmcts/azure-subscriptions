resource "azurerm_role_definition" "app_gateway_backend_health_reader" {
  name        = "Application Gateway Backend Health Reader"
  description = "View backend health on the Application Gateway"
  scope       = "/providers/Microsoft.Management/managementGroups/HMCTS"
  permissions {
    actions = ["Microsoft.Network/applicationGateways/backendhealth/action"]
  }
}