# Configures the internal Network Interface (NIC) for the Jumpbox VM
# Placed securely inside the dedicated 'snet-jumpbox' subnet
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

# Provisions a lightweight Ubuntu Linux VM acting as a Jumpbox and Self-Hosted Runner for CI/CD
resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                  = "vm-jump-${var.project_prefix}-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B2s_v2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.jumpbox.id]

  # Enables a System-Assigned Managed Identity for secure, credential-less Azure resource access
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

# Installs the Entra ID (Azure AD) SSH login extension
# Allows administrators to log into the VM using their Azure credentials instead of relying solely on SSH keys
resource "azurerm_virtual_machine_extension" "entra_id_login" {
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.jumpbox.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

# Grants the executing user/administrator the rights to log into the VM via Entra ID
resource "azurerm_role_assignment" "entra_id_user_login" {
  scope                = azurerm_linux_virtual_machine.jumpbox.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = var.client_object_id
}

# Fetches the current Resource Group reference to construct IAM scopes
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Grants the Jumpbox VM's Managed Identity 'Contributor' rights over the entire Resource Group
# This is required for the GitHub Actions Runner to execute 'az containerapp update' and manage infrastructure
resource "azurerm_role_assignment" "jumpbox_rg_contributor" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_virtual_machine.jumpbox.identity[0].principal_id
}

# Grants the Jumpbox VM the ability to push compiled Docker images to the Azure Container Registry
resource "azurerm_role_assignment" "jumpbox_acr_push" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_linux_virtual_machine.jumpbox.identity[0].principal_id
}