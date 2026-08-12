# User Assigned Managed Identity for Container Apps
resource "azurerm_user_assigned_identity" "aca" {
  name                = "id-aca-${var.project_prefix}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Role Assignment granting AcrPull permissions to the Identity
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca.principal_id
}