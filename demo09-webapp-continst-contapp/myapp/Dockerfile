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