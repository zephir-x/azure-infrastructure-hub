# Fetches current Azure context (Tenant ID, Subscription ID, Object ID)
# Required for assigning RBAC roles and Key Vault access policies to the executor
data "azurerm_client_config" "current" {}

# Primary resource group acting as a logical container for all environment resources
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_prefix}-${var.environment}"
  location = var.location
}

# Generates a dynamic RSA key pair for secure SSH access to the Jumpbox
resource "tls_private_key" "jumpbox" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --- Tier 1: Foundation Layer ---
# Provisions VNET, Subnets, NSGs, Key Vault, ACR, and Managed Identities
module "shared" {
  source = "../../modules/shared"

  project_prefix         = var.project_prefix
  environment            = var.environment
  location               = azurerm_resource_group.main.location
  resource_group_name    = azurerm_resource_group.main.name
  base_cidr              = var.base_cidr
  tenant_id              = data.azurerm_client_config.current.tenant_id
  client_object_id       = data.azurerm_client_config.current.object_id
  jumpbox_ssh_public_key = tls_private_key.jumpbox.public_key_openssh
}

# Stores the generated Jumpbox SSH private key securely in Azure Key Vault
# Ensures no private keys are stored in plain text outside the remote state
resource "azurerm_key_vault_secret" "jumpbox_ssh" {
  name         = "vm-jumpbox-ssh-private"
  value        = tls_private_key.jumpbox.private_key_pem
  key_vault_id = module.shared.key_vault_id

  depends_on = [module.shared]
}

# --- Tier 2: Storage & Persistence Layer ---
# Provisions Azure Database for PostgreSQL Flexible Server
# Requires shared network infrastructure to be deployed first for VNET integration
module "database" {
  source = "../../modules/database"

  project_prefix      = var.project_prefix
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  vnet_id             = module.shared.vnet_id
  subnet_id           = module.shared.subnet_database_id
  key_vault_id        = module.shared.key_vault_id
  db_zone             = "2"

  depends_on = [module.shared]
}

# --- Tier 3: Compute Layer ---
# Provisions Azure Container Apps Environment and associated workspaces
module "compute" {
  source = "../../modules/compute"

  project_prefix             = var.project_prefix
  environment                = var.environment
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = module.shared.log_analytics_workspace_id
  subnet_id                  = module.shared.subnet_compute_id

  depends_on = [module.shared]
}

# --- Tier 4: Application Workloads Layer ---
# Provisions Container Apps (GymCore API, GymCore Frontend, GameNest Sidecar)
# Orchestrates connections between managed identities, database endpoints, and external secrets
module "apps" {
  source = "../../modules/apps"

  project_prefix               = var.project_prefix
  environment                  = var.environment
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = module.compute.container_app_environment_id
  container_registry_name      = module.shared.container_registry_name
  acr_pull_role_assignment_id  = module.shared.acr_pull_role_assignment_id
  aca_identity_id              = module.shared.aca_identity_id
  aca_identity_principal_id    = module.shared.aca_identity_principal_id
  key_vault_id                 = module.shared.key_vault_id
  postgres_fqdn                = module.database.postgres_server_fqdn
  postgres_admin_password      = module.database.postgres_admin_password
  stripe_secret_key            = var.stripe_secret_key
  stripe_webhook_secret        = var.stripe_webhook_secret
  deepseek_api_key             = var.deepseek_api_key

  depends_on = [module.compute, module.database]
}