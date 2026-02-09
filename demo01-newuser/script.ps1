# Load environment variables from .env file
$envFile = Get-Content ".env" | ConvertFrom-StringData

# Create a new Azure AD user
az ad user create `
    --display-name "Zezinho" `
    --user-principal-name "zezinho@MngEnvMCAP222468.onmicrosoft.com" `
    --password $envFile.senha `
    --department "fabricadesoftware"

az ad group create `
    --display-name "desenvolvedores" `
    --mail-nickname "desenvolvedores"
    
az ad group member add `
    --group "desenvolvedores" `
    --member-id "$(az ad user show --id "zezinho@MngEnvMCAP222468.onmicrosoft.com" --query id -o tsv)"


az ad group create `
    --display-name "fabrica" `
    --mail-nickname "fabrica" `
    --dynamic-membership-rule "user.department -eq ""fabricadesoftware""" `
    --enable-dynamic-membership