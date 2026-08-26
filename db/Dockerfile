# ===================================================================
# Dockerfile do Banco de Dados Relacional (PostgreSQL 16 Alpine)
# 1º Checkpoint 2º Semestre: DevOps Tools & Cloud Computing
# ===================================================================
FROM postgres:16-alpine

# Metadados da Imagem
LABEL maintainer="Equipe DimDim <rm562795@fiap.com.br>"
LABEL description="Imagem Docker do Banco PostgreSQL com DDL Inicial DimDim para Azure ACI"

# Configuração de Variáveis de Ambiente Padrão
ENV POSTGRES_DB=dimdim_db
ENV POSTGRES_USER=dimdim_user
ENV POSTGRES_PASSWORD=dimdim_pass123

# Cópia do script DDL de inicialização para execução automática no primeiro boot
COPY init.sql /docker-entrypoint-initdb.d/01_init.sql

# Exposição da porta padrão do PostgreSQL
EXPOSE 5432
