variable "keyvault_name" {
  description = "Name of the key vault"
  type        = string
}

variable "location" {
  description = "Location of the key vault"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID"
  type        = string
}

variable "tags" {
  description = "Tags of the key vault"
  type        = map(string)
}

variable "object_id" {
  description = "Object ID"
  type        = string
}

