# 🏦 Projeto DimDim — Containerização PaaS com ACR & ACI na Microsoft Azure
### 1º Checkpoint 2º Semestre — DevOps Tools & Cloud Computing (FIAP)
**Professor:** Prof. João Menk (`profjoao.menk@fiap.com.br`)

---

## 👥 Integrantes da Equipe
- **Gabriel Maciel Alves de Oliveira (RM562795)** —
- **Vitória Rodrigues Martins (RM565160)**
- **Augusto Bonomo Júnior (RM565155)**
- **Thomas Fontes (RM562254)**
- **Matheus Pereira Molina (RM563399)**

---

## 🔗 Links de Entrega
- **Repositório GitHub Oficial:** `https://github.com/Gabriel-Maciel06/devops-cp1-dimdim-azure`
- **Vídeo de Demonstração (YouTube):** `[COLE SEU LINK DO VIDEO AQUI]`
- **Documentação Swagger UI (Nuvem Azure):** `http://app-dimdim-rm562795.brazilsouth.azurecontainer.io:8080/swagger-ui.html`

---

## 🏛️ 1. Visão Geral da Arquitetura em Nuvem (PaaS)

O projeto **DimDim** consiste em uma solução enterprise de **Gestão Financeira e Transações**, conteinerizada em nuvem utilizando os serviços gerenciados (PaaS) da Microsoft Azure:

```
                                      ┌──────────────────────────────────────────────────────────┐
                                      │                      MICROSOFT AZURE                     │
                                      │                                                          │
   [ Desenvolvedor / CI/CD ]          │   ┌──────────────────────────────────────────────────┐   │
              │                       │   │          Azure Container Registry (ACR)          │   │
              ├─── docker push ───────┼──>│  • rm562795-dimdim-db:latest                     │   │
              │                       │   │  • rm562795-dimdim-app:latest                    │   │
              │                       │   └────────────────────────┬─────────────────────────┘   │
              │                       │                            │ pull image                  │
              │                       │                            ▼                             │
              │                       │   ┌──────────────────────────────────────────────────┐   │
   [ Cliente / Browser / Postman ]    │   │         Azure Container Instances (ACI)          │   │
              │                       │   │                                                  │   │
              ▼  (HTTP :8080)         │   │   ┌──────────────────────────────────────────┐   │   │
   ┌─────────────────────────────┐    │   │   │  App Container (Java 21 / Non-Root)      │   │   │
   │  app-dimdim-rm562795        │───-┼───┼──>│  Name: rm562795-dimdim-app               │   │   │
   │  .brazilsouth.azure...      │    │   │   └────────────────────┬─────────────────────┘   │   │
   └─────────────────────────────┘    │   │                        │ JDBC :5432              │   │
                                      │   │                        ▼                             │
                                      │   │   ┌──────────────────────────────────────────┐   │   │
                                      │   │   │  Database Container (PostgreSQL 16)      │   │   │
                                      │   │   │  Name: rm562795-dimdim-db                │   │   │
                                      │   │   └────────────────────┬─────────────────────┘   │   │
                                      │   └────────────────────────┼─────────────────────────┘   │
                                      │                            │ Volume Mount                │
                                      │                            ▼                             │
                                      │   ┌──────────────────────────────────────────────────┐   │
                                      │   │       Azure Storage Account (Azure Files)        │   │
                                      │   │  • Share: db-dimdim-share                        │   │
                                      │   │  • Mount: /var/lib/postgresql/data               │   │
                                      │   └──────────────────────────────────────────────────┘   │
                                      └──────────────────────────────────────────────────────────┘
```

### 🛡️ Cumprimento Rigoroso das Regras:
1. **Containerização PaaS em Nuvem:** Uso estrito de **Azure Container Registry (ACR)** e **Azure Container Instances (ACI)**.
2. **Segurança de Execução (Non-Root User):** O `Dockerfile` do App cria e executa sob o usuário sem privilégios `appuser:appgroup` (UID 10001).
3. **Persistência de Dados:** O container de banco PostgreSQL monta um volume SMB gerenciado no **Azure File Share (Storage Account)**.
4. **Sem Dados Sensíveis no Código:** Senhas e credenciais injetadas via `--secure-environment-variables` e lidas via `System.getenv()`.
5. **Automação 100% via Azure CLI:** Todo o provisionamento é executado através do script `scripts/deploy_azure.sh`.
6. **Banco Relacional:** PostgreSQL 16 com DDL completo (`db/init.sql`) — **Sem uso de H2**.

---

## 💻 2. HOW-TO: Tutorial de Execução Local e Deploy em Nuvem

### 🚀 Etapa 1: Execução e Teste Local (Docker Compose)

Para testar localmente na sua máquina antes de subir para a nuvem:

```bash
# 1. Clonar o repositório
git clone https://github.com/Gabriel-Maciel06/devops-cp1-dimdim-azure.git
cd devops-cp1-dimdim-azure

# 2. Subir os containers do App e Banco localmente
docker compose up --build -d

# 3. Verificar o status dos containers
docker compose ps

# 4. Acessar a documentação interativa
open http://localhost:8080/swagger-ui.html
```

