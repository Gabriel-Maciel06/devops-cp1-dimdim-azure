#!/bin/bash
# ===================================================================
# SCRIPT DE LIMPEZA E EXCLUSÃO DOS RECURSOS AZURE
# ===================================================================

RESOURCE_GROUP="rg-dimdim-rm562795"

echo "⚠️ Excluindo o Grupo de Recursos '${RESOURCE_GROUP}' e todos os recursos associados..."
az group delete --name "${RESOURCE_GROUP}" --yes --no-wait

echo "✅ Comando de exclusão enviado. Os recursos estão sendo liberados na nuvem Azure."
