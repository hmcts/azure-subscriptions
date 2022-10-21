variable "name" {}
variable "value" {
  default = ""
}

variable "billing_account_name" {}
variable "enrollment_account_name" {}
variable "deploy_acme" {}

variable "storage_container_name" {
  description = "The name of the storage container to create."
  type        = string
  default     = "subscription-tfstate"
}

variable "location" {
  description = "The location for the Storage Account."
  type        = string
  default     = "UK South"
}

variable "account_tier" {
  description = "The tier for the Storage Account."
  type        = string
  default     = "Standard"
}

variable "account_kind" {
  description = "The kind of Storage Account to create."
  type        = string
  default     = "StorageV2"
}

variable "replication_type" {
  description = "The type of replication to use for the Storage Account."
  type        = string
  default     = "ZRS"
}

variable "access_type" {
  description = "The access type for the storage account container."
  type        = string
  default     = "private"
}

variable "purge_protection_enabled" {
  description = "Should we enable Purge Protection on the KeyVault."
  type        = bool
  default     = false
}

variable "sku_name" {
  description = "The SKU for the KeyVault."
  type        = string
  default     = "standard"
}

variable "environment" {
  default = ""

  validation {
    condition     = contains(["demo", "dev", "ithc", "mgmt", "ptl", "ptlsbox", "prod", "sbox", "stg", "test"], var.environment)
    error_message = "Valid values for environment are (demo, dev, ithc, mgmt, ptl, ptlsbox, prod, sbox, stg, test)."
  }
}

variable "common_tags" {
  description = "Common tag to be applied"
  type        = map(string)
}

variable "project_id" {
  # PlatformOperations project
  default = "c8947a39-47e3-4236-8bc8-51ff42dbda51"
}