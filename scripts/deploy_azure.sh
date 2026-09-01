#!/bin/bash
# ===================================================================
# SCRIPT DE AUTOMATIZAÇÃO AZURE CLI: PROJETO DIMDIM (ACR + ACI PaaS)
# 1º Checkpoint 2º Semestre: DevOps Tools & Cloud Computing (FIAP)
# Representante: Gabriel Maciel (RM562795)
# ===================================================================

set -e

# Configurações de Variáveis
RESOURCE_GROUP="rg-dimdim-rm562795"
LOCATION="chilecentral"
ACR_NAME="acrdimdim562795"
STORAGE_ACCOUNT="stdimdim562795"
SHARE_NAME="db-dimdim-share"
DNS_DB="db-dimdim-rm562795"
DNS_APP="app-dimdim-rm562795"
ACI_DB_NAME="rm562795-dimdim-db"
ACI_APP_NAME="rm562795-dimdim-app"
DB_IMAGE_TAG="rm562795-dimdim-db:latest"
APP_IMAGE_TAG="rm562795-dimdim-app:latest"

echo "==================================================================="
echo "🚀 INICIANDO DEPLOY PAAS DO PROJETO DIMDIM NA MICROSOFT AZURE"
echo "==================================================================="

# 1. Criação do Grupo de Recursos (Resource Group)
echo "\n📦 [1/7] Criando Grupo de Recursos '${RESOURCE_GROUP}' em '${LOCATION}'..."
az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}" --output table

# 2. Criação da Conta de Armazenamento para Persistência do Banco (Azure File Share)
echo "\n💾 [2/7] Criando Storage Account '${STORAGE_ACCOUNT}' e Azure File Share '${SHARE_NAME}'..."
az storage account create \
  --name "${STORAGE_ACCOUNT}" \
  --resource-group "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --sku Standard_LRS \
  --output table

STORAGE_KEY=$(az storage account keys list \
  --resource-group "${RESOURCE_GROUP}" \
  --account-name "${STORAGE_ACCOUNT}" \
  --query "[0].value" \
  --output tsv)

az storage share create \
  --name "${SHARE_NAME}" \
  --account-name "${STORAGE_ACCOUNT}" \
  --account-key "${STORAGE_KEY}" \
  --output table

# 3. Criação do Azure Container Registry (ACR)
echo "\n🏭 [3/7] Criando Azure Container Registry '${ACR_NAME}'..."
az acr create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACR_NAME}" \
  --location "${LOCATION}" \
  --sku Basic \
  --admin-enabled true \
  --output table

ACR_SERVER=$(az acr show --name "${ACR_NAME}" --query loginServer --output tsv)
ACR_USER=$(az acr credential show --name "${ACR_NAME}" --query username --output tsv)
ACR_PWD=$(az acr credential show --name "${ACR_NAME}" --query "passwords[0].value" --output tsv)

echo "ACR Login Server: ${ACR_SERVER}"

# 4. Build e Push das Imagens para o ACR
echo "\n🔨 [4/7] Realizando Build e Push das Imagens para o ACR com prefixo RM..."
if docker info >/dev/null 2>&1; then
  echo "--> Compilando Imagem do Banco de Dados via Docker local (linux/amd64)..."
  docker build --platform linux/amd64 -t "${ACR_SERVER}/${DB_IMAGE_TAG}" ./db
  echo "--> Enviando Imagem do Banco para o ACR..."
  az acr login --name "${ACR_NAME}"
  docker push "${ACR_SERVER}/${DB_IMAGE_TAG}"

  echo "--> Compilando Imagem do App (Java 21 / Non-root User / linux/amd64)..."
  docker build --platform linux/amd64 -t "${ACR_SERVER}/${APP_IMAGE_TAG}" ./app
  echo "--> Enviando Imagem do App para o ACR..."
  docker push "${ACR_SERVER}/${APP_IMAGE_TAG}"
