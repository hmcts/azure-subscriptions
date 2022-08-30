module "tags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=DTSPO-9743/azure-enterprise"
  environment = var.env
  product     = var.product
  builtFrom   = var.builtFrom
}