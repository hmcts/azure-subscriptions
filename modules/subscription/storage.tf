resource "azurerm_storage_account" "sa" {
  name                     = join("", ["c", substr(replace(azurerm_subscription.this.subscription_id, "-", ""), 0, 8), substr(replace(azurerm_subscription.this.subscription_id, "-", ""), 24, 12), "sa"])
  resource_group_name      = join("-", ["azure-control", var.environment, "rg"])
  location                 = var.location
  account_tier             = var.account_tier
  account_kind             = var.account_kind
  account_replication_type = var.replication_type
  tags                     = var.common_tags
}

resource "azurerm_storage_container" "sc" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = var.access_type
}