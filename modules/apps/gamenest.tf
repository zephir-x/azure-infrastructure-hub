# --- GameNest Deployment (Sidecar Architecture) ---
# Custom architectural implementation to run a monolithic PHP application in a serverless environment

resource "azurerm_container_app" "gamenest" {
  name                         = "app-gamenest-${var.environment}"
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

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

  secret {
    name                = "db-password"
    key_vault_secret_id = azurerm_key_vault_secret.gamenest_db_pass.versionless_id
    identity            = var.aca_identity_id
  }

  template {
    min_replicas = 1
    max_replicas = 10

    # --- Multi-Container Setup (Sidecar Pattern) ---

    # Container 1: NGINX (Web server receiving external traffic and serving static assets)
    # Routes dynamic PHP requests to localhost:9000
    container {
      name   = "nginx"
      image  = "mcr.microsoft.com/k8se/quickstart:latest" # Placeholder for CI/CD
      cpu    = 0.25
      memory = "0.5Gi"
    }

    # Container 2: PHP-FPM (Backend Processor as Sidecar)
    # Listens on localhost:9000, sharing the same network namespace as the NGINX container
    container {
      name   = "php"
      image  = "mcr.microsoft.com/k8se/quickstart:latest" # Placeholder for CI/CD
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "DB_HOST"
        value = var.postgres_fqdn
      }
      env {
        name  = "DB_PORT"
        value = "5432"
      }
      env {
        name  = "DB_NAME"
        value = "gamenest_db"
      }
      env {
        name  = "DB_USER"
        value = "psqladmin"
      }
      env {
        name        = "DB_PASS"
        secret_name = "db-password"
      }
    }
  }

  # Ignores changes to BOTH container images
  # This prevents 'terraform apply' from destroying the live versions deployed by GitHub Actions
  lifecycle {
    ignore_changes = [
      workload_profile_name,
      template.0.container.0.image,
      template.0.container.1.image
    ]
  }

  depends_on = [
    azurerm_role_assignment.aca_kv_secrets_user,
    var.acr_pull_role_assignment_id
  ]
}