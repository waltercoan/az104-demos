# Demo 08 - Virtual Machine e Virtual Machine Scale Set

![Virtual Machine e Virtual Machine Scale Set](../imgs/diag-demo08.png)

## Criar um Grupo de Recursos do Azure

```powershell
# Load environment variables from .env file
$envFile = Get-Content ".env" | ConvertFrom-StringData

az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"
```
Cria um grupo de recursos chamado `rg-az104-test-brazilsouth-01` na região de Brasil (Sul) para organizar todos os recursos.

## Criar uma Rede Virtual

```powershell
az network vnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vnet-az104-test-brazilsouth-01" --address-prefix "10.0.0.0/16" `
    --subnet-name "Default" --subnet-prefix "10.0.0.0/24"
```
Cria uma rede virtual com espaço de endereço 10.0.0.0/16 e uma sub-rede padrão com prefixo 10.0.0.0/24.

## Criar um Grupo de Segurança de Rede

```powershell
az network nsg create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nsg-az104-test-brazilsouth-01"
```
Cria um grupo de segurança de rede para controlar o tráfego de entrada e saída da máquina virtual.

## Obter o Endereço IP Público Local

```powershell
$myPublicIp = (Invoke-WebRequest -Uri "https://api.ipify.org?format=json" | ConvertFrom-Json).ip
```
Obtém o endereço IP público da máquina local para permitir acesso SSH apenas dessa origem.

## Adicionar Regra SSH ao NSG

```powershell
az network nsg rule create --resource-group "rg-az104-test-brazilsouth-01" `
    --nsg-name "nsg-az104-test-brazilsouth-01" --name "AllowSSH" `
    --priority 1000 --source-address-prefixes "$myPublicIp/32" --destination-port-ranges 22 `
    --access Allow --protocol Tcp
```
Adiciona uma regra que permite conexões SSH (porta 22) apenas do seu IP público.

## Criar um Endereço IP Público

```powershell
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-01"
```
Cria um endereço IP público para ser associado à máquina virtual Linux.

## Criar uma Interface de Rede

```powershell
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-az104-test-brazilsouth-01" --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "Default" --public-ip-address "pip-az104-test-brazilsouth-01" `
    --network-security-group "nsg-az104-test-brazilsouth-01"
```
Cria uma interface de rede conectada à rede virtual, sub-rede padrão, IP público e grupo de segurança.

## Criar uma Máquina Virtual Linux

```powershell
az vm create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vm-az104-test-brazilsouth-01" --nics "nic-az104-test-brazilsouth-01" `
    --image Ubuntu2404 --admin-username azureuser --admin-password $envFile.senha `
    --size Standard_D2as_v6
```
Cria uma máquina virtual Linux com Ubuntu 24.04 e tamanho Standard_D2as_v6.

## Obter o IP Público da VM

```powershell
az network public-ip show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-01" --query "ipAddress" --output tsv
```
Exibe o endereço IP público atribuído à máquina virtual para acesso remoto.

## Criar uma Sub-rede para VMSS

```powershell
az network vnet subnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" --name "vmss-subnet" `
    --address-prefix "10.0.1.0/24"
```
Cria uma sub-rede dedicada para o conjunto de dimensionamento de máquinas virtuais.

## Criar NSG para VMSS

```powershell
az network nsg create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nsg-vmss-az104-test-brazilsouth-01"
```
Cria um grupo de segurança de rede específico para controlar o tráfego do VMSS.

## Criar IP Público para NAT Gateway

```powershell
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-natgw-az104-test-brazilsouth-01" --sku "Standard"
```
Cria um endereço IP público padrão para ser usado pelo NAT Gateway.

## Criar NAT Gateway

```powershell
az network nat gateway create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "natgw-az104-test-brazilsouth-01" `
    --public-ip-addresses "pip-natgw-az104-test-brazilsouth-01"
```
Cria um gateway NAT para permitir que VMs no VMSS acessem a internet com um IP público único.

## Associar NAT Gateway à Sub-rede

```powershell
az network vnet subnet update --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --name "vmss-subnet" `
    --nat-gateway "natgw-az104-test-brazilsouth-01"
```
Vincula o NAT Gateway à sub-rede do VMSS para roteamento de tráfego.

## Criar Regra NSG para HTTP

```powershell
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
```
Adiciona uma regra que permite tráfego HTTP (porta 80) de qualquer origem para o VMSS.

## Associar NSG à Sub-rede VMSS

```powershell
az network vnet subnet update --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --name "vmss-subnet" `
    --network-security-group "nsg-vmss-az104-test-brazilsouth-01"
```
Vincula o grupo de segurança de rede à sub-rede do VMSS.

## Criar Virtual Machine Scale Set

```powershell
az vmss create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vmss-az104-test-brazilsouth-01" --image Ubuntu2404 `
    --instance-count 2 --admin-username azureuser `
    --admin-password $envFile.senha --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "vmss-subnet" --nsg "nsg-vmss-az104-test-brazilsouth-01" `
    --backend-port 80 `
    --custom-data .\demo08-vm-vmss\cloudinit.yml `
    --vm-sku Standard_D2as_v6
```
Cria um conjunto de dimensionamento com 2 instâncias Ubuntu 24.04 na sub-rede VMSS com configuração inicial via cloud-init.
