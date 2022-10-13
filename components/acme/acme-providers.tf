data "azurerm_subscriptions" "dcd_cft_sandbox"{
    display_name_prefix = "DCD-CFT-Sandbox"
}

provider "azurerm" {
  alias = "DCD-CFT-Sandbox"
  subscription_id = data.azurerm_subscriptions.dcd_cft_sandbox.id
}