variable "root_id" {
  type    = string
  default = "hmcts"
}

variable "root_name" {
  type    = string
  default = "HMCTS Programmes"
}

# unused
variable "env" {}
variable "builtFrom" {}
variable "product" {}

variable "environment" {}

variable "cft_subscriptions" {
  default = []
}
variable "cft_sandbox_subscriptions" {
  default = []
}
variable "cft_non_production_subscriptions" {
  default = []
}
variable "cft_production_subscriptions" {
  default = []
}

variable "sds_subscriptions" {
  default = []
}
variable "sds_sandbox_subscriptions" {
  default = []
}
variable "sds_non_production_subscriptions" {
  default = []
}
variable "sds_production_subscriptions" {
  default = []
}
variable "crime_subscriptions" {
  default = []
}
variable "heritage_subscriptions" {
  default = []
}
variable "heritage_sandbox_subscriptions" {
  default = []
}
variable "heritage_non_production_subscriptions" {
  default = []
}
variable "heritage_production_subscriptions" {
  default = []
}
variable "security_subscriptions" {
  default = []
}
variable "platform_subscriptions" {
  default = []
}
variable "platform_sandbox_subscriptions" {
  default = []
}
variable "platform_non_production_subscriptions" {
  default = []
}
variable "platform_production_subscriptions" {
  default = []
}

variable "billing_account_name" {
  default = "59232335"
}

variable "enrollment_account_name" {}

variable "location" {
  default = "UK South"
}
