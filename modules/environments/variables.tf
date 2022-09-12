variable "name" {}

variable "location" {}
variable "product" {}
variable "env" {}
variable "asp_sku_size" {}
variable "asp_sku_tier" {}
variable "pipeline_environment" {}
variable "display_name_prefix" {
  default = ""
}

variable "common_tags" {
  description = "Common tag to be applied"
  type        = map(string)
}
