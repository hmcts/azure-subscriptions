module "enterprise" {
  source = "../../modules/enterprise"

  root_id        = var.root_id
  root_name      = var.root_name
  root_parent_id = data.azurerm_client_config.core.tenant_id

  management_groups = {
    HMCTS = {
      display_name               = "HMCTS Programmes"
      parent_management_group_id = data.azurerm_client_config.core.tenant_id
      subscription_ids           = []
    }

    # CFT
    CFT = {
      display_name               = "CFT"
      parent_management_group_id = "HMCTS"
      subscription_ids           = var.cft_subscriptions
    }
    CFT-Sandbox = {
      display_name               = "CFT - Sandbox"
      parent_management_group_id = "CFT"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "cft_sandbox"]
    }
    CFT-NonProd = {
      display_name               = "CFT - Non-production"
      parent_management_group_id = "CFT"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "cft_non_production"]
    }
    CFT-Prod = {
      display_name               = "CFT - Production"
      parent_management_group_id = "CFT"
      subscription_ids           = var.cft_production_subscriptions
    }

    # SDS
    SDS = {
      display_name               = "SDS"
      parent_management_group_id = "HMCTS"
      subscription_ids           = var.sds_subscriptions
    }
    SDS-Sandbox = {
      display_name               = "SDS - Sandbox"
      parent_management_group_id = "SDS"
      subscription_ids           = var.sds_sandbox_subscriptions
    }
    SDS-NonProd = {
      display_name               = "SDS - Non-production"
      parent_management_group_id = "SDS"
      subscription_ids           = var.sds_non_production_subscriptions
    }
    SDS-Prod = {
      display_name               = "SDS - Production"
      parent_management_group_id = "SDS"
      subscription_ids           = var.sds_production_subscriptions
    }

    # Crime
    Crime = {
      display_name               = "Crime"
      parent_management_group_id = "HMCTS"
      subscription_ids           = var.crime_subscriptions
    }

    # Heritage
    Heritage = {
      display_name               = "Heritage"
      parent_management_group_id = "HMCTS"
      subscription_ids           = var.heritage_subscriptions
    }
    Heritage-Sandbox = {
      display_name               = "Heritage - Sandbox"
      parent_management_group_id = "Heritage"
      subscription_ids           = var.heritage_sandbox_subscriptions
    }
    Heritage-NonProd = {
      display_name               = "Heritage - Non-production"
      parent_management_group_id = "Heritage"
      subscription_ids           = var.heritage_non_production_subscriptions
    }
    Heritage-Prod = {
      display_name               = "Heritage - Production"
      parent_management_group_id = "Heritage"
      subscription_ids           = var.heritage_production_subscriptions
    }

    # Security
    Security = {
      display_name               = "Security"
      parent_management_group_id = "HMCTS"
      subscription_ids           = var.security_subscriptions
    }

    # Platform
    Platform = {
      display_name               = "Platform"
      parent_management_group_id = "HMCTS"
      subscription_ids           = var.platform_subscriptions
    }
    Platform-Sandbox = {
      display_name               = "Platform - Sandbox"
      parent_management_group_id = "Platform"
      subscription_ids           = var.platform_sandbox_subscriptions
    }
    Platform-NonProd = {
      display_name               = "Platform - Non-production"
      parent_management_group_id = "Platform"
      subscription_ids           = var.platform_non_production_subscriptions
    }
    Platform-Prod = {
      display_name               = "Platform - Production"
      parent_management_group_id = "Platform"
      subscription_ids           = var.platform_production_subscriptions
    }
  }
}