else
  echo "--> Docker local indisponivel. Usando 'az acr build' (Build nativo diretamente na Nuvem Azure)..."
  echo "--> Compilando Imagem do Banco na Nuvem..."
  az acr build --registry "${ACR_NAME}" --image "${DB_IMAGE_TAG}" ./db
  echo "--> Compilando Imagem do App (Java 21 / Non-root User) na Nuvem..."
  az acr build --registry "${ACR_NAME}" --image "${APP_IMAGE_TAG}" ./app
fi

# 5. Criação da Instância de Container do Banco de Dados (ACI - PostgreSQL) com Volume Persistente
echo "\n🛢️ [5/7] Criando Azure Container Instance para o Banco de Dados com Azure Files..."
az container delete --resource-group "${RESOURCE_GROUP}" --name "${ACI_DB_NAME}" --yes 2>/dev/null || true
az container create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACI_DB_NAME}" \
  --image "${ACR_SERVER}/${DB_IMAGE_TAG}" \
  --registry-login-server "${ACR_SERVER}" \
  --registry-username "${ACR_USER}" \
  --registry-password "${ACR_PWD}" \
  --dns-name-label "${DNS_DB}" \
  --ports 5432 \
  --ip-address Public \
  --os-type Linux \
  --environment-variables POSTGRES_DB="dimdim_db" POSTGRES_USER="dimdim_user" PGDATA="/var/lib/postgresql/data/pgdata" \
  --secure-environment-variables POSTGRES_PASSWORD="dimdim_pass123" \
  --azure-file-volume-account-name "${STORAGE_ACCOUNT}" \
  --azure-file-volume-account-key "${STORAGE_KEY}" \
  --azure-file-volume-share-name "${SHARE_NAME}" \
  --azure-file-volume-mount-path "/var/lib/postgresql/data" \
  --cpu 1 \
  --memory 1.5 \
  --output table

DB_FQDN=$(az container show --resource-group "${RESOURCE_GROUP}" --name "${ACI_DB_NAME}" --query ipAddress.fqdn --output tsv)
echo "Banco de Dados ACI FQDN: ${DB_FQDN}"

# 6. Criação da Instância de Container da Aplicação (ACI - DimDim API)
echo "\n🌐 [6/7] Criando Azure Container Instance para o App DimDim..."
az container delete --resource-group "${RESOURCE_GROUP}" --name "${ACI_APP_NAME}" --yes 2>/dev/null || true
az container create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACI_APP_NAME}" \
  --image "${ACR_SERVER}/${APP_IMAGE_TAG}" \
  --registry-login-server "${ACR_SERVER}" \
  --registry-username "${ACR_USER}" \
  --registry-password "${ACR_PWD}" \
  --dns-name-label "${DNS_APP}" \
  --ports 8080 \
  --ip-address Public \
  --os-type Linux \
  --environment-variables \
      SPRING_DATASOURCE_URL="jdbc:postgresql://${DB_FQDN}:5432/dimdim_db" \
      SPRING_DATASOURCE_USERNAME="dimdim_user" \
  --secure-environment-variables \
      SPRING_DATASOURCE_PASSWORD="dimdim_pass123" \
  --cpu 1 \
  --memory 1.5 \
  --output table

APP_FQDN=$(az container show --resource-group "${RESOURCE_GROUP}" --name "${ACI_APP_NAME}" --query ipAddress.fqdn --output tsv)

echo "\n==================================================================="
echo "✅ DEPLOY CONCLUÍDO COM SUCESSO NA AZURE!"
echo "==================================================================="
echo "📊 Swagger UI (Nuvem):  http://${APP_FQDN}:8080/swagger-ui.html"
echo "📡 Endpoint API REST:   http://${APP_FQDN}:8080/api/transacoes"
echo "🛢️ Banco PostgreSQL:   ${DB_FQDN}:5432"
echo "==================================================================="
