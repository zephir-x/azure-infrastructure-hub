# --- Highly Opinionated Module Variables ---
# NOTE: This module is custom-built specifically for the GymCore and GameNest architectures
# It expects exact parameters required by these distinct applications

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
  type        = string
  description = "The isolated environment ID where all application pods will be hosted."
}

variable "container_registry_name" {
  type        = string
  description = "ACR registry name used by Container Apps to pull deployment images."
}

# --- Identity Variables ---

variable "aca_identity_id" {
  type        = string
  description = "The full ID of the User-Assigned Managed Identity attached to the applications."
}

variable "aca_identity_principal_id" {
  type        = string
  description = "The Principal (Object) ID used to grant Key Vault access to the Container Apps."
}

variable "acr_pull_role_assignment_id" {
  type        = string
  description = "Ensures ACR pull rights are fully propagated before attempting to create the Container Apps."
}

variable "key_vault_id" {
  type = string
}

# --- Database & External Integrations ---

variable "postgres_fqdn" {
  type        = string
  description = "The Fully Qualified Domain Name of the PostgreSQL server for dynamic connection string generation."
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