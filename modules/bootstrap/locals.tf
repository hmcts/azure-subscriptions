locals {
  app_name = join(" ", ["DTS Bootstrap", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])])
  env      = var.env == "sandbox" ? "sbox" : var.env
  groups = {
    "Contributor" = {
      name        = join(" ", ["DTS Contributors", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants contributor permissions to the ${var.subscription_name} subscription"
      members     = [data.azuread_group.ops_env.object_id, azuread_service_principal.sp.object_id]
    }
    "Key Vault Administrator" = {
      name        = join(" ", ["DTS Key Vault Administrators", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants key vault administrator permissions to the ${var.subscription_name} subscription"
      members     = [data.azuread_group.ops_env.object_id, azuread_service_principal.sp.object_id]
    }
    "Reader" = {
      name        = join(" ", ["DTS Readers", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants reader permissions to the ${var.subscription_name} subscription"
      members     = [data.azuread_group.ops_mgmt.object_id]
    }
    "Security Reader" = {
      name        = join(" ", ["DTS Security Readers", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants security reader permissions to the ${var.subscription_name} subscription"
    }
    "Storage Blob Data Reader" = {
      name        = join(" ", ["DTS Blob Readers", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants storage blob data contributor permissions to the ${var.subscription_name} subscription"
    }
    "Owner" = {
      name        = join(" ", ["DTS Owners", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants owner permissions to the ${var.subscription_name} subscription"
      members     = [azuread_service_principal.sp.object_id]
    }
  }
  role_assignments = {
    "Key Vault Contributor" = {
      principal_id = azuread_group.group["Contributor"].id
      scope        = azurerm_key_vault.kv.id
    }
    "Monitoring Contributor" = {
      principal_id = data.azuread_group.ops_mgmt.object_id
      scope        = "/subscriptions/${var.subscription_id}"
    }
    "Network Contributor" = {
      principal_id = data.azuread_group.ops_mgmt.object_id
      scope        = "/subscriptions/${var.subscription_id}"
    }
    "Storage Account Contributor" = {
      principal_id = azuread_group.group["Contributor"].id
      scope        = azurerm_storage_account.sa.id
    }
    "Storage Blob Data Contributor" = {
      principal_id = azuread_group.group["Contributor"].id
      scope        = azurerm_storage_account.sa.id
    }
    "User Access Administrator" = {
      principal_id = data.azuread_group.ops_env.object_id
      scope        = "/subscriptions/${var.subscription_id}"
    }
  }
}