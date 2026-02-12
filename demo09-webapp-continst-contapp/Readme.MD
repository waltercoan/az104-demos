# Demo09 - Web App - Container Instance - Container App

## Web App

### Criar Grupo de Recursos
```powershell
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"
```
Cria um grupo de recursos no Azure na região Brasil Sul para organizar os recursos da aplicação.

### Criar Plano de Serviço de Aplicativo
```powershell
az appservice plan create --name "asp-az104-test-brazilsouth-01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --sku F1
```
Define um plano de App Service com SKU F1 (camada gratuita) no Linux para hospedar a aplicação web.

### Criar Aplicativo Web
```powershell
az webapp create --resource-group "rg-az104-test-brazilsouth-01" `
    --plan "asp-az104-test-brazilsouth-01" `
    --name "app-az104-test-brazilsouth-01" `
    --runtime "dotnet:10"
```
Cria uma aplicação web com runtime .NET 10 associada ao plano de serviço criado.

### Navegar e Criar Diretório
```powershell
cd demo09-webapp-continst-contapp
mkdir myapp
cd myapp
```
Navega para o diretório do demo e cria uma nova pasta para a aplicação.

### Criar Projeto Blazor
```powershell
dotnet new blazor
```
Gera um novo projeto Blazor como template inicial.

### Publicar Aplicação
```powershell
dotnet publish -c Release -o ./publish
```
Compila e publica a aplicação em modo Release na pasta publish.

### Implantar no Azure
```powershell
cd .\publish\
az webapp up --resource-group "rg-az104-test-brazilsouth-01" `
    --name "app-az104-test-brazilsouth-01" `
    --plan "asp-az104-test-brazilsouth-01" `
    --runtime "dotnet:10"
```
Acessa a pasta publicada e faz deploy da aplicação para a web app do Azure.

## Docker file

```bash
# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:latest AS build
WORKDIR /src

# Copy project files
COPY ["myapp.csproj", "./"]

# Restore dependencies
RUN dotnet restore "myapp.csproj"

# Copy source code
COPY . .

# Build the application
RUN dotnet build "myapp.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "myapp.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:latest AS runtime
WORKDIR /app

# Copy published application from publish stage
COPY --from=publish /app/publish .

# Expose port
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Start application
ENTRYPOINT ["dotnet", "myapp.dll"]
```

## Container Registry

### Criar Container Registry
```powershell
az acr create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "acraz104testbrazilsouth01" `
    --sku Basic
```

### Build de uma apliação .NET usando o ACR
```powershell
cd demo09-webapp-continst-contapp\myapp

az acr build --registry acraz104testbrazilsouth01 `
 --image myapp:v1 .
```

## Container Instance

### Criar Grupo de Recursos
```powershell
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"
```
Cria um grupo de recursos no Azure na região Brasil Sul para organizar os recursos da instância de contêiner.

### Criar Instância de Contêiner
```powershell
az container create --resource-group "rg-az104-test-brazilsouth-01" `
    --name "aci-az104-test-brazilsouth-01" `
    --image "mcr.microsoft.com/azuredocs/aci-helloworld:latest" `
    --os-type Linux `
    --ports 80 `
    --ip-address public `
    --cpu 1 `
    --memory 1
```
Cria uma instância de contêiner Azure com a imagem hello-world, configurando-a para executar em Linux com 1 CPU, 1GB de memória, acesso público na porta 80 e nome específico no grupo de recursos.


## Container App

### Criar Grupo de Recursos
```powershell
az group create --name "rg-az104-test-brazilsouth-01" --location "brazilsouth"
```
Cria um grupo de recursos no Azure na região Brasil Sul para organizar os recursos da aplicação em contêiner.

### Criar Ambiente de Container Apps
```powershell
az containerapp env create --name "cae-az104-test-brazilsouth-01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --location "brazilsouth"
```
Cria um ambiente de Container Apps que fornece a infraestrutura compartilhada necessária para executar aplicações em contêiner gerenciadas.

### Criar Aplicação em Contêiner
```powershell
az containerapp create --name "ca-az104-test-brazilsouth-01" `
    --resource-group "rg-az104-test-brazilsouth-01" `
    --environment "cae-az104-test-brazilsouth-01" `
    --image "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest" `
    --target-port 80 `
    --ingress 'external' `
    --query properties.configuration.ingress.fqdn
```
Cria uma aplicação em contêiner usando a imagem hello-world, configurando-a para usar a porta 80, permitir acesso externo via ingress e retornar o FQDN (nome de domínio totalmente qualificado) para acesso público.