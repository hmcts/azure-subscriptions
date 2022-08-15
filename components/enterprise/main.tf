variable "root_id" {
  type    = string
  default = "hmcts"
}

variable "root_name" {
  type    = string
  default = "HMCTS Programmes"
}

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
      subscription_ids           = []
    }
    CFT-Sandbox = {
      display_name               = "CFT - Sandbox"
      parent_management_group_id = "CFT"
      subscription_ids           = []
    }
    CFT-NonProd = {
      display_name               = "CFT - Non-production"
      parent_management_group_id = "CFT"
      subscription_ids           = []
    }
    CFT-Prod = {
      display_name               = "CFT - Production"
      parent_management_group_id = "CFT"
      subscription_ids           = []
    }

    # SDS
    SDS = {
      display_name               = "SDS"
      parent_management_group_id = "HMCTS"
      subscription_ids           = []
    }
    SDS-Sandbox = {
      display_name               = "SDS - Sandbox"
      parent_management_group_id = "SDS"
      subscription_ids           = []
    }
    SDS-NonProd = {
      display_name               = "SDS - Non-production"
      parent_management_group_id = "SDS"
      subscription_ids           = []
    }
    SDS-Prod = {
      display_name               = "SDS - Production"
      parent_management_group_id = "SDS"
      subscription_ids           = []
    }

    # Crime
    Crime = {
      display_name               = "Crime"
      parent_management_group_id = "HMCTS"
      subscription_ids           = []
    }

    # Heritage
    Heritage = {
      display_name               = "Heritage"
      parent_management_group_id = "HMCTS"
      subscription_ids           = []
    }
    Heritage-Sandbox = {
      display_name               = "Heritage - Sandbox"
      parent_management_group_id = "Heritage"
      subscription_ids           = []
    }
    Heritage-NonProd = {
      display_name               = "Heritage - Non-production"
      parent_management_group_id = "Heritage"
      subscription_ids           = []
    }
    Heritage-Prod = {
      display_name               = "Heritage - Production"
      parent_management_group_id = "Heritage"
      subscription_ids           = []
    }

    # Security
    Security = {
      display_name               = "Security"
      parent_management_group_id = "HMCTS"
      subscription_ids           = []
    }

    # Platform
    Platform = {
      display_name               = "Platform"
      parent_management_group_id = "HMCTS"
      subscription_ids           = []
    }
    Platform-Sandbox = {
      display_name               = "Platform - Sandbox"
      parent_management_group_id = "Platform"
      subscription_ids           = []
    }
    Platform-NonProd = {
      display_name               = "Platform - Non-production"
      parent_management_group_id = "Platform"
      subscription_ids           = []
    }
    Platform-Prod = {
      display_name               = "Platform - Production"
      parent_management_group_id = "Platform"
      subscription_ids           = []
    }
  }
}