---

### ☁️ Etapa 2: Provisionamento Automatizado na Azure (Azure CLI)

Para provisionar o Storage Account, ACR, Build/Push de Imagens e ACIs em nuvem:

```bash
# 1. Autenticar na sua conta Azure
az login

# 2. Dar permissão de execução ao script
chmod +x scripts/deploy_azure.sh scripts/test_crud.sh scripts/destroy_azure.sh

# 3. Executar o deploy automatizado
./scripts/deploy_azure.sh
```

---

### 🔨 Comandos Manuais Individuais (Build e Push)

Caso deseje executar os comandos de Build e Push passo a passo:

```bash
# Definir variáveis
ACR_SERVER="acrdimdim562795.azurecr.io"

# Login no Azure Container Registry
az acr login --name acrdimdim562795

# Build e Push da Imagem do Banco de Dados
docker build -t ${ACR_SERVER}/rm562795-dimdim-db:latest ./db
docker push ${ACR_SERVER}/rm562795-dimdim-db:latest

# Build e Push da Imagem da Aplicação (Java 21 / Non-Root)
docker build -t ${ACR_SERVER}/rm562795-dimdim-app:latest ./app
docker push ${ACR_SERVER}/rm562795-dimdim-app:latest
```

---

## 🧪 3. Evidências do CRUD no Banco de Dados (SELECT & JSONs)

### 📋 Mapeamento de Endpoints da API

| Método | Endpoint | Descrição | Status HTTP |
| :--- | :--- | :--- | :---: |
| **GET** | `/api/transacoes` | Listar todas as transações cadastradas | `200 OK` |
| **GET** | `/api/transacoes/{id}` | Buscar transação por ID | `200 OK` |
| **POST** | `/api/transacoes` | Cadastrar nova transação financeira | `201 Created` |
| **PUT** | `/api/transacoes/{id}` | Atualizar transação por ID | `200 OK` |
| **DELETE** | `/api/transacoes/{id}` | Excluir transação por ID | `204 No Content` |
| **GET** | `/api/transacoes/resumo` | Consultar resumo de saldo e totais | `200 OK` |

---

### 📜 DDL das Tabelas (`db/init.sql`)

```sql
CREATE TABLE IF NOT EXISTS TB_DIMDIM_TRANSACOES (
    ID BIGSERIAL PRIMARY KEY,
    DESCRICAO VARCHAR(150) NOT NULL,
    VALOR NUMERIC(12, 2) NOT NULL,
    TIPO VARCHAR(10) NOT NULL,
    CATEGORIA VARCHAR(50) NOT NULL,
    DATA_TRANSACAO TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT CK_VALOR_POSITIVO CHECK (VALOR > 0),
    CONSTRAINT CK_TIPO_VALIDO CHECK (TIPO IN ('ENTRADA', 'SAIDA'))
);
```

---

### 🔍 Evidência do CRUD via SELECT no PostgreSQL:

```sql
-- 1. Consulta Inicial (Carga de Dados):
SELECT ID, DESCRICAO, VALOR, TIPO, CATEGORIA FROM TB_DIMDIM_TRANSACOES;

-- 2. Evidência após o POST (Novo registro inserido):
SELECT * FROM TB_DIMDIM_TRANSACOES WHERE DESCRICAO LIKE '%Venda de Licença%';

-- 3. Evidência após o PUT (Registro atualizado):
SELECT * FROM TB_DIMDIM_TRANSACOES WHERE ID = 1;

-- 4. Evidência após o DELETE (Registro excluído):
SELECT COUNT(*) FROM TB_DIMDIM_TRANSACOES WHERE ID = 5;
```

---

## 📁 4. Estrutura do Repositório

```text
devops-cp1-dimdim-azure/
├── app/
│   ├── Dockerfile                  # Multi-stage com usuário não-root (USER 10001)
│   ├── pom.xml                     # Maven dependencies (Java 21, Spring Boot 3.3, JPA, OpenAPI)
│   └── src/main/
│       ├── java/com/fiap/dimdim/   # Controllers, Services, Entities, DTOs, Configs
│       └── resources/
│           └── application.properties
├── db/
│   ├── Dockerfile                  # Imagem PostgreSQL customizada para o ACR
│   └── init.sql                    # DDL + Carga inicial de dados
├── scripts/
│   ├── deploy_azure.sh             # Automação completa Azure CLI (Storage, ACR, ACIs)
│   ├── test_crud.sh                # Teste automatizado dos endpoints via curl
│   └── destroy_azure.sh            # Script para limpeza dos recursos na Azure
├── tests/
│   ├── post_transacao.json         # Payload de teste POST
│   ├── put_transacao.json          # Payload de teste PUT
│   ├── get_transacao_response.json # Amostra de resposta GET
│   └── delete_transacao_response.json
├── docker-compose.yml              # Orquestração para teste local
└── README.md                       # Documentação completa How-To
```
