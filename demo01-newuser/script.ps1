# Load environment variables from .env file
$envFile = Get-Content ".env" | ConvertFrom-StringData

# Create a new Azure AD user
az ad user create `
    --display-name "Huguinho" `
    --user-principal-name "huguinho@MngEnvMCAP222468.onmicrosoft.com" `
    --password $envFile.senha 

az ad group create `
    --display-name "desenvolvedores" `
    --mail-nickname "desenvolvedores"
    
az ad group member add `
    --group "desenvolvedores" `
    --member-id "$(az ad user show --id "huguinho@MngEnvMCAP222468.onmicrosoft.com" --query id -o tsv)"

