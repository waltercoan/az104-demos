# Demo10 - Data Protection

## Documentação do Script

### Criação do Grupo de Recursos
```powershell
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"
```
Cria um grupo de recursos no Azure na região Brasil Sul para organizar todos os recursos da demonstração.

### Criação da Conta de Armazenamento
```powershell
az storage account create `
    --name "staz104testbs01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --location "brazilsouth" --sku Standard_LRS
```
Cria uma conta de armazenamento com replicação LRS (armazenamento redundante local) para armazenar dados.

### Criação da Rede Virtual
```powershell
az network vnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vnet-az104-test-brazilsouth-01" --address-prefix "10.0.0.0/16" `
    --subnet-name "Default" --subnet-prefix "10.0.0.0/24"
```
Cria uma rede virtual com espaço de endereço 10.0.0.0/16 e uma sub-rede padrão.

### Criação do Grupo de Segurança de Rede
```powershell
az network nsg create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nsg-az104-test-brazilsouth-01"
```
Cria um Grupo de Segurança de Rede para gerenciar regras de firewall.

### Obtenção do IP Público Local
```powershell
$myPublicIp = (Invoke-WebRequest -Uri "https://api.ipify.org?format=json" | ConvertFrom-Json).ip
```
Recupera o endereço IP público da máquina local para criar regras de acesso seguro.

### Criação de Regra para SSH
```powershell
az network nsg rule create --resource-group "rg-az104-test-brazilsouth-01" `
    --nsg-name "nsg-az104-test-brazilsouth-01" --name "AllowSSH" `
    --priority 1000 --source-address-prefixes "$myPublicIp/32" --destination-port-ranges 22 `
    --access Allow --protocol Tcp
```
Cria uma regra permitindo acesso SSH apenas do IP público local na porta 22.

### Criação do IP Público
```powershell
az network public-ip create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-01"
```
Cria um endereço IP público para associar à máquina virtual.

### Criação da Interface de Rede
```powershell
az network nic create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nic-az104-test-brazilsouth-01" --vnet-name "vnet-az104-test-brazilsouth-01" `
    --subnet "Default" --public-ip-address "pip-az104-test-brazilsouth-01" `
    --network-security-group "nsg-az104-test-brazilsouth-01"
```
Cria uma interface de rede conectada à rede virtual, ao IP público e ao grupo de segurança.

### Criação da Máquina Virtual
```powershell
az vm create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vm-az104-test-brazilsouth-01" --nics "nic-az104-test-brazilsouth-01" `
    --image Ubuntu2404 --admin-username azureuser --admin-password $envFile.senha `
    --size Standard_D2as_v6 --enable-secure-boot false --enable-vtpm false
```
Cria uma máquina virtual Linux com Ubuntu 24.04, tamanho Standard_D2as_v6 e desativa recursos de segurança específicos.

### Exibição do IP Público
```powershell
az network public-ip show --resource-group "rg-az104-test-brazilsouth-01" `
    --name "pip-az104-test-brazilsouth-01" --query "ipAddress" --output tsv
```
Recupera e exibe o endereço IP público atribuído à máquina virtual para conexão remota.