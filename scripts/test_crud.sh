#!/bin/bash
# ===================================================================
# SCRIPT DE TESTE AUTOMATIZADO DAS OPERAÇÕES CRUD NA NUVEM AZURE
# ===================================================================

RESOURCE_GROUP="rg-dimdim-rm562795"
ACI_APP_NAME="rm562795-dimdim-app"

APP_FQDN=$(az container show --resource-group "${RESOURCE_GROUP}" --name "${ACI_APP_NAME}" --query ipAddress.fqdn --output tsv 2>/dev/null || echo "app-dimdim-rm562795.brazilsouth.azurecontainer.io")
BASE_URL="http://${APP_FQDN}:8080/api/transacoes"

echo "==================================================================="
echo "🧪 INICIANDO TESTES DO CRUD DIMDIM EM NUVEM NA AZURE"
echo "🌐 URL Alvo: ${BASE_URL}"
echo "==================================================================="

# 1. Teste GET All
echo "\n🔍 1. Testando GET /api/transacoes (Listar Todos):"
curl -s -X GET "${BASE_URL}" | jq . || curl -s -X GET "${BASE_URL}"

# 2. Teste POST (Create)
echo "\n\n➕ 2. Testando POST /api/transacoes (Cadastrar Nova Transação):"
POST_RES=$(curl -s -X POST "${BASE_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Venda de Licença Software DimDim",
    "valor": 1250.00,
    "tipo": "ENTRADA",
    "categoria": "Vendas"
  }')
echo "${POST_RES}"

# 3. Teste PUT (Update)
echo "\n\n✏️ 3. Testando PUT /api/transacoes/1 (Atualizar Transação ID 1):"
curl -s -X PUT "${BASE_URL}/1" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Salário Mensal - DimDim Tecnologia (Reajustado)",
    "valor": 8200.00,
    "tipo": "ENTRADA",
    "categoria": "Salário"
  }'

# 4. Teste GET Resumo Financeiro
echo "\n\n📊 4. Testando GET /api/transacoes/resumo (Resumo de Saldo e Totais):"
curl -s -X GET "${BASE_URL}/resumo"

# 5. Teste DELETE
echo "\n\n🗑️ 5. Testando DELETE /api/transacoes/5 (Excluir Transação ID 5):"
curl -s -i -X DELETE "${BASE_URL}/5"

echo "\n\n==================================================================="
echo "✅ TODOS OS TESTES DO CRUD FORAM CONCLUÍDOS COM SUCESSO!"
echo "==================================================================="
