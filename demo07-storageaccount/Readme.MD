# Demo07 - Storage Account

## Criar Grupo de Recursos

```powershell
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"
```

Cria um grupo de recursos no Azure na região Brazil South. O grupo de recursos é um contêiner que mantém recursos relacionados.

## Criar Conta de Armazenamento

```powershell
az storage account create `
    --name "stdaz104testbr01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --location "brazilsouth" `
    --sku "Standard_LRS" `
    --kind "StorageV2"
```

Cria uma conta de armazenamento padrão v2 com replicação localmente redundante (LRS) no grupo de recursos criado anteriormente.

## Criar Container

```powershell
az storage container create `
    --auth-mode login `
    --name "imagens" `
    --account-name "stdaz104testbr01"
```

Cria um contêiner denominado "imagens" na conta de armazenamento usando autenticação por login.

## Exibir Ajuda do AzCopy

```powershell
azcopy --help
```

Exibe a documentação de ajuda da ferramenta AzCopy.

## Fazer Login com AzCopy

```powershell
azcopy login
```

Autentica o usuário para usar AzCopy com a conta Azure.

## Copiar Arquivos PNG

```powershell
azcopy copy "imgs/*.png" "https://stdaz104testbr01.blob.core.windows.net/imagens" --recursive
```

Copia recursivamente todos os arquivos PNG da pasta local "imgs" para o contêiner "imagens" no blob storage.

## Listar Blobs do Container

```powershell
az storage blob list `
    --auth-mode login `
    --container-name "imagens" `
    --account-name "stdaz104testbr01" `
    --output table
```

Lista todos os blobs no contêiner "imagens" em formato de tabela. **Nota**: Este comando pode gerar erro de permissão dependendo das permissões RBAC atribuídas.
