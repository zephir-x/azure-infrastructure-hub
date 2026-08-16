# --- Global Naming & Location Parameters ---

variable "project_prefix" {
  type        = string
  description = "A standard prefix added to all resources to ensure consistent naming conventions."
}

variable "environment" {
  type        = string
  description = "The deployment environment tier (e.g., dev, prod, staging)."
}

variable "location" {
  type        = string
  description = "The target Azure region where the shared resources will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the main resource group acting as the root container."
}

# --- Network Parameters ---

variable "base_cidr" {
  type        = string
  description = "The root IPv4 CIDR block for the Virtual Network, which will be logically divided into subnets."
}

# --- Identity & Authentication Parameters ---

variable "tenant_id" {
  type        = string
  description = "The Azure Active Directory (Entra ID) tenant ID."
}

variable "client_object_id" {
  type        = string
  description = "The Object ID of the executing user or service principal (used for RBAC and Key Vault access)."
}

variable "jumpbox_ssh_public_key" {
  type        = string
  description = "The dynamically generated public SSH key used to authenticate with the Jumpbox VM."
}