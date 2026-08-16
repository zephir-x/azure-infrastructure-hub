# Provisions a private Azure Container Registry (ACR) to store application Docker images
resource "azurerm_container_registry" "main" {
  name                = "acr${var.project_prefix}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"

  # Admin account is disabled to enforce a Zero Trust security model
  # Authentication will be handled exclusively via Azure Managed Identities
  admin_enabled       = false
}