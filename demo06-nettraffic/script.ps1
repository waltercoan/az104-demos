# Create an Azure Resource Group
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"

# Create a Virtual Network in the Resource Group
az network vnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vnet-az104-test-brazilsouth-01" --address-prefix "10.0.0.0/16" `
    --subnet-name "Default" --subnet-prefix "10.0.0.0/24"

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
    --name "Default" `
    --nat-gateway "natgw-az104-test-brazilsouth-01"

# Create Network Security Group
az network nsg create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nsg-az104-test-brazilsouth-01"

# Create NSG rule to allow port 80 from internet
az network nsg rule create --resource-group "rg-az104-test-brazilsouth-01" `
    --nsg-name "nsg-az104-test-brazilsouth-01" `
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
    --name "Default" `
    --network-security-group "nsg-az104-test-brazilsouth-01"

# Create a Network Interface without Public IP
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-vm-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "Default" 

# Create a second Network Interface without Public IP
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-vm-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "Default" 

# Create a Virtual Machine with cloud-init script
az vm create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vm-az104-test-brazilsouth-01" `
    --nics "nic-vm-az104-test-brazilsouth-01" `
    --image "Ubuntu2404" `
    --size Standard_D2as_v6 `
    --admin-username azureuser --admin-password "Password123!" `
    --custom-data .\demo06-nettraffic\cloudinit.yml

# Get Cloud Init LOG from a VM
#az vm run-command invoke --resource-group "rg-az104-test-brazilsouth-01" `
#    --name "vm-az104-test-brazilsouth-01" `
#    --command-id RunShellScript `
#    --scripts "cat /var/log/cloud-init.log" `
#    --query "value[0].message" -o tsv

# Create a second Network Interface without Public IP
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-vm-az104-test-brazilsouth-02" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "Default" 

# Create a Virtual Machine with cloud-init script
az vm create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vm-az104-test-brazilsouth-02" `
    --nics "nic-vm-az104-test-brazilsouth-02" `
    --image "Ubuntu2404" `
    --size Standard_D2as_v6 `
    --admin-username azureuser --admin-password "Password123!" `
    --custom-data .\demo06-nettraffic\cloudinit.yml


# Get the private IPs of both VMs
$vm1_private_ip = az network nic show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-vm-az104-test-brazilsouth-01" --query "ipConfigurations[0].privateIPAddress" -o tsv 
$vm2_private_ip = az network nic show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-vm-az104-test-brazilsouth-02" --query "ipConfigurations[0].privateIPAddress" -o tsv

Write-Host "VM1 Private IP: $vm1_private_ip"
Write-Host "VM2 Private IP: $vm2_private_ip"

# Create Public IP for Load Balancer
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-lb-az104-test-brazilsouth-01" --sku "Standard"

# Create Load Balancer
az network lb create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "lb-az104-test-brazilsouth-01" `
    --sku "Standard" `
    --public-ip-address "pip-lb-az104-test-brazilsouth-01" `
    --frontend-ip-name "lb-frontend" `
    --backend-pool-name "lb-backend"

# Create health probe
az network lb probe create --resource-group "rg-az104-test-brazilsouth-01" `
    --lb-name "lb-az104-test-brazilsouth-01" `
    --name "health-probe" `
    --protocol "http" --port 80 --path "/"

# Create load balancing rule
az network lb rule create --resource-group "rg-az104-test-brazilsouth-01" `
    --lb-name "lb-az104-test-brazilsouth-01" `
    --name "lb-rule" `
    --protocol "tcp" --frontend-port 80 --backend-port 80 `
    --frontend-ip-name "lb-frontend" `
    --backend-pool-name "lb-backend" `
    --probe-name "health-probe"

# Add NICs to backend pool
az network nic ip-config address-pool add --resource-group "rg-az104-test-brazilsouth-01" `
    --nic-name "nic-vm-az104-test-brazilsouth-01" `
    --ip-config-name "ipconfig1" `
    --lb-name "lb-az104-test-brazilsouth-01" `
    --address-pool "lb-backend"

az network nic ip-config address-pool add --resource-group "rg-az104-test-brazilsouth-01" `
    --nic-name "nic-vm-az104-test-brazilsouth-02" `
    --ip-config-name "ipconfig1" `
    --lb-name "lb-az104-test-brazilsouth-01" `
    --address-pool "lb-backend"

# Get and display the Load Balancer Public IP
az network public-ip show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-lb-az104-test-brazilsouth-01" --query "ipAddress" -o tsv


##########################################
#### Create Azure Application Gateway ####
##########################################

# Create Public IP for Application Gateway
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-agw-az104-test-brazilsouth-01" --sku "Standard"

# Create NSG rule to allow port range 65200-65535
az network nsg rule create --resource-group "rg-az104-test-brazilsouth-01" `
    --nsg-name "nsg-az104-test-brazilsouth-01" `
    --name "AllowPortRange" `
    --priority 101 `
    --direction Inbound `
    --access Allow `
    --protocol Tcp `
    --source-address-prefixes "*" `
    --destination-address-prefixes "*" `
    --source-port-ranges "*" `
    --destination-port-ranges "65200-65535"

# Create a new subnet for Application Gateway
az network vnet subnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --name "subnet-agw" `
    --address-prefix "10.0.1.0/24" `
    --network-security-group "nsg-az104-test-brazilsouth-01"

az network application-gateway create `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --name "agw-az104-test-brazilsouth-01" `
    --capacity 2 `
    --sku Standard_v2 `
    --priority 1001 `
    --http-settings-port 80 `
    --http-settings-protocol Http `
    --frontend-port 80 `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "subnet-agw" `
    --http-settings-cookie-based-affinity Disabled `
    --public-ip-address "pip-agw-az104-test-brazilsouth-01" `
    --servers "$vm1_private_ip" "$vm2_private_ip"

# Get and display the Load Balancer Public IP
az network public-ip show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-agw-az104-test-brazilsouth-01" --query "ipAddress" -o tsv
