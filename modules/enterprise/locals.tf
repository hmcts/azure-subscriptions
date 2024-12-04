# The following locals are used to define base Azure
# provider paths and resource types
locals {
  provider_path = {
    management_groups = "/providers/Microsoft.Management/managementGroups/"
  }

  custom_roles = {
    "Application Gateway Backend Health Reader" = {
      description = "View backend health on the Application Gateway"
      scope       = "/providers/Microsoft.Management/managementGroups/HMCTS"
      actions     = ["Microsoft.Network/applicationGateways/backendhealth/action"]
    },
  }
}
