locals {
  app_name = "DTS Bootstrap (sub:${azurerm_subscription.this.subscription_name})"
  groups = {
    "Azure Kubernetes Service Cluster Admin Role" = {
      name        = "DTS AKS Administrators (sub:${azurerm_subscription.this.subscription_name})"
      description = "Grants aks cluster admin permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = [data.azuread_group.aks_global_admin.id]
    }
    "Azure Kubernetes Service Cluster User Role" = {
      name        = "DTS AKS Users (sub:${azurerm_subscription.this.subscription_name})"
      description = "Grants aks cluster user permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = []
    }
    "Contributor" = {
      name        = "DTS Contributors (sub:${azurerm_subscription.this.subscription_name})"
      description = "Grants contributor permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = [data.azuread_group.dts_operations.object_id, azuread_service_principal.sp.object_id]
    }
    "Key Vault Administrator" = {
      name        = "DTS Key Vault Administrators (sub:${azurerm_subscription.this.subscription_name})"
      description = "Grants key vault administrator permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = [data.azuread_group.dts_operations.object_id, azuread_service_principal.sp.object_id]
    }
    "Reader" = {
      name        = "DTS Readers (sub:${azurerm_subscription.this.subscription_name})"
      description = "Grants reader permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = [data.azuread_group.ops_mgmt.object_id]
    }
    "Security Reader" = {
      name        = "DTS Security Readers (sub:${azurerm_subscription.this.subscription_name})"
      description = "Grants security reader permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = []
    }
    "Storage Blob Data Reader" = {
      name        = "DTS Blob Readers (sub:${azurerm_subscription.this.subscription_name})"
      description = "Grants storage blob data contributor permissions to the ${azurerm_subscription.this.subscription_name} subscription"
      members     = []
    }
    "Owner" = {
      name        = "DTS Owners (sub:${azurerm_subscription.this.subscription_name})"
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
      principal_id = data.azuread_group.dts_operations.object_id
      scope        = "/subscriptions/${azurerm_subscription.this.subscription_id}"
    }
  }
}