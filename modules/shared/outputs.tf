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

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "acr_id" {
  value = azurerm_container_registry.main.id
}

output "aca_identity_id" {
  value = azurerm_user_assigned_identity.aca.id
}

output "aca_identity_principal_id" {
  value = azurerm_user_assigned_identity.aca.principal_id
}