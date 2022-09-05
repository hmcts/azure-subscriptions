resource "azurerm_key_vault" "kv" {
  name                     = join("", ["c", substr(replace(azurerm_subscription.this.subscription_id, "-", ""), 0, 8), substr(replace(azurerm_subscription.this.subscription_id, "-", ""), 24, 12), "kv"])
  location                 = var.location
  resource_group_name      = join("-", ["azure-control", var.environment, "rg"])
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = var.purge_protection_enabled
  sku_name                 = var.sku_name
  tags                     = module.tags.common_tags
}

resource "azurerm_key_vault_access_policy" "permissions" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_group.group["Contributor"].id
  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update"
  ]
  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey"
  ]
  secret_permissions = [
    "Get",
    "Set",
    "List",
    "Delete",
    "Restore",
    "Recover",
    "Backup"
  ]
  storage_permissions = [
    "Backup",
    "Delete",
    "DeleteSAS",
    "Get",
    "GetSAS",
    "List",
    "ListSAS",
    "Recover",
    "RegenerateKey",
    "Restore",
    "Set",
    "SetSAS",
    "Update"
  ]
}

resource "azurerm_key_vault_secret" "sp_object_id" {
  name         = "sp-object-id"
  value        = azuread_service_principal.sp.object_id
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "sp_app_id" {
  name         = "sp-application-id"
  value        = azuread_application.app.application_id
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "sp_token" {
  name         = "sp-token"
  value        = azuread_application_password.token.value
  key_vault_id = azurerm_key_vault.kv.id
}