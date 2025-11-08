-- CQL (Cassandra Query Language)
-- ------------------------------------------------------------
-- 💡 Observação:
-- Todos os comandos abaixo devem ser executados dentro do shell interativo do Cassandra (cqlsh)
-- Inicie com: $ cqlsh ou $ docker exec -it cassandra cqlsh


-- ============================================================
-- 🧭 EXPLORAÇÃO INICIAL
-- ============================================================

-- Listar todos os keyspaces existentes no cluster
DESCRIBE KEYSPACES;


-- ============================================================
-- 🏗️ CRIAÇÃO DE KEYSPACES
-- ============================================================

-- Criar um novo keyspace com replicação simples
CREATE KEYSPACE unipe WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- Verificar se o keyspace foi criado corretamente
DESCRIBE KEYSPACES;


-- ============================================================
-- 📦 SELEÇÃO DE KEYSPACE
-- ============================================================

-- Selecionar o keyspace que será utilizado
USE unipe;


-- ============================================================
-- 🧱 CRIAÇÃO DE TABELAS
-- ============================================================

-- Criar tabela 'musicas' com chave primária do tipo UUID
CREATE TABLE musicas (
    id uuid PRIMARY KEY,
    nome text,
    album text,
    artista text
);

-- Exibir detalhes da tabela
DESCRIBE TABLE musicas;


-- ============================================================
-- 🧩 INSERÇÃO DE REGISTROS
-- ============================================================

-- Inserir registros na tabela (valores de UUID devem ser válidos)
INSERT INTO musicas (id, nome, album, artista)
VALUES (a70ca7ff-6d57-4f89-be89-08421c432bb7, 'Help', 'Help', 'Beatles');

INSERT INTO musicas (id, nome, album, artista)
VALUES (1a8d6a80-33df-11e5-a151-feff819cdc9f, 'Yesterday', 'Help!', 'Beatles');

INSERT INTO musicas (id, nome, album, artista)
VALUES (04b57f0e-33df-11e5-a151-feff819cdc9f, 'Something', 'Abbey Road', 'Beatles');

INSERT INTO musicas (id, nome, album, artista)
VALUES (1a8d649a-33df-11e5-a151-feff819cdc9f, 'Blackbird', 'The Beatles', 'Beatles');

-- Visualizar todos os registros inseridos
SELECT * FROM musicas;


-- ============================================================
-- ✏️ ATUALIZAÇÃO DE REGISTROS
-- ============================================================

-- Atualizar campos de um registro existente
UPDATE musicas 
SET nome = 'Help!', album = 'Help!'
WHERE id = a70ca7ff-6d57-4f89-be89-08421c432bb7;

-- Verificar a atualização
SELECT * FROM musicas WHERE id = a70ca7ff-6d57-4f89-be89-08421c432bb7;


-- ============================================================
-- 🗑️ EXCLUSÃO DE REGISTROS
-- ============================================================

-- Excluir um registro pelo ID
DELETE FROM musicas WHERE id = a70ca7ff-6d57-4f89-be89-08421c432bb7;

-- Confirmar exclusão
SELECT * FROM musicas;


-- ============================================================
-- 🔍 CONSULTAS E ÍNDICES
-- ============================================================

-- Tentativa de busca por uma coluna que não é chave ou índice (irá falhar)
-- SELECT * FROM musicas WHERE album = 'Help!';
-- Resultado: InvalidRequest: Cannot execute this query as the column 'album' is not indexed

-- Criar índice na coluna 'album'
CREATE INDEX ON musicas (album);

-- Agora a consulta funciona
SELECT * FROM musicas WHERE album = 'Help!';


-- ============================================================
-- 🧪 EXERCÍCIO PRÁTICO (proposto no material)
-- ============================================================

-- Criar um keyspace para atividades de teste
CREATE KEYSPACE unipe WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE unipe;

-- Criar tabela de cadastro
CREATE TABLE cadastro (
    id uuid PRIMARY KEY,
    nome text,
    cargo text
);

-- Inserir dados
INSERT INTO cadastro (id, nome, cargo) VALUES (uuid(), 'Thyago', 'professor');
INSERT INTO cadastro (id, nome, cargo) VALUES (uuid(), 'Afonso', 'professor');
INSERT INTO cadastro (id, nome, cargo) VALUES (uuid(), 'Fernanda', 'aluno');
INSERT INTO cadastro (id, nome, cargo) VALUES (uuid(), 'Theo', 'aluno');
INSERT INTO cadastro (id, nome, cargo) VALUES (uuid(), 'Sophia', 'funcionario');
INSERT INTO cadastro (id, nome, cargo) VALUES (uuid(), 'Leonardo', 'funcionario');


-- Atualizar cargo e idade
UPDATE cadastro SET cargo = 'funcionario' WHERE nome = 'Theo';  -- Requer indexação de 'nome' para funcionar

-- Criar índice para permitir consultas por nome ou cargo
CREATE INDEX ON cadastro (nome);
CREATE INDEX ON cadastro (cargo);

-- Reexecutar atualização após criação do índice
UPDATE cadastro SET cargo = 'funcionario' WHERE nome = 'Theo';

-- Excluir registro
DELETE FROM cadastro WHERE nome = 'Afonso';

-- Buscar por todos os professores
SELECT * FROM cadastro WHERE cargo = 'professor';

-- Buscar por todos os alunos
SELECT * FROM cadastro WHERE cargo = 'aluno';
