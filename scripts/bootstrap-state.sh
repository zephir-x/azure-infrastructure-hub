# Configuration
REGION="polandcentral"
PROJECT_PREFIX="mthub"  # Multi-Tenant Hub
ENV="core"              # Core infrastructure shared across environments
RESOURCE_GROUP_NAME="rg-${PROJECT_PREFIX}-${ENV}"
STORAGE_ACCOUNT_NAME="st${PROJECT_PREFIX}tfstate$RANDOM"
CONTAINER_NAME="tfstate"

echo "Creating Resource Group: $RESOURCE_GROUP_NAME"
az group create --name $RESOURCE_GROUP_NAME --location $REGION

echo "Creating Storage Account: $STORAGE_ACCOUNT_NAME"
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $REGION \
  --sku Standard_LRS \
  --encryption-services blob

echo "Creating Blob Container: $CONTAINER_NAME"
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME

echo "========================================="
echo "State infrastructure provisioned."
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
echo "Container Name: $CONTAINER_NAME"
echo "========================================="