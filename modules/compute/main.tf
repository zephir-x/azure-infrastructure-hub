# Container Apps Environment (Managed Kubernetes Cluster)
resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.project_prefix}-${var.environment}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  logs_destination           = "log-analytics"

  # Network integration - putting the environment into our VNet
  infrastructure_subnet_id       = var.subnet_id
  internal_load_balancer_enabled = false

  lifecycle {
    ignore_changes = [
      workload_profile
    ]
  }
}