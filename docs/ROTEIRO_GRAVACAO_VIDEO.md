# 🎬 Roteiro Oficial de Gravação de Vídeo Completo (15 Minutos)
**Disciplina:** DevOps Tools & Cloud Computing  
**Professor:** Prof. João Menk  
**Projeto:** DimDim — Containerização PaaS com ACR e ACI na Microsoft Azure  
**Representante do Grupo:** Gabriel Maciel Alves de Oliveira (RM562795)  

---

## ⏱️ Distribuição do Tempo (15 Minutos Detalhados)

| Bloco | Tempo | Tema Principal | O que mostrar na tela |
| :--- | :---: | :--- | :--- |
| **Bloco 1** | `00:00 - 02:00` | Abertura, Equipe & Contexto DimDim | Folha de Rosto PDF (`DimDim_container.pdf`) / GitHub |
| **Bloco 2** | `02:00 - 05:00` | Tour Completo pelos Recursos PaaS na Azure | Portal Azure (Resource Group, ACR, Storage, ACIs, Logs) |
| **Bloco 3** | `05:00 - 08:00` | Código-Fonte, Dockerfiles & Script Azure CLI | GitHub / VS Code (Multi-stage non-root, DDL, CLI .sh) |
| **Bloco 4** | `08:00 - 12:30` | Demonstração do CRUD ao Vivo com SELECT | Tela dividida: Swagger UI na Azure + DBeaver/psql |
| **Bloco 5** | `12:30 - 14:00` | Comprovação da Persistência no Azure Files | Portal Azure (File Share com arquivos do PostgreSQL) |
| **Bloco 6** | `14:00 - 15:00` | Checklist de Avaliação & Fechamento | PDF de Entrega e Encerramento |

---

## 🎙️ Script de Fala e Ações Passo a Passo

---

