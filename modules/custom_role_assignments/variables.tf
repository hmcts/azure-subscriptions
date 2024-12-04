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

variable "create_custom_roles" {
  description = "A boolean value to inform module if custom roles were created or looked up using data lookups"
  type        = bool
  default     = true
}
