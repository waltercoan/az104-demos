
# Demo 01 - Criação de um usuário e criação de um grupo

## Carregar variáveis de ambiente

```powershell
$envFile = Get-Content ".env" | ConvertFrom-StringData
```

Lê o arquivo `.env` e converte seu conteúdo em uma tabela hash, permitindo acessar variáveis de configuração como `$envFile.senha`.

## Criar novo usuário Azure AD

```powershell
az ad user create `
    --display-name "Zezinho" `
    --user-principal-name "zezinho@MngEnvMCAP222468.onmicrosoft.com" `
    --password $envFile.senha `
    --department "fabricadesoftware"
```

Cria um novo usuário no Azure AD com nome "Zezinho", define seu UPN, senha (carregada do `.env`) e departamento.

## Criar grupo "desenvolvedores"

```powershell
az ad group create `
    --display-name "desenvolvedores" `
    --mail-nickname "desenvolvedores"
```

Cria um grupo estático no Azure AD chamado "desenvolvedores" para organizar usuários.

## Adicionar usuário ao grupo

```powershell
az ad group member add `
    --group "desenvolvedores" `
    --member-id "$(az ad user show --id "zezinho@MngEnvMCAP222468.onmicrosoft.com" --query id -o tsv)"
```

Adiciona o usuário "Zezinho" ao grupo "desenvolvedores" usando seu ID único.

## Criar grupo dinâmico "fabrica"

```powershell
az ad group create `
    --display-name "fabrica" `
    --mail-nickname "fabrica" `
    --dynamic-membership-rule "user.department -eq ""fabricadesoftware""" `
    --enable-dynamic-membership
```

Cria um grupo dinâmico que automaticamente inclui todos os usuários cujo departamento é "fabricadesoftware".
