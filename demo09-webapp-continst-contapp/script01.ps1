# Create an Azure Resource Group
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"

# Create an App Service Plan with F1 SKU on Linux
az appservice plan create --name "asp-az104-test-brazilsouth-01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --sku F1

# Create a Web App with .NET runtime
az webapp create --resource-group "rg-az104-test-brazilsouth-01" `
    --plan "asp-az104-test-brazilsouth-01" `
    --name "app-az104-test-brazilsouth-01" `
    --runtime "dotnet:10"

cd demo09-webapp-continst-contapp
mkdir myapp
cd myapp
dotnet new blazor

dotnet publish -c Release -o ./publish
cd .\publish\
az webapp up --resource-group "rg-az104-test-brazilsouth-01" `
    --name "app-az104-test-brazilsouth-01" `
    --plan "asp-az104-test-brazilsouth-01" `
    --runtime "dotnet:10" 