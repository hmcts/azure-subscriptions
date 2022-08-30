locals {
  groups = {
    "Contributor" = {
      name        = join(" ", ["DTS Contributors", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants contributor permissions to the ${var.subscription_name} subscription"
    }
    "Reader" = {
      name        = join(" ", ["DTS Readers", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants reader permissions to the ${var.subscription_name} subscription"
    }
    "Security Reader" = {
      name        = join(" ", ["DTS Security Readers", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants security reader permissions to the ${var.subscription_name} subscription"
    }
    "Owner" = {
      name        = join(" ", ["DTS Owners", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants owner permissions to the ${var.subscription_name} subscription"
    }
  }
}