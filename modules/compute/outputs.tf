# --- Container Environment Outputs ---

# Exported to dictate where individual Container Apps (frontend, API, sidecars) should be deployed
output "container_app_environment_id" {
  value = azurerm_container_app_environment.main.id
}