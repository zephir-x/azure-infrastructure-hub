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

variable "container_app_environment_id" {
  type = string
}

variable "container_registry_name" {
  type        = string
  description = "ACR registry name"
}

variable "aca_identity_id" {
  type = string
}

variable "aca_identity_principal_id" {
  type = string
}

variable "acr_pull_role_assignment_id" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "postgres_fqdn" {
  type = string
}

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}

variable "stripe_secret_key" {
  type      = string
  sensitive = true
}

variable "stripe_webhook_secret" {
  type      = string
  sensitive = true
}

variable "deepseek_api_key" {
  type      = string
  sensitive = true
}