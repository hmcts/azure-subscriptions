module "environment" {
  for_each = local.environments

  source               = "../../modules/environments"
  name                 = each.key
  common_tags          = module.environment_tags[each.key].common_tags
  location             = var.location
  env                  = each.key
  sp_sku_name          = var.sp_sku_name
  product              = var.product
  pipeline_environment = var.env
  display_name_prefix  = try(each.value.display_name_prefix, "DTS-SHAREDSERVICES-${upper(each.key)}")
}

module "environment_tags" {
  for_each    = local.environments
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = each.key
  product     = var.product
  builtFrom   = var.builtFrom
}
