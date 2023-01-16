module "enterprise" {
  source = "../../modules/enterprise"

  root_id        = var.root_id
  root_name      = var.root_name
  root_parent_id = data.azurerm_client_config.core.tenant_id

  custom_roles = module.enterprise.custom_roles

  management_groups = {
    HMCTS = {
      display_name               = "HMCTS"
      parent_management_group_id = data.azurerm_client_config.core.tenant_id
      subscription_ids           = []
    }

    # CFT
    CFT = {
      display_name               = "CFT"
      parent_management_group_id = "HMCTS"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "cft"]
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
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "cft_production"]
    }

    # SDS
    SDS = {
      display_name               = "SDS"
      parent_management_group_id = "HMCTS"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "sds"]
    }
    SDS-Sandbox = {
      display_name               = "SDS - Sandbox"
      parent_management_group_id = "SDS"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "sds_sandbox"]
    }
    SDS-NonProd = {
      display_name               = "SDS - Non-production"
      parent_management_group_id = "SDS"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "sds_non_production"]
    }
    SDS-Prod = {
      display_name               = "SDS - Production"
      parent_management_group_id = "SDS"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "sds_production"]
    }

    # Crime
    Crime = {
      display_name               = "Crime"
      parent_management_group_id = "HMCTS"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "crime"]
    }

    # Heritage
    Heritage = {
      display_name               = "Heritage"
      parent_management_group_id = "HMCTS"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "heritage"]
    }
    Heritage-Sandbox = {
      display_name               = "Heritage - Sandbox"
      parent_management_group_id = "Heritage"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "heritage_sandbox"]
    }
    Heritage-NonProd = {
      display_name               = "Heritage - Non-production"
      parent_management_group_id = "Heritage"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "heritage_non_production"]
    }
    Heritage-Prod = {
      display_name               = "Heritage - Production"
      parent_management_group_id = "Heritage"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "heritage_production"]
    }

    # Security
    Security = {
      display_name               = "Security"
      parent_management_group_id = "HMCTS"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "security"]
    }

    # Platform
    Platform = {
      display_name               = "Platform"
      parent_management_group_id = "HMCTS"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "platform"]
    }
    Platform-Sandbox = {
      display_name               = "Platform - Sandbox"
      parent_management_group_id = "Platform"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "platform_sandbox"]
    }
    Platform-NonProd = {
      display_name               = "Platform - Non-production"
      parent_management_group_id = "Platform"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "platform_non_production"]
    }
    Platform-Prod = {
      display_name               = "Platform - Production"
      parent_management_group_id = "Platform"
      subscription_ids           = [for subscription in values(module.subscription).*.subscription_id : subscription.subscription_id if subscription.group == "platform_production"]
    }
  }
}
