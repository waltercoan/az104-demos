# Demo 06 - Network Load Balancer e Application Gateway

![Network Load Balancer e Application Gateway Diagram](../imgs/diag-demo06.png)

## Criar um Grupo de Recursos do Azure

```powershell
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"
```

Cria um novo grupo de recursos no Azure na região Brazil South. Este grupo servirá como contêiner para todos os recursos que serão criados nesta demonstração.

## Criar uma Rede Virtual

```powershell
az network vnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vnet-az104-test-brazilsouth-01" --address-prefix "10.0.0.0/16" `
    --subnet-name "Default" --subnet-prefix "10.0.0.0/24"
```

Cria uma rede virtual com espaço de endereçamento 10.0.0.0/16 e uma sub-rede padrão com intervalo 10.0.0.0/24. Esta rede virtual será usada para conectar todas as máquinas virtuais.

## Criar um IP Público para NAT Gateway

```powershell
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-natgw-az104-test-brazilsouth-01" --sku "Standard"
```

Cria um endereço IP público com SKU Standard que será associado ao NAT Gateway para permitir que as máquinas virtuais acessem a internet.

## Criar um NAT Gateway

```powershell
az network nat gateway create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "natgw-az104-test-brazilsouth-01" `
    --public-ip-addresses "pip-natgw-az104-test-brazilsouth-01"
```

Cria um NAT Gateway que permite que as máquinas virtuais na rede virtual acessem a internet através do IP público criado anteriormente.

## Associar NAT Gateway à Sub-rede

```powershell
az network vnet subnet update --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --name "Default" `
    --nat-gateway "natgw-az104-test-brazilsouth-01"
```

Associa o NAT Gateway à sub-rede padrão, permitindo que as máquinas virtuais desta sub-rede usem o NAT Gateway para comunicação com a internet.

## Criar Grupo de Segurança de Rede

```powershell
az network nsg create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nsg-az104-test-brazilsouth-01"
```

Cria um Grupo de Segurança de Rede (NSG) que servirá para gerenciar as regras de firewall e controlar o tráfego de rede.

## Criar Regra NSG para Permite HTTP

```powershell
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
```

Cria uma regra no NSG que permite tráfego HTTP (porta 80) vindo de qualquer origem para qualquer destino com prioridade 100.

## Associar NSG à Sub-rede

```powershell
az network vnet subnet update --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --name "Default" `
    --network-security-group "nsg-az104-test-brazilsouth-01"
```

Associa o NSG à sub-rede padrão, aplicando as regras de firewall a todos os recursos conectados nesta sub-rede.

## Criar Primeira Interface de Rede

```powershell
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-vm-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "Default"
```

Cria uma interface de rede para a primeira máquina virtual. Esta interface não terá IP público, apenas um IP privado da rede virtual.

## Criar Segunda Interface de Rede

```powershell
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-vm-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "Default"
```

Cria uma segunda interface de rede para outra máquina virtual, também sem IP público.

## Criar Primeira Máquina Virtual

```powershell
az vm create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vm-az104-test-brazilsouth-01" `
    --nics "nic-vm-az104-test-brazilsouth-01" `
    --image "Ubuntu2404" `
    --size Standard_D2as_v6 `
    --admin-username azureuser --admin-password $envFile.senha `
    --custom-data .\demo06-nettraffic\cloudinit.yml
```

Cria a primeira máquina virtual Ubuntu 24.04 usando a interface de rede criada, com configurações iniciais via cloud-init script.

## Criar Terceira Interface de Rede

```powershell
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-vm-az104-test-brazilsouth-02" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "Default"
```

Cria uma terceira interface de rede para a segunda máquina virtual.

## Criar Segunda Máquina Virtual

```powershell
az vm create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vm-az104-test-brazilsouth-02" `
    --nics "nic-vm-az104-test-brazilsouth-02" `
    --image "Ubuntu2404" `
    --size Standard_D2as_v6 `
    --admin-username azureuser --admin-password $envFile.senha `
    --custom-data .\demo06-nettraffic\cloudinit.yml
