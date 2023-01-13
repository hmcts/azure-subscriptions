resource "azurerm_role_definition" "custom_role_definitions" {
  for_each = local.custom_role_assignments

  name        = each.key
  description = each.value.description
  scope       = each.value.scope

  permissions {
    actions = each.value.actions
  }
}

locals {
  custom_role_assignments = {
    "Application Gateway Backend Health Reader" = {
      description = "View backend health on the Application Gateway"
      scope       = "/providers/Microsoft.Management/managementGroups/HMCTS"
      actions     = ["Microsoft.Network/applicationGateways/backendhealth/action"]
    },
  }
}