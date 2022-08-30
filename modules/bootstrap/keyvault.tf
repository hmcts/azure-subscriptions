resource "azurerm_key_vault" "kv" {
    name = "${var.name}kv"
    location = var.location
    resource_group_name = var.resource_group_name
    tenant_id = data.azurerm_client_config.current.tenant_id
    purge_protection_enabled = var.purge_protection_enabled
    sku_name = var.sku_name
    tags = var.tags
}