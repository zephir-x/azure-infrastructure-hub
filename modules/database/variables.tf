variable "project_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_id" {
  type        = string
  description = "ID of the Virtual Network to link the Private DNS Zone against."
}

variable "subnet_id" {
  type        = string
  description = "ID of the delegated subnet where the PostgreSQL server will be injected."
}

variable "key_vault_id" {
  type        = string
  description = "ID of the Key Vault where the generated admin password will be stored."
}

variable "db_sku_name" {
  type        = string
  default     = "B_Standard_B2s"
  description = "SKU for the PostgreSQL instance. Default is a cost-effective burstable tier for development."
}

variable "db_zone" {
  type        = string
  default     = "2"
  description = "Availability zone for the PostgreSQL instance. Must match the availability zone constraints of the region."
}