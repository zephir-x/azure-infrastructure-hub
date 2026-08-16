# --- Base Infrastructure Configuration ---

# Used as a prefix for all resource names to ensure uniqueness
variable "project_prefix" {
  type    = string
  default = "mthub"
}

# Defines the deployment environment (e.g., dev, prod)
variable "environment" {
  type    = string
  default = "dev"
}

# Target Azure region for deployment
variable "location" {
  type    = string
  default = "polandcentral"
}

# Base CIDR block for the Virtual Network (VNET)
variable "base_cidr" {
  type    = string
  default = "10.40.0.0/22"
}

# --- Sensitive Application Secrets ---
# These should be securely passed via terraform.tfvars or CI/CD pipelines

# Stripe API key for payment processing
variable "stripe_secret_key" {
  type      = string
  sensitive = true
}

# Stripe webhook secret for event verification
variable "stripe_webhook_secret" {
  type      = string
  sensitive = true
}

# DeepSeek API key for AI integrations
variable "deepseek_api_key" {
  type      = string
  sensitive = true
}