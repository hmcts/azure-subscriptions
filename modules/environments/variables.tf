variable "name" {}

variable "location" {}
variable "product" {}
variable "env" {}
variable "asp_sku_size" {}
variable "asp_sku_tier" {}


variable "common_tags" {
  description = "Common tag to be applied"
  type        = map(string)
}