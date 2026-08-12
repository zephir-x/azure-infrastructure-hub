# Azure Container Registry for storing application images
resource "azurerm_container_registry" "main" {
  name                = "acr${var.project_prefix}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}