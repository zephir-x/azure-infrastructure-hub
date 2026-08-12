resource "azurerm_container_app" "gymcore_api" {
  name                         = "app-gymcore-api-${var.environment}"
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.aca_identity_id]
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8080
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  secret {
    name                = "db-connection-string"
    key_vault_secret_id = azurerm_key_vault_secret.gymcore_db_cs.versionless_id
    identity            = var.aca_identity_id
  }

  secret {
    name                = "jwt-secret"
    key_vault_secret_id = azurerm_key_vault_secret.gymcore_jwt.versionless_id
    identity            = var.aca_identity_id
  }

  secret {
    name                = "stripe-secret-key"
    key_vault_secret_id = azurerm_key_vault_secret.stripe_secret_key.versionless_id
    identity            = var.aca_identity_id
  }

  secret {
    name                = "stripe-webhook-secret"
    key_vault_secret_id = azurerm_key_vault_secret.stripe_webhook_secret.versionless_id
    identity            = var.aca_identity_id
  }

  secret {
    name                = "deepseek-api-key"
    key_vault_secret_id = azurerm_key_vault_secret.deepseek_api_key.versionless_id
    identity            = var.aca_identity_id
  }

  template {
    container {
      name   = "gymcore-api"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Development"
      }
      env {
        name        = "ConnectionStrings__DefaultConnection"
        secret_name = "db-connection-string"
      }
      env {
        name        = "JwtSettings__Secret"
        secret_name = "jwt-secret"
      }
      env {
        name        = "Stripe__SecretKey"
        secret_name = "stripe-secret-key"
      }
      env {
        name        = "Stripe__WebhookSecret"
        secret_name = "stripe-webhook-secret"
      }
      env {
        name        = "DeepSeek__ApiKey"
        secret_name = "deepseek-api-key"
      }
      env {
        name  = "FrontendUrl"
        value = "https://app-gymcore-front-${var.environment}.${var.location}.azurecontainerapps.io"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      workload_profile_name
    ]
  }

  depends_on = [azurerm_role_assignment.aca_kv_secrets_user]
}