locals {
  app_name = join(" ", ["DTS Operations", join("", ["(", join(":", ["env", var.environment]), ")"])])
  # env      = var.environment == "sandbox" ? "sbox" : var.environment
  groups = {
    "DTS Operations" = {
      name        = join(" ", ["DTS Operations", join("", ["(", join(":", ["env", var.environment]), ")"])]),
      description = "${var.environment} Operations elevated access"
      members     = [azuread_service_principal.sp.object_id]
    }
    "DNS Zone Contributor" = {
      name        = join(" ", ["DTS DPublic DNS Contributors", join("", ["(", join(":", ["env", var.environment]), ")"])]),
      description = "Grants dns zone contributor permissions to the ${var.environment} environment"
      members     = [data.azuread_group.ops_env.object_id, azuread_service_principal.sp.object_id]
    }
  }
}