```

Cria a segunda máquina virtual Ubuntu 24.04 com configurações similares à primeira.

## Obter IP Privado da Primeira Máquina Virtual

```powershell
$vm1_private_ip = az network nic show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-vm-az104-test-brazilsouth-01" --query "ipConfigurations[0].privateIPAddress" -o tsv
```

Recupera o endereço IP privado da primeira máquina virtual e armazena em uma variável.

## Obter IP Privado da Segunda Máquina Virtual

```powershell
$vm2_private_ip = az network nic show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-vm-az104-test-brazilsouth-02" --query "ipConfigurations[0].privateIPAddress" -o tsv
```

Recupera o endereço IP privado da segunda máquina virtual e armazena em uma variável.

## Exibir IPs Privados

```powershell
Write-Host "VM1 Private IP: $vm1_private_ip"
Write-Host "VM2 Private IP: $vm2_private_ip"
```

Exibe os IPs privados de ambas as máquinas virtuais no console.

## Criar IP Público para Load Balancer

```powershell
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-lb-az104-test-brazilsouth-01" --sku "Standard"
```

Cria um endereço IP público que será usado pelo Load Balancer para receber tráfego da internet.

## Criar Load Balancer

```powershell
az network lb create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "lb-az104-test-brazilsouth-01" `
    --sku "Standard" `
    --public-ip-address "pip-lb-az104-test-brazilsouth-01" `
    --frontend-ip-name "lb-frontend" `
    --backend-pool-name "lb-backend"
```

Cria um Load Balancer com SKU Standard, associado ao IP público, com uma configuração frontend e backend pool.

## Criar Health Probe

```powershell
az network lb probe create --resource-group "rg-az104-test-brazilsouth-01" `
    --lb-name "lb-az104-test-brazilsouth-01" `
    --name "health-probe" `
    --protocol "http" --port 80 --path "/"
```

Cria um health probe que monitora a saúde das máquinas virtuais verificando a porta 80 periodicamente.

## Criar Regra de Load Balancing

```powershell
az network lb rule create --resource-group "rg-az104-test-brazilsouth-01" `
    --lb-name "lb-az104-test-brazilsouth-01" `
    --name "lb-rule" `
    --protocol "tcp" --frontend-port 80 --backend-port 80 `
    --frontend-ip-name "lb-frontend" `
    --backend-pool-name "lb-backend" `
    --probe-name "health-probe"
```

Cria uma regra que distribui o tráfego na porta 80 do frontend para as máquinas virtuais no backend usando o health probe criado.

## Adicionar Primeira NIC ao Backend Pool

```powershell
az network nic ip-config address-pool add --resource-group "rg-az104-test-brazilsouth-01" `
    --nic-name "nic-vm-az104-test-brazilsouth-01" `
    --ip-config-name "ipconfig1" `
    --lb-name "lb-az104-test-brazilsouth-01" `
    --address-pool "lb-backend"
```

Adiciona a primeira interface de rede ao backend pool do Load Balancer.

## Adicionar Segunda NIC ao Backend Pool

```powershell
az network nic ip-config address-pool add --resource-group "rg-az104-test-brazilsouth-01" `
    --nic-name "nic-vm-az104-test-brazilsouth-02" `
    --ip-config-name "ipconfig1" `
    --lb-name "lb-az104-test-brazilsouth-01" `
    --address-pool "lb-backend"
```

Adiciona a segunda interface de rede ao backend pool do Load Balancer.

## Obter IP Público do Load Balancer

```powershell
az network public-ip show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-lb-az104-test-brazilsouth-01" --query "ipAddress" -o tsv
```

Recupera e exibe o endereço IP público do Load Balancer.

## Criar IP Público para Application Gateway

```powershell
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-agw-az104-test-brazilsouth-01" --sku "Standard"
```

Cria um endereço IP público que será usado pelo Application Gateway.

## Criar Regra NSG para Range de Portas

```powershell
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
```

Cria uma regra NSG que permite tráfego nas portas 65200-65535, necessárias para o funcionamento do Application Gateway.

## Criar Sub-rede para Application Gateway

```powershell
az network vnet subnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --name "subnet-agw" `
    --address-prefix "10.0.1.0/24" `
    --network-security-group "nsg-az104-test-brazilsouth-01"
```

Cria uma nova sub-rede dedicada ao Application Gateway com intervalo de IP 10.0.1.0/24.

## Criar Application Gateway

```powershell
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
```

Cria um Application Gateway Standard v2 com capacidade para 2 instâncias, que irá distribuir tráfego HTTP para as máquinas virtuais backend.

## Obter IP Público do Application Gateway

```powershell
az network public-ip show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-agw-az104-test-brazilsouth-01" --query "ipAddress" -o tsv
```

Recupera e exibe o endereço IP público do Application Gateway.
