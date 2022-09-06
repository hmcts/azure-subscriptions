cft_sandbox_subscriptions = {
  DCD-RBAC-NONPRODUCTION = {
    env = "sbox"
  }
}

cft_non_production_subscriptions = {
  DTS-Terraform-Dev-Test1 = {
    env = "dev"
    deploy_acme = true
    acme_storage_account_repl_type = "LRS"
  }
  DTS-Terraform-Dev-Test2 = {
    env = "dev"
  }
}

enrollment_account_name = "322108"