# --- Identity & Security Outputs ---
# Exported for integration with the 'apps' and 'database' modules

output "key_vault_id" {
  value = azurerm_key_vault.main.id
}

output "aca_identity_id" {
  value = azurerm_user_assigned_identity.aca.id
}

output "aca_identity_principal_id" {
  value = azurerm_user_assigned_identity.aca.principal_id
}

# --- Network Outputs ---
# Exported to ensure workloads are deployed into the correct pre-configured subnets

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_compute_id" {
  value = azurerm_subnet.compute.id
}

output "subnet_database_id" {
  value = azurerm_subnet.database.id
}

# --- Registry Outputs ---
# Exported so CI/CD processes and Container Apps know where to push/pull Docker images

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "acr_id" {
  value = azurerm_container_registry.main.id
}

output "acr_pull_role_assignment_id" {
  value = azurerm_role_assignment.acr_pull.id
}

output "container_registry_name" {
  value = azurerm_container_registry.main.name
}

# --- Monitoring Outputs ---

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}