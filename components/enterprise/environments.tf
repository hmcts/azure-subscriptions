module "environment" {
  for_each = local.environments

  source               = "../../modules/environments"
  name                 = each.key
  common_tags          = module.environment_tags[each.key].common_tags
  location             = var.location
  env                  = each.key
  asp_sku_size         = var.asp_sku_size
  asp_sku_tier         = var.asp_sku_tier
  product              = var.product
  pipeline_environment = var.env
  display_name_prefix  = try(each.value.display_name_prefix, "DTS-SHAREDSERVICES-${each.key}")
}

module "environment_tags" {
  for_each    = local.environments
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=DTSPO-9743/azure-enterprise"
  environment = each.key
  product     = var.product
  builtFrom   = var.builtFrom
}
