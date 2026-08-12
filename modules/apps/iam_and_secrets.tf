# Grant Container Apps Identity permission to read secrets
resource "azurerm_role_assignment" "aca_kv_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.aca_identity_principal_id
}

# Construct and store full connection string
resource "azurerm_key_vault_secret" "gymcore_db_cs" {
  name         = "gymcore-db-connection-string"
  value        = "Host=${var.postgres_fqdn};Port=5432;Database=gymcore_db;Username=psqladmin;Password=${var.postgres_admin_password}"
  key_vault_id = var.key_vault_id
  depends_on   = [azurerm_role_assignment.aca_kv_secrets_user]
}

# Generate and store JWT Secret
resource "random_password" "jwt_secret" {
  length  = 64
  special = true
}

resource "azurerm_key_vault_secret" "gymcore_jwt" {
  name         = "gymcore-jwt-secret"
  value        = random_password.jwt_secret.result
  key_vault_id = var.key_vault_id
}

# External API Secrets
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

# GameNest DB Password
resource "azurerm_key_vault_secret" "gamenest_db_pass" {
  name         = "gamenest-db-pass"
  value        = var.postgres_admin_password
  key_vault_id = var.key_vault_id
  depends_on   = [azurerm_role_assignment.aca_kv_secrets_user]
}