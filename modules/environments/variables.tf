variable "name" {}

variable "location" {}
variable "product" {}
variable "env" {}
variable "sp_sku_name" {}
variable "pipeline_environment" {}
variable "display_name_prefix" {
  default = ""
}

variable "common_tags" {
  description = "Common tag to be applied"
  type        = map(string)
}

variable "project_id" {
  # PlatformOperations project
  default = "c8947a39-47e3-4236-8bc8-51ff42dbda51"
}