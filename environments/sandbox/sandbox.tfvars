cft_sandbox_subscriptions = [
  "89678afe-decf-43ac-a878-64359bdbed56", # DCD-RBAC-NONPRODUCTION
]

cft_non_production_subscriptions = [
  "DTS-Terraform-Dev-Test1",
  "DTS-Terraform-Dev-Test2",
  "DCD-RBAC-NONPRODUCTION"
]

enrollment_account_name = "322108"

subscriptions = [
  {
    name                = "DTS-Terraform-Dev-Test1"
    management_group    = "cft_non_production_subscriptions"
  },
  {
    name                = "DTS-Terraform-Dev-Test2"
    management_group    = "cft_non_production_subscriptions"
  },
    {
    name                = "DTS-Terraform-Dev-Test3"
    management_group    = "cft_non_production_subscriptions"
  }
]