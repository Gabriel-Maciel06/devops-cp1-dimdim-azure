# 🎬 Roteiro Oficial de Gravação de Vídeo — Checkpoint 1 (2º Semestre)
**Disciplina:** DevOps Tools & Cloud Computing  
**Professor:** Prof. João Menk  
**Projeto:** DimDim — Containerização PaaS com ACR e ACI na Microsoft Azure  
**Representante do Grupo:** Gabriel Maciel Alves de Oliveira (RM562795)  

---

## 📋 Checklist Pré-Gravação (Evite Perda de Pontos)

> [!IMPORTANT]
> O professor avalia rigorosamente os itens do checklist. Verifique antes de apertar o REC:
> - [ ] **Qualidade de Vídeo:** Gravador configurado em **1080p** (ou no mínimo 720p) com áudio limpo.
> - [ ] **Ambiente em Nuvem Ativo:** Containers no ACI rodando e acessíveis via FQDN (nunca mostrar `localhost`!).
> - [ ] **Ferramenta de Banco Aberta:** DBeaver, pgAdmin ou terminal `psql` conectado ao PostgreSQL no ACI (`5432`).
> - [ ] **Swagger UI ou Postman Pronto:** Aberto na URL pública da Azure (`http://app-dimdim-rm562795.brazilsouth.azurecontainer.io:8080/swagger-ui.html`).
> - [ ] **Portal Azure Aberto:** Na aba do Resource Group `rg-dimdim-rm562795`.
> - [ ] **Repositório GitHub Aberto:** Mostrando README, Dockerfiles, scripts e JSONs.

---

## ⏱️ Linha do Tempo & Script de Fala (5 a 6 Minutos)

### 🟢 BLOCO 1: Abertura e Identificação da Equipe (0:00 - 0:45)
**O que mostrar na tela:** Slide de Apresentação / Folha de Rosto PDF (`DimDim_container.pdf`) ou tela inicial do GitHub.

> 🗣️ **O QUE FALAR:**
> *"Olá professor João Menk e a todos que estão assistindo. Eu sou o Gabriel Maciel, RM 562795, e estou representando nosso grupo no 1º Checkpoint do 2º Semestre da disciplina de DevOps Tools & Cloud Computing.*  
> *O nosso grupo é formado por mim, Gabriel Maciel, pela Vitória Rodrigues (RM 565160), Augusto Bonomo (RM 565155), Thomas Fontes (RM 562254) e Matheus Molina (RM 563399).*  
> *Hoje vamos apresentar a entrega completa do Projeto DimDim, onde realizamos a containerização de uma aplicação Java Spring Boot e banco de dados relacional PostgreSQL em formato 100% PaaS na nuvem Microsoft Azure, utilizando Azure Container Registry (ACR), Azure Container Instances (ACI) e Azure Files para persistência."*

---

### ☁️ BLOCO 2: Demonstração dos Recursos Criados na Azure (0:45 - 2:00)
**O que mostrar na tela:** Aba do navegador no **Portal Azure** navegando dentro do Resource Group `rg-dimdim-rm562795`.

> 🗣️ **O QUE FALAR:**
> *"Como exigido no enunciado, vamos iniciar mostrando todos os recursos provisionados na nuvem Azure:*  
> 1. *Aqui temos o nosso Resource Group `rg-dimdim-rm562795` na região Brazil South.*  
> 2. *O nosso Azure Container Registry (ACR) chamado `acrdimdim562795`. Clicando em Repositórios, vemos as duas imagens versionadas com o prefixo do meu RM: `rm562795-dimdim-app:latest` e `rm562795-dimdim-db:latest`.*  
> 3. *A Conta de Armazenamento `stdimdim562795`, onde criamos o File Share `db-dimdim-share` para garantir a persistência dos dados do banco relacional.*  
> 4. *E as duas instâncias serverless no Azure Container Instances (ACI): o `rm562795-dimdim-db` rodando PostgreSQL na porta 5432 com o volume SMB montado, e o `rm562795-dimdim-app` rodando a nossa API na porta 8080."*

---

### 💻 BLOCO 3: Repositório GitHub, Dockerfile Non-Root e Scripts CLI (2:00 - 2:45)
**O que mostrar na tela:** Repositório no GitHub aberto na tela.

> 🗣️ **O QUE FALAR:**
> *"Aqui no nosso repositório oficial do GitHub, temos toda a estrutura do projeto:*  
> - *No `app/Dockerfile`, destaco um ponto fundamental de segurança exigido no checkpoint: nossa aplicação utiliza multi-stage build e roda sob o usuário não-root `appuser:appgroup` com UID 10001, sem qualquer privilégio administrativo de root.*  
> - *No `db/init.sql`, temos o DDL completo da tabela relacional `TB_DIMDIM_TRANSACOES` com constraints, índices e carga inicial de dados no PostgreSQL, em estrito cumprimento à regra de não utilizar banco H2.*  
> - *Na pasta `scripts/`, temos o script `deploy_azure.sh` que automatizou todo o provisionamento via Azure CLI, sem uso de cliques manuais.*  
> - *E na pasta `tests/`, disponibilizamos todos os arquivos JSON usados nos testes do CRUD."*

---

### 🧪 BLOCO 4: Demonstração do CRUD & Evidências com SELECT no Banco (2:45 - 4:45)
> [!CAUTION]
> **ESTE É O BLOCO MAIS IMPORTANTE (-30 pontos se faltar!).**  
> Divida a tela ao meio: **Lado Esquerdo: Swagger UI na Nuvem** / **Lado Direito: DBeaver ou terminal com SELECT no PostgreSQL**.

