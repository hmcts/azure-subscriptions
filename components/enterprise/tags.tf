module "tags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = "nonprod"
  product     = var.product
  builtFrom   = var.builtFrom
}