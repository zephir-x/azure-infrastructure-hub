# --- PostgreSQL Connectivity Outputs ---
# Exported so the application modules can dynamically construct connection strings

output "postgres_server_name" {
  value = azurerm_postgresql_flexible_server.main.name
}

output "postgres_server_fqdn" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}

# Exported temporarily to pass into the application module deployment
# Marked as sensitive to prevent Terraform from printing it in plaintext console logs
output "postgres_admin_password" {
  value     = random_password.postgres_admin.result
  sensitive = true
}