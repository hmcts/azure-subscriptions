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

variable "project_id" {
  default = "c8947a39-47e3-4236-8bc8-51ff42dbda51"
}