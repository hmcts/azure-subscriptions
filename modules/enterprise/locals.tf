# The following locals are used to define base Azure
# provider paths and resource types
locals {
  provider_path = {
    management_groups = "/providers/Microsoft.Management/managementGroups/"
  }

  custom_roles = {
    "Application Gateway Backend Health Reader" = {
      scope       = "/providers/Microsoft.Management/managementGroups/HMCTS"
    },
  }
}
