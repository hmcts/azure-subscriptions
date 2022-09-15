resource "azurerm_service_plan" "asp" {
  location            = var.location
  name                = "${var.product}-${var.env}-asp"
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"
  reserved            = false
  os_type             = "Windows"
  sku {
    size = var.asp_sku_size
    tier = var.asp_sku_tier
  }
  tags = var.common_tags
}
