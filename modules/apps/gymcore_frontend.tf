# --- GymCore React Frontend Deployment ---
# Specifically designed for a decoupled React/Vite SPA architecture

resource "azurerm_container_app" "gymcore_frontend" {
  name                         = "app-gymcore-front-${var.environment}"
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  # Attaches the Managed Identity used for secure ACR pulls and Key Vault access
  identity {
    type         = "UserAssigned"
    identity_ids = [var.aca_identity_id]
  }

  registry {
    server   = "${var.container_registry_name}.azurecr.io"
    identity = var.aca_identity_id
  }

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
    min_replicas = 1
    max_replicas = 10

    container {
      name   = "gymcore-frontend"
      # Initial placeholder image. GitHub Actions CI/CD will overwrite this with the actual application build
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.5
      memory = "1Gi"

      # Dynamically injects the API FQDN generated in gymcore_api.tf so the frontend knows where to send requests
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

  depends_on = [
    azurerm_role_assignment.aca_kv_secrets_user,
    var.acr_pull_role_assignment_id
  ]
}