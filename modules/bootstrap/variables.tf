variable "tags" {
  description = "Tags to be used when we create the Storage Account."
  type        = map(string)
}

# variable "storage_account_name" {
#   description = "The name of the Storage Account to create."
#   type        = string
# }

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

variable "resource_group_name" {
  description = "The name of the resource group to contain the Storage Account."
  type        = string
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