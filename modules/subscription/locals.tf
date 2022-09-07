locals {
  app_name = join(" ", ["DTS Bootstrap", join("", ["(", join(":", ["sub", azurerm_subscription.this.subscription_name]), ")"])])
  # env      = var.value.environment == "sandbox" ? "sbox" : var.value.environment
  groups = {
    "Azure Kubernetes Service Cluster Admin Role" = {
      name        = join(" ", ["DTS AKS Administrators", join("", ["(", join(":", ["sub", azurerm_subscription.this.subscription_name]), ")"])]),
      description = "Grants aks cluster admin permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = [data.azuread_group.aks_global_admin.id]
    }
    "Azure Kubernetes Service Cluster User Role" = {
      name        = join(" ", ["DTS AKS Users", join("", ["(", join(":", ["sub", azurerm_subscription.this.subscription_name]), ")"])]),
      description = "Grants aks cluster user permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = []
    }
    "Contributor" = {
      name        = join(" ", ["DTS Contributors", join("", ["(", join(":", ["sub", azurerm_subscription.this.subscription_name]), ")"])]),
      description = "Grants contributor permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = [var.dts_operations_group_id, azuread_service_principal.sp.object_id]
    }
    "Key Vault Administrator" = {
      name        = join(" ", ["DTS Key Vault Administrators", join("", ["(", join(":", ["sub", azurerm_subscription.this.subscription_name]), ")"])]),
      description = "Grants key vault administrator permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = [var.dts_operations_group_id, azuread_service_principal.sp.object_id]
    }
    "Reader" = {
      name        = join(" ", ["DTS Readers", join("", ["(", join(":", ["sub", azurerm_subscription.this.subscription_name]), ")"])]),
      description = "Grants reader permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = [data.azuread_group.ops_mgmt.object_id]
    }
    "Security Reader" = {
      name        = join(" ", ["DTS Security Readers", join("", ["(", join(":", ["sub", azurerm_subscription.this.subscription_name]), ")"])]),
      description = "Grants security reader permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = []
    }
    "Storage Blob Data Reader" = {
      name        = join(" ", ["DTS Blob Readers", join("", ["(", join(":", ["sub", azurerm_subscription.this.subscription_name]), ")"])]),
      description = "Grants storage blob data contributor permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = []
    }
    "Owner" = {
      name        = join(" ", ["DTS Owners", join("", ["(", join(":", ["sub", azurerm_subscription.this.subscription_name]), ")"])]),
      description = "Grants owner permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = [azuread_service_principal.sp.object_id]
    }
  }
  role_assignments = {
    "Key Vault Contributor" = {
      principal_id = azuread_group.groups["Contributor"].id
      scope        = azurerm_key_vault.kv.id
    }
    "Monitoring Contributor" = {
      principal_id = data.azuread_group.ops_mgmt.object_id
      scope        = "/subscriptions/${azurerm_subscription.this.subscription_id}"
    }
    "Network Contributor" = {
      principal_id = data.azuread_group.ops_mgmt.object_id
      scope        = "/subscriptions/${azurerm_subscription.this.subscription_id}"
    }
    "Storage Account Contributor" = {
      principal_id = azuread_group.groups["Contributor"].id
      scope        = azurerm_storage_account.sa.id
    }
    "Storage Blob Data Contributor" = {
      principal_id = azuread_group.groups["Contributor"].id
      scope        = azurerm_storage_account.sa.id
    }
    "User Access Administrator" = {
      principal_id = var.dts_operations_group_id
      scope        = "/subscriptions/${azurerm_subscription.this.subscription_id}"
    }
  }
}