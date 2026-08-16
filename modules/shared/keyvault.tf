# Generates a random 6-character string
# Required because Azure Key Vault names must be globally unique across all Azure customers
resource "random_string" "kv_suffix" {
  length  = 6
  upper   = false
  special = false
}

# Provisions a centralized Key Vault for secure storage of database connection strings, API keys, and certificates
resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.project_prefix}-${var.environment}-${random_string.kv_suffix.result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"

  # Uses the modern Azure Role-Based Access Control (RBAC) authorization model instead of legacy Access Policies
  rbac_authorization_enabled = true

  # Set to false for dev/PoC environments to allow rapid recreation of Key Vaults without waiting for the purge period
  purge_protection_enabled   = false
}

# Grants the deploying principal (the user running Terraform) full administrative rights over Key Vault secrets
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.client_object_id
}