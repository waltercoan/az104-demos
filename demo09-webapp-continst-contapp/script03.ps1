# Create an Azure Resource Group
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"

# Create a Container Apps Environment
az containerapp env create --name "cae-az104-test-brazilsouth-01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --location "brazilsouth"

# Create a Container App
az containerapp create --name "ca-az104-test-brazilsouth-01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --environment "cae-az104-test-brazilsouth-01" `
    --image "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest" `
    --target-port 80 `
    --ingress 'external' `
    --query properties.configuration.ingress.fqdn