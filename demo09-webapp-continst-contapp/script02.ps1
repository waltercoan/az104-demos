# Create an Azure Resource Group
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"

# Create an Azure Container Instance
az container create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "aci-az104-test-brazilsouth-01" `
    --image "mcr.microsoft.com/azuredocs/aci-helloworld:latest" `
    --os-type Linux `
    --ports 80 `
    --ip-address public `
    --cpu 1 `
    --memory 1