#### 1. READ Inicial (SELECT):
- **Ação:** No banco, execute `SELECT * FROM TB_DIMDIM_TRANSACOES ORDER BY ID;`.
- **Fala:** *"Vamos consultar o estado inicial do banco. Vemos os 5 registros inseridos pela carga inicial."*
- **Ação:** No Swagger, execute `GET /api/transacoes`.
- **Fala:** *"A API na nuvem responde com status 200 OK trazendo exatamente os mesmos 5 registros."*

#### 2. CREATE (POST):
- **Ação:** No Swagger, abra o `POST /api/transacoes` e envie o JSON:
  ```json
  {
    "descricao": "Venda de Licença Software DimDim",
    "valor": 1250.00,
    "tipo": "ENTRADA",
    "categoria": "Vendas"
  }
  ```
- **Fala:** *"Executando o POST, recebemos o código HTTP 201 Created com o ID gerado."*
- **Ação:** No banco, execute imediatamente:  
  `SELECT * FROM TB_DIMDIM_TRANSACOES WHERE DESCRICAO LIKE '%Licença%';`
- **Fala:** *"Ao rodar o SELECT imediatamente no PostgreSQL, comprovamos que o registro foi persistido fisicamente na tabela com ID atribuído."*

#### 3. UPDATE (PUT):
- **Ação:** No Swagger, abra `PUT /api/transacoes/1` e envie:
  ```json
  {
    "descricao": "Salário Mensal - DimDim Tecnologia (Reajustado)",
    "valor": 8200.00,
    "tipo": "ENTRADA",
    "categoria": "Salário"
  }
  ```
- **Fala:** *"Executando o PUT para atualizar a transação de ID 1, a API retorna 200 OK."*
- **Ação:** No banco, execute:  
  `SELECT ID, DESCRICAO, VALOR FROM TB_DIMDIM_TRANSACOES WHERE ID = 1;`
- **Fala:** *"No SELECT do banco, vemos o valor atualizado para 8200.00 e a nova descrição."*

#### 4. DELETE:
- **Ação:** No Swagger, execute `DELETE /api/transacoes/5`.
- **Fala:** *"Vamos excluir a transação de ID 5. Retorno 204 No Content."*
- **Ação:** No banco, execute:  
  `SELECT * FROM TB_DIMDIM_TRANSACOES WHERE ID = 5;`
- **Fala:** *"O SELECT confirma que o registro 5 não existe mais no banco de dados."*

#### 5. RESUMO FINANCEIRO (GET):
- **Ação:** No Swagger, execute `GET /api/transacoes/resumo`.
- **Fala:** *"E o endpoint de resumo calcula em tempo real o total de entradas, saídas e o saldo consolidado do DimDim."*

---

### 💾 BLOCO 5: Comprovação da Persistência no Azure File Share (4:45 - 5:30)
**O que mostrar na tela:** Portal Azure -> Storage Account `stdimdim562795` -> File shares -> `db-dimdim-share`.

> 🗣️ **O QUE FALAR:**
> *"Para comprovar a persistência de dados em nuvem: aqui dentro do Azure Portal, na nossa Storage Account `stdimdim562795`, acessamos o File Share `db-dimdim-share`. Como podemos ver, todos os arquivos de dados do PostgreSQL (`base/`, `global/`, `pg_wal/`) estão fisicamente armazenados no Azure Files.*  
> *Isso garante que se o container do ACI for reiniciado ou recriado, nenhuma informação é perdida."*

---

### 🏁 BLOCO 6: Conclusão & Encerramento (5:30 - 6:00)
**O que mostrar na tela:** Documento PDF de Entrega (`DimDim_container.pdf`) ou tela final com os links.

> 🗣️ **O QUE FALAR:**
> *"Com isso, cobrimos 100% dos requisitos do Checkpoint:*  
> - *Arquitetura PaaS com ACR e ACI na Azure;*  
> - *Imagens e containers com prefixo do RM;*  
> - *App seguro rodando como usuário não-root;*  
> - *Banco relacional PostgreSQL persistido em Azure File Share, sem uso de H2;*  
> - *Provisionamento 100% automatizado via Azure CLI;*  
> - *Evidências completas do CRUD comprovadas via SELECT.*  
> *Agradecemos a atenção do professor João Menk e encerramos aqui a nossa apresentação. Muito obrigado!"*

---

## 🛠️ Comandos SQL Prontos para Copiar e Colar Durante a Gravação

```sql
-- 1. CONSULTA INICIAL
SELECT ID, DESCRICAO, VALOR, TIPO, CATEGORIA FROM TB_DIMDIM_TRANSACOES ORDER BY ID;

-- 2. APÓS O POST
SELECT * FROM TB_DIMDIM_TRANSACOES WHERE DESCRICAO LIKE '%Licença%';

-- 3. APÓS O PUT
SELECT ID, DESCRICAO, VALOR, TIPO FROM TB_DIMDIM_TRANSACOES WHERE ID = 1;

-- 4. APÓS O DELETE
SELECT COUNT(*) AS TOTAL_REGISTROS FROM TB_DIMDIM_TRANSACOES;
SELECT * FROM TB_DIMDIM_TRANSACOES WHERE ID = 5;
```
