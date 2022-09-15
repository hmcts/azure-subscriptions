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
  project_id           = "c8947a39-47e3-4236-8bc8-51ff42dbda51"
}

module "environment_tags" {
  for_each    = local.environments
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = each.key
  product     = var.product
  builtFrom   = var.builtFrom
}
