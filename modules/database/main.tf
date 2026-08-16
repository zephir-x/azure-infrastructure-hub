# Provisions a Private DNS Zone required for internal name resolution of the PostgreSQL server
# This ensures database traffic remains strictly within the Azure backbone and never traverses the public internet
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

# Links the Private DNS Zone directly to the main Virtual Network (VNET)
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                = "dns-link-postgres-${var.project_prefix}-${var.environment}"
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id
  virtual_network_id  = var.vnet_id

  depends_on = [azurerm_private_dns_zone.postgres]
}

# Generates a highly secure, randomized 24-character password for the database administrator
resource "random_password" "postgres_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Persists the generated administrator password directly into Azure Key Vault
# This prevents credential leakage and allows applications to fetch it securely via Managed Identities
resource "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  value        = random_password.postgres_admin.result
  key_vault_id = var.key_vault_id
}

# Provisions the primary PostgreSQL Flexible Server instance
# Configured for VNET injection (delegated_subnet_id) with public network access strictly disabled
resource "azurerm_postgresql_flexible_server" "main" {
  name                          = "psql-${var.project_prefix}-${var.environment}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "16"
  delegated_subnet_id           = var.subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  administrator_login           = "psqladmin"
  administrator_password        = random_password.postgres_admin.result
  sku_name                      = var.db_sku_name
  storage_mb                    = 32768
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = false
  zone                          = var.db_zone

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
}

# Logical database provisioning for the GymCore application
resource "azurerm_postgresql_flexible_server_database" "gymcore" {
  name      = "gymcore_db"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# Logical database provisioning for the GameNest application
# Sharing the same physical server instance significantly reduces compute costs while maintaining logical isolation
resource "azurerm_postgresql_flexible_server_database" "gamenest" {
  name      = "gamenest_db"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}