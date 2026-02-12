# Create an Azure Resource Group
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"

# Create an Azure Container Registry
az acr create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "acraz104testbrazilsouth01" `
    --sku Basic

cd demo09-webapp-continst-contapp\myapp

az acr build --registry acraz104testbrazilsouth01 `
 --image myapp:v1 .

# Create an Azure Container Instance
az container create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "aci-az104-test-brazilsouth-02" `
    --image "acraz104testbrazilsouth01.azurecr.io/myapp:v1" `
    --os-type Linux `
    --ports 80 `
    --ip-address public `
    --cpu 1 `
    --memory 1