variable "custom_roles" {
  default = {}
}

variable "reader_group_id" {
  description = "The ID of the Azure AD group that should be assigned reader roles."
  type        = string
}

variable "subscription_id" {
  description = "THe ID of the subscription to assign roles to."
  type        = string
}
