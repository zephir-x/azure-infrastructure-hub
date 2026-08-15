# Production Environment

The `env/prod` directory is the target location for the production environment configuration. Following Infrastructure as Code (IaC) best practices and the DRY (Don't Repeat Yourself) concept, the production environment uses the exact same base modules defined in the `/modules` directory as the development environment (`env/dev`).

The difference lies solely in the input values passed in the `terraform.tfvars` file, which adjust service parameters to rigorous production requirements.

## Architectural Differences from the DEV Environment

The table below illustrates the key configuration differences that will be applied in the production environment via module variables:

| Infrastructure Component | DEV Environment (`env/dev`) | PROD Environment (`env/prod`) |
| :--- | :--- | :--- |
| **Azure Container Apps** | Scaling: 0 - 2 replicas (cost savings) | Scaling: 2 - 10 replicas (high availability) |
| **Database (PostgreSQL)** | SKU: Burstable (B1ms), no redundancy | SKU: General Purpose, zonal redundancy enabled (Zone-Redundant HA) |
| **Azure Container Registry** | SKU: Basic | SKU: Premium (image geo-replication) |
| **Network Access (NSG)** | Selected ports open for easy debugging | Restrictive rules, access only through Azure Front Door/Application Gateway |
| **State Management** | State stored in the primary Storage Account | Storage Account with Resource Lock and object versioning |

## Usage

To deploy this environment, create a dedicated `terraform.tfvars` file in this directory and then perform the standard initialization process:

1. `terraform init`
2. `terraform workspace select prod` (or appropriate backend configuration)
3. `terraform plan -out=prod.tfplan`
4. `terraform apply prod.tfplan`