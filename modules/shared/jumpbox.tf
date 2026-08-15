# Jumpbox Virtual Machine with Entra ID authentication
resource "azurerm_network_interface" "jumpbox" {
  name                = "nic-jumpbox-${var.project_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jumpbox.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                  = "vm-jump-${var.project_prefix}-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B2s_v2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.jumpbox.id]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.jumpbox_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "entra_id_login" {
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.jumpbox.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_role_assignment" "entra_id_user_login" {
  scope                = azurerm_linux_virtual_machine.jumpbox.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = var.client_object_id
}

# We fetch information about our resource group to get its ID
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# We give Jumpbox the rights to modify services (e.g. Container Apps)
resource "azurerm_role_assignment" "jumpbox_rg_contributor" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_virtual_machine.jumpbox.identity[0].principal_id
}

# We give Jumpbox the rights to upload Docker images to the ACR registry
resource "azurerm_role_assignment" "jumpbox_acr_push" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_linux_virtual_machine.jumpbox.identity[0].principal_id
}