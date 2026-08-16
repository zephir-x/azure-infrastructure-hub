# --- Identity Access Management (IAM) & Secrets Provisioning ---

# Grants the Azure Container Apps (ACA) Managed Identity permission to read secrets from Key Vault
# This eliminates the need to hardcode passwords in application environment variables
resource "azurerm_role_assignment" "aca_kv_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.aca_identity_principal_id
}

# Dynamically constructs the full PostgreSQL connection string for GymCore and stores it securely
resource "azurerm_key_vault_secret" "gymcore_db_cs" {
  name         = "gymcore-db-connection-string"
  value        = "Host=${var.postgres_fqdn};Port=5432;Database=gymcore_db;Username=psqladmin;Password=${var.postgres_admin_password}"
  key_vault_id = var.key_vault_id

  # Must wait for IAM propagation to avoid race conditions during deployment
  depends_on   = [azurerm_role_assignment.aca_kv_secrets_user]
}

# Generates and stores a cryptographically secure 64-character secret for GymCore's JWT authentication
resource "random_password" "jwt_secret" {
  length  = 64
  special = true
}

resource "azurerm_key_vault_secret" "gymcore_jwt" {
  name         = "gymcore-jwt-secret"
  value        = random_password.jwt_secret.result
  key_vault_id = var.key_vault_id
}

# --- External API Secrets ---
# Safely injects third-party API keys into the Key Vault via Terraform variables

resource "azurerm_key_vault_secret" "stripe_secret_key" {
  name         = "stripe-secret-key"
  value        = var.stripe_secret_key
  key_vault_id = var.key_vault_id
  depends_on   = [azurerm_role_assignment.aca_kv_secrets_user]
}

resource "azurerm_key_vault_secret" "stripe_webhook_secret" {
  name         = "stripe-webhook-secret"
  value        = var.stripe_webhook_secret
  key_vault_id = var.key_vault_id
  depends_on   = [azurerm_role_assignment.aca_kv_secrets_user]
}

resource "azurerm_key_vault_secret" "deepseek_api_key" {
  name         = "deepseek-api-key"
  value        = var.deepseek_api_key
  key_vault_id = var.key_vault_id
  depends_on   = [azurerm_role_assignment.aca_kv_secrets_user]
}

# Stores the raw database password for GameNest (since PHP handles the connection string construction internally)
resource "azurerm_key_vault_secret" "gamenest_db_pass" {
  name         = "gamenest-db-pass"
  value        = var.postgres_admin_password
  key_vault_id = var.key_vault_id
  depends_on   = [azurerm_role_assignment.aca_kv_secrets_user]
}