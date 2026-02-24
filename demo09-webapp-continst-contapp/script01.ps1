# Create an Azure Resource Group
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"

# Create an App Service Plan with F1 SKU on Windows
az appservice plan create --name "asp-az104-test-brazilsouth-01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --sku S1

# Create a Web App with .NET runtime
az webapp create --resource-group "rg-az104-test-brazilsouth-01" `
    --plan "asp-az104-test-brazilsouth-01" `
    --name "app-az104-test-brazilsouth-01" `
    --runtime "dotnet:10"

cd demo09-webapp-continst-contapp
mkdir myapp
cd myapp
dotnet new blazor

# Remove previous publish output to avoid stale files causing BLAZOR106
if (Test-Path .\publish) {
    Remove-Item -Recurse -Force .\publish
}

dotnet publish -c Release -o ./publish
cd .\publish\

az webapp up --resource-group "rg-az104-test-brazilsouth-01" `
    --name "app-az104-test-brazilsouth-01" `
    --plan "asp-az104-test-brazilsouth-01" `
    --runtime "dotnet:10" 


# Criar um novo deployment slot chamado "teste"
az webapp deployment slot create --name "app-az104-test-brazilsouth-01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --slot "teste"

cd ..

# Remove previous publish output to avoid stale files causing BLAZOR106
if (Test-Path .\publish) {
    Remove-Item -Recurse -Force .\publish
}

dotnet publish -c Release -o ./publish
cd .\publish\

cd ..
Compress-Archive -Path .\publish\* -DestinationPath .\app.zip -Force

az webapp deployment source config-zip `
    --name "app-az104-test-brazilsouth-01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --slot "teste" `
    --src app.zip