locals {
  groups = {
    owners = {
      name        = join(" ", ["DTS Owners", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants owner permissions to the ${var.subscription} subscription"
    }
    readers = {
      name        = join(" ", ["DTS Readers", join("", ["(", join(":", ["sub", var.subscription_name]), ")"])]),
      description = "Grants reader permissions to the ${var.subscription} subscription"
    }
  }
}