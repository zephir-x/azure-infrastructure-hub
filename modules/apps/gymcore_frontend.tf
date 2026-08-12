resource "azurerm_container_app" "gymcore_frontend" {
  name                         = "app-gymcore-front-${var.environment}"
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = "gymcore-frontend"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.5
      memory = "1Gi"

      # Dynamically mapping the generated API URL
      env {
        name  = "VITE_API_URL"
        value = "https://${azurerm_container_app.gymcore_api.ingress[0].fqdn}"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      workload_profile_name
    ]
  }
}