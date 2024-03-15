RESOURCE_GROUP="red-deployment"
# Deploy to a resource group
az deployment group create --resource-group $RESOURCE_GROUP --template-file ./deploy.bicep