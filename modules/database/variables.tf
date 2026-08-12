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
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "db_sku_name" {
  type    = string
  default = "B2s_v2"
}

variable "db_zone" {
  type    = string
  default = "2"
}