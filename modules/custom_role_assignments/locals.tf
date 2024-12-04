locals {
  custom_role_assignments = merge(var.custom_roles, {
    "Application Gateway Backend Health Reader" = {
      principal_id = var.reader_group_id
    },
  })
}

