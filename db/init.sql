-- ===================================================================
-- SCRIPT DDL: Banco de Dados Relacional PostgreSQL - Projeto DimDim
-- 1º Checkpoint 2º Semestre: DevOps Tools & Cloud Computing (FIAP)
-- ===================================================================

-- Criação da Tabela de Transações Financeiras do DimDim
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

-- Criação de Índices para Otimização de Consultas por Tipo e Categoria
CREATE INDEX IF NOT EXISTS IDX_TRANSACOES_TIPO ON TB_DIMDIM_TRANSACOES(TIPO);
CREATE INDEX IF NOT EXISTS IDX_TRANSACOES_CATEGORIA ON TB_DIMDIM_TRANSACOES(CATEGORIA);

-- Inserção de Carga Inicial para Demonstração de Evidências CRUD
INSERT INTO TB_DIMDIM_TRANSACOES (DESCRICAO, VALOR, TIPO, CATEGORIA, DATA_TRANSACAO) VALUES
('Salário Mensal - DimDim Tecnologia', 7500.00, 'ENTRADA', 'Salário', CURRENT_TIMESTAMP - INTERVAL '5 days'),
('Pagamento Aluguel Escritório', 2200.00, 'SAIDA', 'Moradia', CURRENT_TIMESTAMP - INTERVAL '4 days'),
('Consultoria Cloud Azure DimDim', 3800.00, 'ENTRADA', 'Serviços', CURRENT_TIMESTAMP - INTERVAL '3 days'),
('Supermercado e Suprimentos', 850.50, 'SAIDA', 'Alimentação', CURRENT_TIMESTAMP - INTERVAL '2 days'),
('Assinatura Microsoft Azure Cloud', 420.00, 'SAIDA', 'Infraestrutura', CURRENT_TIMESTAMP - INTERVAL '1 day');
