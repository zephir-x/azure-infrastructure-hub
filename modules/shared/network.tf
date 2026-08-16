# Provisions the foundational Virtual Network (VNET) encapsulating all ecosystem resources
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.base_cidr]
}

# Dedicated subnet for Azure Bastion. The name 'AzureBastionSubnet' is strictly required by Azure
# Uses the first chunk of the base CIDR
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.base_cidr, 4, 0)]
}

# Dedicated subnet for Azure Container Apps Environment (Compute Layer)
resource "azurerm_subnet" "compute" {
  name                 = "snet-compute"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.base_cidr, 2, 1)]

  depends_on = [azurerm_subnet.bastion]

  # Explicit delegation required by Azure to allow Container Apps to inject itself into the VNET
  delegation {
    name = "aca-delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Dedicated subnet for PostgreSQL Flexible Server (Database Layer)
resource "azurerm_subnet" "database" {
  name                 = "snet-database"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.base_cidr, 2, 2)]

  depends_on = [azurerm_subnet.compute]

  # Explicit delegation required by Azure to allow the database service to bind to this subnet
  delegation {
    name = "pgsql-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Dedicated subnet for management operations, hosting the Jumpbox VM
resource "azurerm_subnet" "jumpbox" {
  name                 = "snet-jumpbox"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.base_cidr, 2, 3)]

  depends_on = [azurerm_subnet.database]
}