resource "azurerm_storage_account" "sa" {
  name                            = "c${substr(replace(azurerm_subscription.this.subscription_id, "-", ""), 0, 8)}${substr(replace(azurerm_subscription.this.subscription_id, "-", ""), 20, 32)}sa"
  resource_group_name             = "azure-control-${var.environment}-rg"
  location                        = var.location
  account_tier                    = var.account_tier
  account_kind                    = var.account_kind
  account_replication_type        = var.replication_type
  tags                            = var.common_tags
  allow_nested_items_to_be_public = false
  blob_properties {
    versioning_enabled = var.versioning_enabled
    delete_retention_policy {
      days = 30
    }
  }
}

resource "azurerm_storage_container" "sc" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = var.access_type
}
