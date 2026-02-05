# Create an Azure Resource Group
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"

# Create a Virtual Network in the Resource Group
az network vnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vnet-az104-test-brazilsouth-01" --address-prefix "10.0.0.0/16" `
    --subnet-name "Default" --subnet-prefix "10.0.0.0/24"
    
# Create a Virtual Network in the Resource Group
az network vnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vnet-az104-test-brazilsouth-02" --address-prefix "10.1.0.0/16" `
    --subnet-name "Default" --subnet-prefix "10.1.0.0/24"


################################################
#### Linux VM 1 in VNet 1                   
################################################

# Create a Network Security Group
az network nsg create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nsg-az104-test-brazilsouth-01"

# Get your public IP
$myPublicIp = (Invoke-WebRequest -Uri "https://api.ipify.org?format=json" | ConvertFrom-Json).ip

# Add rule to allow SSH (port 22) from your public IP
az network nsg rule create --resource-group "rg-az104-test-brazilsouth-01" `
    --nsg-name "nsg-az104-test-brazilsouth-01" --name "AllowSSH" `
    --priority 1000 --source-address-prefixes "$myPublicIp/32" --destination-port-ranges 22 `
    --access Allow --protocol Tcp

# Create a public IP
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-01"

# Create a network interface
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-az104-test-brazilsouth-01" --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "Default" --public-ip-address "pip-az104-test-brazilsouth-01" `
    --network-security-group "nsg-az104-test-brazilsouth-01"

# Create a Linux VM
az vm create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vm-az104-test-brazilsouth-01" --nics "nic-az104-test-brazilsouth-01" `
    --image Ubuntu2404 --admin-username azureuser --admin-password "Password123!" `
    --size Standard_D2as_v6

# Get the public IP of the first VM
az network public-ip show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-01" --query "ipAddress" --output tsv
    
################################################
#### Linux VM 2 in VNet 2                   
################################################

# Create a second public IP
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-02"

# Create a second network interface
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-az104-test-brazilsouth-02" --vnet-name "vnet-az104-test-brazilsouth-02" `
    --subnet "Default" --public-ip-address "pip-az104-test-brazilsouth-02" `
    --network-security-group "nsg-az104-test-brazilsouth-01"

# Create a second Linux VM
az vm create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vm-az104-test-brazilsouth-02" --nics "nic-az104-test-brazilsouth-02" `
    --image Ubuntu2404 --admin-username azureuser --admin-password "Password123!" `
    --size Standard_D2as_v6

# Get the public IP of the second VM
az network public-ip show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-02" --query "ipAddress" --output tsv


# Create VNet peering from VNet 1 to VNet 2
az network vnet peering create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "peering-vnet1-to-vnet2" --vnet-name "vnet-az104-test-brazilsouth-01" `
    --remote-vnet "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-az104-test-brazilsouth-01/providers/Microsoft.Network/virtualNetworks/vnet-az104-test-brazilsouth-02" `
    --allow-vnet-access

# Create VNet peering from VNet 2 to VNet 1
az network vnet peering create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "peering-vnet2-to-vnet1" --vnet-name "vnet-az104-test-brazilsouth-02" `
    --remote-vnet "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-az104-test-brazilsouth-01/providers/Microsoft.Network/virtualNetworks/vnet-az104-test-brazilsouth-01" `
    --allow-vnet-access