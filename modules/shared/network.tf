# Virtual Network and Subnets configuration
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.base_cidr]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.base_cidr, 4, 0)]
}

resource "azurerm_subnet" "compute" {
  name                 = "snet-compute"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.base_cidr, 2, 1)]
  depends_on           = [azurerm_subnet.bastion]

  delegation {
    name = "aca-delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "database" {
  name                 = "snet-database"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.base_cidr, 2, 2)]
  depends_on           = [azurerm_subnet.compute]

  delegation {
    name = "pgsql-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "jumpbox" {
  name                 = "snet-jumpbox"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.base_cidr, 2, 3)]
  depends_on           = [azurerm_subnet.database]
}