### 🟢 BLOCO 1: Abertura, Equipe & Contexto de Negócio (00:00 - 02:00)
**Tela:** Folha de Rosto PDF ([`DimDim_container.pdf`](file:///Users/gabrieloliveira/Desktop/Agentes-cloud/devops-cp1-dimdim-azure/DimDim_container.pdf)) ou capa do repositório GitHub.

> 🗣️ **O QUE FALAR:**
> *"Olá professor João Menk e colegas. Meu nome é **Gabriel Maciel Alves de Oliveira (RM 562795)** e estou aqui como representante do nosso grupo para apresentar a entrega completa do **1º Checkpoint do 2º Semestre** na disciplina de **DevOps Tools & Cloud Computing**.*  
> 
> *Nossa equipe é formada por:*  
> - *Gabriel Maciel Alves de Oliveira (RM562795)*  
> - *Vitória Rodrigues Martins (RM565160)*  
> - *Augusto Bonomo Júnior (RM565155)*  
> - *Thomas Fontes (RM562254)*  
> - *Matheus Pereira Molina (RM563399)*  
> 
> *O objetivo desta entrega é a **containerização em nuvem no modelo PaaS** para o **Projeto DimDim**, nossa solução de gestão financeira e transações bancárias. Desenvolvemos uma arquitetura moderna em nuvem utilizando **Java 21 LTS com Spring Boot 3.3**, banco de dados relacional **PostgreSQL 16**, registro privado de imagens no **Azure Container Registry (ACR)**, execução serverless no **Azure Container Instances (ACI)** e persistência física de dados no **Azure Files (Storage Account)**.*  
> 
> *Todos os recursos foram provisionados 100% via **Azure CLI**, o container da aplicação roda com usuário **não-root** por segurança, não utilizamos banco H2 e todas as operações do CRUD serão demonstradas na prática com consultas SELECT diretamente no banco de dados na nuvem."*

---

### ☁️ BLOCO 2: Tour Completo pela Infraestrutura PaaS na Azure (02:00 - 05:00)
**Tela:** Navegador Web no **Portal da Microsoft Azure**.

> 🗣️ **O QUE FALAR & MOSTRAR:**
> 
> 1. **Resource Group:**  
>    *"Iniciando a demonstração pela infraestrutura em nuvem, estamos aqui no Portal da Azure dentro do Resource Group `rg-dimdim-rm562795`, criado na região Brazil South."*
> 
> 2. **Azure Container Registry (ACR):**  
>    *(Clique em `acrdimdim562795` ➔ menu esquerdo em **Repositories**)*  
>    *"Aqui temos o nosso registro privado `acrdimdim562795`. Como solicitado no enunciado, todas as imagens possuem o prefixo do meu RM:*  
>    - *`rm562795-dimdim-db:latest` (Imagem customizada do PostgreSQL com scripts DDL de inicialização).*  
>    - *`rm562795-dimdim-app:latest` (Imagem compilada da nossa API Java Spring Boot).*  
>    *Nas configurações de Access Keys, o usuário admin está habilitado para autenticação segura dos containers."*
> 
> 3. **Conta de Armazenamento (Azure Storage Account & Azure Files):**  
>    *(Abra `stdimdim562795` ➔ menu **File shares** ➔ clique em `db-dimdim-share`)*  
>    *"Para garantir a persistência física dos dados do banco relacional, criamos a Storage Account `stdimdim562795` com o File Share `db-dimdim-share`. Este volume SMB é montado diretamente no container do PostgreSQL no caminho `/var/lib/postgresql/data`."*
> 
> 4. **Azure Container Instances (ACI):**  
>    *(Abra a lista de Container Instances no Portal)*  
>    *"Temos dois ACIs em execução com status 'Running':*  
>    - *`rm562795-dimdim-db`: Container do PostgreSQL na porta 5432, com FQDN `db-dimdim-rm562795.chilecentral.azurecontainer.io` e com o volume Azure Files montado.*  
>    - *`rm562795-dimdim-app`: Container da aplicação Spring Boot na porta 8080, com FQDN público `app-dimdim-rm562795.chilecentral.azurecontainer.io`.*  
>    *(Abra o container do App ➔ clique em **Logs**)*  
>    *Nos logs do container, podemos ver o Spring Boot 3.3 inicializando o servidor Tomcat na porta 8080 e estabelecendo com sucesso a conexão JDBC com o container do banco PostgreSQL."*

---

### 💻 BLOCO 3: Código-Fonte, Segurança Docker & Script Azure CLI (05:00 - 08:00)
**Tela:** Repositório no **GitHub** ou no **VS Code/IntelliJ**.

> 🗣️ **O QUE FALAR & MOSTRAR:**
> 
> 1. **Dockerfile do App (`app/Dockerfile`):**  
>    *(Abra o arquivo `app/Dockerfile` no GitHub e destaque)*  
>    *"No Dockerfile da aplicação, implementamos um **Multi-Stage Build**:*  
>    - *No Estágio 1, usamos `maven:3.9.8-eclipse-temurin-21-alpine` para compilar o código fonte e gerar o JAR.*  
>    - *No Estágio 2, usamos `eclipse-temurin:21-jre-alpine` minimalista.*  
>    - *E aqui está a regra crítica de segurança do checkpoint: criamos o grupo e usuário `appuser:appgroup` (UID 10001) e definimos a diretiva `USER appuser:appgroup`. Isso garante que a aplicação execute sem qualquer privilégio administrativo de root na nuvem."*
> 
> 2. **Dockerfile do Banco & DDL (`db/init.sql`):**  
>    *(Abra `db/init.sql` no GitHub)*  
>    *"No script DDL `init.sql`, temos a criação da tabela relacional `TB_DIMDIM_TRANSACOES` com chave primária `BIGSERIAL`, tipos de dados precisos (`NUMERIC(12,2)` para valores monetários), constraints de validação (`CHECK (VALOR > 0)` e `CHECK (TIPO IN ('ENTRADA', 'SAIDA'))`), índices de performance e a carga inicial de dados. Total conformidade: sem uso de H2."*
> 
> 3. **Automação 100% Azure CLI (`scripts/deploy_azure.sh`):**  
>    *(Abra `scripts/deploy_azure.sh` no GitHub)*  
>    *"Todo o provisionamento foi automatizado neste script bash utilizando Azure CLI:*  
>    - *`az group create`*  
>    - *`az storage account create` e `az storage share create`*  
>    - *`az acr create`, `az acr login` e `docker push` das imagens com prefixo RM*  
>    - *`az container create` para o banco com montagem do volume SMB*  
>    - *`az container create` para o App passando as credenciais de forma segura com `--secure-environment-variables` sem expor senhas no código."*
> 
> 4. **Arquivos de Teste JSON (`tests/`):**  
>    *(Abra a pasta `tests/` e mostre os arquivos `post_transacao.json`, `put_transacao.json`, `get_transacao_response.json` e `delete_transacao_response.json`)*  
>    *"Disponibilizamos no GitHub todos os payloads JSON utilizados para os testes das rotas do CRUD."*

---

### 🧪 BLOCO 4: Demonstração Prática do CRUD com SELECT em Tempo Real (08:00 - 12:30)
- Repositório GitHub: https://github.com/Gabriel-Maciel06/devops-cp1-dimdim-azure
- Vídeo de Demonstração (YouTube): https://youtu.be/sOJWAZk0AmU?is=WEzSpdxw0hyJ5_0e
- Swagger UI (Nuvem Azure): http://app-dimdim-rm562795.chilecentral.azurecontainer.io:8080/swagger-ui.html
- **Lado Direito:** DBeaver / pgAdmin / terminal `psql` conectado ao PostgreSQL na nuvem (`db-dimdim-rm562795.chilecentral.azurecontainer.io:5432`).

```
┌──────────────────────────────────────────────┬──────────────────────────────────────────────┐
│  SWAGGER UI NA NUVEM AZURE (:8080)           │  DBeaver / BANCO POSTGRESQL NA NUVEM (:5432) │
│  http://app-dimdim-rm562795.chilecentral...   │  Host: db-dimdim-rm562795.chilecentral...     │
└──────────────────────────────────────────────┴──────────────────────────────────────────────┘
```

> 🗣️ **O QUE FALAR & EXECUTAR:**

#### 🔍 1. Operação READ Inicial:
- **No Banco (DBeaver):** Execute:
  ```sql
  SELECT ID, DESCRICAO, VALOR, TIPO, CATEGORIA FROM TB_DIMDIM_TRANSACOES ORDER BY ID;
  ```
  *"Primeiro, consultamos o banco de dados diretamente via SELECT. Temos os 5 registros inseridos pela carga inicial."*
- **No Swagger:** Abra `GET /api/transacoes` e clique em *Execute*.
  *"Agora chamamos o endpoint GET da nossa API na Azure. Status 200 OK com o array JSON contendo exatamente os mesmos 5 registros."*
- **Filtro no Swagger:** Teste `GET /api/transacoes?tipo=ENTRADA`.
  *"Podemos filtrar por tipo: trazendo apenas as transações de ENTRADA."*

#### ➕ 2. Operação CREATE (POST):
- **No Swagger:** Abra `POST /api/transacoes`, cole o JSON de teste e clique em *Execute*:
  ```json
  {
    "descricao": "Venda de Licença Software DimDim Enterprise",
    "valor": 1250.00,
    "tipo": "ENTRADA",
    "categoria": "Vendas"
  }
  ```
  *"Enviamos a requisição de cadastro. A API responde com **HTTP 201 Created**, gerando o ID 6."*
- **No Banco (DBeaver):** Execute imediatamente:
  ```sql
  SELECT * FROM TB_DIMDIM_TRANSACOES WHERE ID = 6;
  ```
  *"Rodando o SELECT imediatamente no banco PostgreSQL, comprovamos que a transação foi persistida fisicamente na tabela com os dados corretos."*

#### ✏️ 3. Operação UPDATE (PUT):
- **No Swagger:** Abra `PUT /api/transacoes/1`, cole o JSON e clique em *Execute*:
  ```json
  {
    "descricao": "Salário Mensal - DimDim Tecnologia (Reajuste Anual)",
    "valor": 8500.00,
    "tipo": "ENTRADA",
    "categoria": "Salário"
  }
  ```
  *"Atualizamos a transação de ID 1 alterando a descrição e aumentando o valor para 8500.00. Retorno **HTTP 200 OK**."*
- **No Banco (DBeaver):** Execute:
  ```sql
  SELECT ID, DESCRICAO, VALOR, TIPO FROM TB_DIMDIM_TRANSACOES WHERE ID = 1;
  ```
  *"No SELECT do banco, comprovamos que o registro de ID 1 foi atualizado com sucesso."*

#### 🗑️ 4. Operação DELETE:
- **No Swagger:** Abra `DELETE /api/transacoes/5` e clique em *Execute*.
  *"Vamos deletar a transação de ID 5. Resposta **HTTP 204 No Content**."*
- **No Banco (DBeaver):** Execute:
  ```sql
  SELECT * FROM TB_DIMDIM_TRANSACOES WHERE ID = 5;
  ```
  *"Ao rodar o SELECT no banco procurando pelo ID 5, o banco retorna vazio (0 linhas), comprovando a exclusão física do registro."*

#### 📊 5. Endpoint de Resumo Financeiro (Regra de Negócio):
- **No Swagger:** Abra `GET /api/transacoes/resumo` e clique em *Execute*.
  *"A API calcula em tempo real o total de entradas, total de saídas, a quantidade de transações e o saldo consolidado da conta DimDim."*
- **No Banco (DBeaver):** Rode para validar a soma:
  ```sql
  SELECT SUM(VALOR) FROM TB_DIMDIM_TRANSACOES WHERE TIPO = 'ENTRADA';
  ```
  *"Batendo exatamente com a soma calculada pela aplicação."*

---

### 💾 BLOCO 5: Comprovação da Persistência no Azure File Share (12:30 - 14:00)
**Tela:** Portal Azure ➔ Storage Account `stdimdim562795` ➔ File shares ➔ `db-dimdim-share`.

> 🗣️ **O QUE FALAR:**
> *"Agora vamos comprovar a persistência real dos dados em nuvem:*  
> *Estamos dentro da nossa Storage Account `stdimdim562795`, no File Share `db-dimdim-share`.*  
> *Podemos navegar e ver as pastas físicas do PostgreSQL criadas aqui: `base/`, `global/`, `pg_wal/`, `postmaster.opts`.*  
> *Isso comprova que mesmo se o container ACI for destruído, reiniciado ou escalado, todo o banco de dados e as operações que acabamos de realizar no CRUD permanecem 100% salvos e persistidos no Azure Files."*

---

### 🏁 BLOCO 6: Documento de Entrega & Fechamento (14:00 - 15:00)
**Tela:** Documento PDF [`DimDim_container.pdf`](file:///Users/gabrieloliveira/Desktop/Agentes-cloud/devops-cp1-dimdim-azure/DimDim_container.pdf).

> 🗣️ **O QUE FALAR:**
> *"Para finalizar nossa apresentação, temos aqui o documento PDF oficial de entrega gerado (`DimDim_container.pdf`), contendo a folha de rosto, os nomes e RMs de todos os integrantes, o link do repositório GitHub e o link deste vídeo gravado.*  
> 
> *Recapitulando todos os requisitos cumpridos com nota máxima:*  
> - *Ambiente 100% em nuvem PaaS na Azure (ACR + ACI + Azure Files);*  
> - *Imagens e instâncias nomeadas com o prefixo do RM;*  
> - *Aplicação Java 21 Spring Boot com segurança e usuário não-root;*  
> - *Banco relacional PostgreSQL sem uso de H2 e com persistência comprovada;*  
> - *Provisionamento automatizado via Azure CLI;*  
> - *Demonstração detalhada de cada operação do CRUD com SELECT no banco;*  
> - *Documentação completa no padrão How-To e JSONs de teste no repositório.*  
> 
> *Agradecemos a atenção do professor João Menk e encerramos aqui a nossa entrega. Muito obrigado!"*
