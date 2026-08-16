# Provisions a static Public IP specifically for the Azure Bastion service
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bas-${var.project_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Deploys Azure Bastion Host to provide secure, agentless SSH/RDP access to VMs
# This eliminates the need to expose port 22 (SSH) to the public internet
resource "azurerm_bastion_host" "main" {
  name                = "bas-${var.project_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}