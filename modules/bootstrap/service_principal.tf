resource "random_password" "token" {
  length           = 32
  special          = true
  override_special = "$@"
}

resource "random_uuid" "app_uuid" {}

resource "azuread_application" "app" {
  display_name = local.app_name
  api {
    oauth2_permissions_scope {
      admin_consent_description  = join(" ", ["Allow the application to access", local.app_name, "on behalf of the signed-in user."])
      admin_consent_display_name = join(" ", ["Access", local.app_name])
      id                         = random_uuid.app_uuid.result
      enabled                    = true
      type                       = "User"
      user_consent_description   = join(" ", ["Allow the application to access", local.app_name, "on your behalf."])
      user_consent_display_name  = join(" ", ["Access", local.app_name])
      value                      = "user_impersonation"
    }
  }
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a" # Directory.Read.All Delegated
      type = "Scope"
    }
  }
  web {
    homepage_url = "https://dev.azure.com/hmcts/Operations"
  }
}

resource "azuread_application_password" "token" {
  application_object_id = azuread_application.app.id
  value                 = random_password.token.result
  end_date_relative     = "8760h"
}

resource "azuread_service_principal" "sp" {
  application_id = azuread_application.app.application_id
}