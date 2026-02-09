# Demo 06 - Network Peering

![Network Peering](../imgs/diag-demo05.png)

## Script de Configuração de VNet Peering

### Carregar variáveis de ambiente
```powershell
$envFile = Get-Content ".env" | ConvertFrom-StringData
```
Lê o arquivo `.env` e converte seu conteúdo em uma tabela hash para acessar variáveis de ambiente como senhas.

### Criar Grupo de Recursos
```powershell
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"
```
Cria um grupo de recursos no Azure na região de Brazil South para organizar todos os recursos.

### Criar primeira rede virtual
```powershell
az network vnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vnet-az104-test-brazilsouth-01" --address-prefix "10.0.0.0/16" `
    --subnet-name "Default" --subnet-prefix "10.0.0.0/24"
```
Cria a primeira rede virtual com espaço de endereço 10.0.0.0/16 e uma sub-rede padrão.

### Criar segunda rede virtual
```powershell
az network vnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vnet-az104-test-brazilsouth-02" --address-prefix "10.1.0.0/16" `
    --subnet-name "Default" --subnet-prefix "10.1.0.0/24"
```
Cria a segunda rede virtual com espaço de endereço 10.1.0.0/16 para demonstrar peering entre redes.

### Criar Grupo de Segurança de Rede
```powershell
az network nsg create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nsg-az104-test-brazilsouth-01"
```
Cria um grupo de segurança de rede para controlar o tráfego de entrada e saída das máquinas virtuais.

### Obter seu IP público
```powershell
$myPublicIp = (Invoke-WebRequest -Uri "https://api.ipify.org?format=json" | ConvertFrom-Json).ip
```
Consulta um serviço externo para obter o IP público da máquina local e armazena em uma variável.

### Adicionar regra SSH
```powershell
az network nsg rule create --resource-group "rg-az104-test-brazilsouth-01" `
    --nsg-name "nsg-az104-test-brazilsouth-01" --name "AllowSSH" `
    --priority 1000 --source-address-prefixes "$myPublicIp/32" --destination-port-ranges 22 `
    --access Allow --protocol Tcp
```
Cria uma regra de segurança permitindo conexões SSH (porta 22) apenas do seu IP público.

### Criar IP público para primeira VM
```powershell
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-01"
```
Aloca um endereço IP público para associar à primeira máquina virtual.

### Criar interface de rede para primeira VM
```powershell
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-az104-test-brazilsouth-01" --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "Default" --public-ip-address "pip-az104-test-brazilsouth-01" `
    --network-security-group "nsg-az104-test-brazilsouth-01"
```
Cria uma interface de rede conectada à primeira VNet com IP público e grupo de segurança.

### Criar primeira máquina virtual Linux
```powershell
az vm create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vm-az104-test-brazilsouth-01" --nics "nic-az104-test-brazilsouth-01" `
    --image Ubuntu2404 --admin-username azureuser --admin-password $envFile.senha `
    --size Standard_D2as_v6
```
Cria a primeira máquina virtual Ubuntu com a interface de rede configurada.

### Obter IP público da primeira VM
```powershell
az network public-ip show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-01" --query "ipAddress" --output tsv
```
Exibe o endereço IP público atribuído à primeira máquina virtual.

### Criar IP público para segunda VM
```powershell
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-02"
```
Aloca um endereço IP público para a segunda máquina virtual.

### Criar interface de rede para segunda VM
```powershell
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-az104-test-brazilsouth-02" --vnet-name "vnet-az104-test-brazilsouth-02" `
    --subnet "Default" --public-ip-address "pip-az104-test-brazilsouth-02" `
    --network-security-group "nsg-az104-test-brazilsouth-01"
```
Cria uma interface de rede conectada à segunda VNet com seu próprio IP público.

### Criar segunda máquina virtual Linux
```powershell
az vm create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vm-az104-test-brazilsouth-02" --nics "nic-az104-test-brazilsouth-02" `
    --image Ubuntu2404 --admin-username azureuser --admin-password $envFile.senha `
    --size Standard_D2as_v6
```
Cria a segunda máquina virtual Ubuntu na segunda rede virtual.

### Obter IP público da segunda VM
```powershell
az network public-ip show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-02" --query "ipAddress" --output tsv
```
Exibe o endereço IP público atribuído à segunda máquina virtual.

### Criar peering de VNet 1 para VNet 2
```powershell
az network vnet peering create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "peering-vnet1-to-vnet2" --vnet-name "vnet-az104-test-brazilsouth-01" `
    --remote-vnet "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-az104-test-brazilsouth-01/providers/Microsoft.Network/virtualNetworks/vnet-az104-test-brazilsouth-02" `
    --allow-vnet-access
```
Estabelece uma conexão de peering da primeira rede virtual para a segunda, permitindo comunicação entre elas.

### Criar peering de VNet 2 para VNet 1
```powershell
az network vnet peering create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "peering-vnet2-to-vnet1" --vnet-name "vnet-az104-test-brazilsouth-02" `
    --remote-vnet "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-az104-test-brazilsouth-01/providers/Microsoft.Network/virtualNetworks/vnet-az104-test-brazilsouth-01" `
    --allow-vnet-access
```
Completa a conexão de peering bidirecional criando o peering inverso da segunda rede para a primeira.