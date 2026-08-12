output "key_vault_id" {
  value = azurerm_key_vault.main.id
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_compute_id" {
  value = azurerm_subnet.compute.id
}

output "subnet_database_id" {
  value = azurerm_subnet.database.id
}