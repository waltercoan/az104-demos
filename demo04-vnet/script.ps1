# Create an Azure Resource Group
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"

# Create a Virtual Network in the Resource Group
az network vnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vnet-az104-test-brazilsouth-01" --address-prefix "10.0.0.0/16" `
    --subnet-name "Default" --subnet-prefix "10.0.0.0/24"

# Create a Network Security Group
az network nsg create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nsg-az104-test-brazilsouth-01"
    
# Associate the NSG with the subnet
az network vnet subnet update --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --name "Default" `
    --network-security-group "nsg-az104-test-brazilsouth-01"
