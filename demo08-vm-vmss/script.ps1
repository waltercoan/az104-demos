# Load environment variables from .env file
$envFile = Get-Content ".env" | ConvertFrom-StringData

# Create an Azure Resource Group
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"

# Create a Virtual Network in the Resource Group
az network vnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vnet-az104-test-brazilsouth-01" --address-prefix "10.0.0.0/16" `
    --subnet-name "Default" --subnet-prefix "10.0.0.0/24"
    
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
    --image Ubuntu2404 --admin-username azureuser --admin-password $envFile.senha `
    --size Standard_D2as_v6

# Get the public IP of the first VM
az network public-ip show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-01" --query "ipAddress" --output tsv
    
################################################
#### VMSS Linux                   
################################################

# Create a subnet for VMSS
az network vnet subnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" --name "vmss-subnet" `
    --address-prefix "10.0.1.0/24"

# Create a Network Security Group for VMSS
az network nsg create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nsg-vmss-az104-test-brazilsouth-01"

# Create a Public IP for NAT Gateway
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-natgw-az104-test-brazilsouth-01" --sku "Standard"

# Create NAT Gateway
az network nat gateway create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "natgw-az104-test-brazilsouth-01" `
    --public-ip-addresses "pip-natgw-az104-test-brazilsouth-01"

# Associate NAT Gateway with the subnet
az network vnet subnet update --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --name "vmss-subnet" `
    --nat-gateway "natgw-az104-test-brazilsouth-01"

# Create NSG rule to allow port 80 from internet
az network nsg rule create --resource-group "rg-az104-test-brazilsouth-01" `
    --nsg-name "nsg-vmss-az104-test-brazilsouth-01" `
    --name "AllowHTTP" `
    --priority 100 `
    --direction Inbound `
    --access Allow `
    --protocol Tcp `
    --source-address-prefixes "*" `
    --destination-address-prefixes "*" `
    --source-port-ranges "*" `
    --destination-port-ranges 80

# Associate NSG with subnet
az network vnet subnet update --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --name "vmss-subnet" `
    --network-security-group "nsg-vmss-az104-test-brazilsouth-01"


# Create VMSS without public IPs
az vmss create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vmss-az104-test-brazilsouth-01" --image Ubuntu2404 `
    --instance-count 2 --admin-username azureuser `
    --admin-password $envFile.senha --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "vmss-subnet" --nsg "nsg-vmss-az104-test-brazilsouth-01" `
    --backend-port 80 `
    --custom-data .\demo08-vm-vmss\cloudinit.yml `
    --vm-sku Standard_D2as_v6