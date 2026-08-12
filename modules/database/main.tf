# Private DNS integration for PostgreSQL Flexible Server
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                = "dns-link-postgres-${var.project_prefix}-${var.environment}"
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id
  virtual_network_id  = var.vnet_id

  depends_on = [azurerm_private_dns_zone.postgres]
}

# Administrative credentials generation and secure storage
resource "random_password" "postgres_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  value        = random_password.postgres_admin.result
  key_vault_id = var.key_vault_id
}

# Primary PostgreSQL Flexible Server deployment
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

# Tenant database provisioning
resource "azurerm_postgresql_flexible_server_database" "gymcore" {
  name      = "gymcore_db"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_database" "gamenest" {
  name      = "gamenest_db"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}