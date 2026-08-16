# Provisions the Azure Container Apps Environment
# This acts as the secure, serverless runtime boundary (under the hood: a managed Kubernetes cluster)
resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.project_prefix}-${var.environment}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Routes all standard output (stdout/stderr) from containers directly to Azure Log Analytics
  logs_destination           = "log-analytics"

  # Network integration: injects the environment directly into our dedicated compute VNET subnet
  infrastructure_subnet_id       = var.subnet_id

  # Set to false to allow applications hosted in this environment to receive external HTTPS traffic
  internal_load_balancer_enabled = false

  # Prevents Terraform from reverting dynamic workload profile adjustments made by Azure or external scaling events
  lifecycle {
    ignore_changes = [
      workload_profile
    ]
  }
}