locals {
  app_name = "DTS Operations (env:${var.env})"
  groups = {
    "DTS Operations" = {
      name        = "DTS Operations (env:${var.env})"
      description = "${var.env} Operations elevated access"
      members     = [azuread_service_principal.sp.object_id]
    }
    "DNS Zone Contributor" = {
      name        = "DTS Public DNS Contributor (env:${var.env})"
      description = "Grants dns zone contributor permissions to the ${var.env} environment"
      members     = [azuread_service_principal.sp.object_id]
    }
  }
}