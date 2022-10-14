resource "random_uuid" "acme_app_uuid" {
    count = var.deploy_acme ? 1 : 0
}

resource "azuread_application" "acme_appreg" {
  count        = var.deploy_acme ? 1 : 0
  display_name = local.acme_app_name
  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access ${local.acme_app_name} on behalf of the signed-in user."
      admin_consent_display_name = "Access ${local.acme_app_name}"
      id                         = random_uuid.acme_app_uuid[0].result
      enabled                    = true
      type                       = "User"
      user_consent_description   = "Allow the application to access ${local.acme_app_name} on your behalf."
      user_consent_display_name  = "Access ${local.acme_app_name}"
      value                      = "user_impersonation"
    }
  }
  web {
    redirect_uris = ["https://acme${replace(local.acme_uri, "-", "")}.azurewebsites.net/.auth/login/aad/callback"]

    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }
}