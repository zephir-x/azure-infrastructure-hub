output "postgres_server_name" {
  value = azurerm_postgresql_flexible_server.main.name
}

output "postgres_server_fqdn" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgres_admin_password" {
  value     = random_password.postgres_admin.result
  sensitive = true
}