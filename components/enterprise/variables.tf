variable "root_id" {
  type    = string
  default = "hmcts"
}

variable "root_name" {
  type    = string
  default = "HMCTS Programmes"
}

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
