# Configures Terraform version and required providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }

  # Remote state configuration mapped to Azure Storage Account
  backend "azurerm" {
    resource_group_name  = "rg-mthub-core"
    storage_account_name = "stmthubtfstate14856" # Storage account must be pre-provisioned via scripts/bootstrap-state.sh
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

# Configures the Azure Resource Manager provider
provider "azurerm" {
  features {
    # Ensures Key Vault secrets can be fully purged or recovered during environment teardown/rebuild
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
  }
}