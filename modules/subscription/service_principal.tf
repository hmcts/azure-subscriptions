resource "time_rotating" "one_year" {
  rotation_days = 365
}

resource "random_uuid" "app_uuid" {}

resource "azuread_application" "app" {
  display_name = local.app_name
  owners       = [data.azurerm_client_config.current.object_id]

  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access ${local.app_name} on behalf of the signed-in user."
      admin_consent_display_name = "Access ${local.app_name}"
      id                         = random_uuid.app_uuid.result
      enabled                    = true
      type                       = "User"
      user_consent_description   = "Allow the application to access ${local.app_name} on your behalf."
      user_consent_display_name  = "Access ${local.app_name}"
      value                      = "user_impersonation"
    }
  }
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a" # Directory.Read.All Delegated
      type = "Scope"
    }

    resource_access {
      id   = "5b567255-7703-4780-807c-7be8301ae99b" # Group.Read.All Application
      type = "Role"
    }

    resource_access {
      id   = "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30" # Application.Read.All Application
      type = "Role"
    }
  }
  web {
    homepage_url = "https://dev.azure.com/hmcts/PlatformOperations"

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_application_password" "token" {
  application_object_id = azuread_application.app.id
  rotate_when_changed = {
    rotation = time_rotating.one_year.id
  }
}

resource "azuread_service_principal" "sp" {
  owners         = [data.azurerm_client_config.current.object_id]
  application_id = azuread_application.app.application_id
}