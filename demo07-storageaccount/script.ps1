# Create an Azure Resource Group
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"

# Create an Azure Storage Account (Standard v2)
az storage account create `
    --name "stdaz104testbr01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --location "brazilsouth" `
    --sku "Standard_LRS" `
    --kind "StorageV2"

# Create a container named "imagens" in the storage account
az storage container create `
    --auth-mode login `
    --name "imagens" `
    --account-name "stdaz104testbr01"

azcopy --help

azcopy login

# Copy a PNG file from local imgs folder to the storage container
azcopy copy "imgs/*.png" "https://stdaz104testbr01.blob.core.windows.net/imagens" --recursive

# List all files in the container
# DEVE DAR ERRO DE PERMISSAO
az storage blob list `
    --auth-mode login `
    --container-name "imagens" `
    --account-name "stdaz104testbr01" `
    --output table