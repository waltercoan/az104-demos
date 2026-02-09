
# Demo04 - VNet

## Linha 4: Criar Grupo de Recursos
```powershell
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"
```
Cria um grupo de recursos Azure chamado `rg-az104-test-brazilsouth-01` na região `brazilsouth`. O grupo de recursos é um contêiner lógico para gerenciar recursos relacionados.

## Linha 6-8: Criar Rede Virtual
```powershell
az network vnet create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "vnet-az104-test-brazilsouth-01" --address-prefix "10.0.0.0/16" `
    --subnet-name "Default" --subnet-prefix "10.0.0.0/24"
```
Cria uma rede virtual com espaço de endereço `10.0.0.0/16` e uma sub-rede padrão com `10.0.0.0/24`.

## Linha 10-11: Criar Grupo de Segurança de Rede
```powershell
az network nsg create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "nsg-az104-test-brazilsouth-01"
```
Cria um Grupo de Segurança de Rede (NSG) para controlar e filtrar o tráfego de entrada e saída.

## Linha 13-16: Associar NSG à Sub-rede
```powershell
az network vnet subnet update --resource-group "rg-az104-test-brazilsouth-01" `
    --vnet-name "vnet-az104-test-brazilsouth-01" `
    --name "Default" `
    --network-security-group "nsg-az104-test-brazilsouth-01"
```
Associa o grupo de segurança de rede à sub-rede `Default`, aplicando suas regras de firewall.
