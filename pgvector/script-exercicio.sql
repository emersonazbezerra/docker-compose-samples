-- =========================================================
-- PARTE 1 — PREPARAÇÃO DO AMBIENTE
-- =========================================================

-- Exercício 1
CREATE DATABASE ia_semantica;
\c ia_semantica;

CREATE EXTENSION IF NOT EXISTS vector;

-- Exercício 2
\dx

-- =========================================================
-- PARTE 2 — TABELAS E INSERÇÕES
-- =========================================================

-- Exercício 3
CREATE TABLE documentos (
    id SERIAL PRIMARY KEY,
    titulo TEXT,
    conteudo TEXT,
    embedding VECTOR(3)
);

-- Exercício 4
INSERT INTO documentos (titulo, conteudo, embedding) VALUES
('IA Generativa', 'Modelos de linguagem generativos', '[0.8, 0.1, 0.3]'),
('Machine Learning', 'Aprendizado supervisionado e não supervisionado', '[0.7, 0.2, 0.4]'),
('Deep Learning', 'Redes neurais profundas e convolucionais', '[0.9, 0.05, 0.2]'),
('Processamento de Linguagem', 'Técnicas de NLP com transformers', '[0.75, 0.15, 0.35]'),
('Big Data', 'Análise de grandes volumes de dados', '[0.2, 0.8, 0.1]');

-- =========================================================
-- PARTE 3 — CONSULTAS DE SIMILARIDADE
-- =========================================================

-- Exercício 5 (Cosine)
SELECT id, titulo, embedding <=> '[0.8, 0.1, 0.3]' AS distancia
FROM documentos
ORDER BY embedding <=> '[0.8, 0.1, 0.3]'
LIMIT 3;

-- Exercício 6 (Euclidiana)
SELECT id, titulo, embedding <-> '[0.8, 0.1, 0.3]' AS distancia
FROM documentos
ORDER BY embedding <-> '[0.8, 0.1, 0.3]'
LIMIT 3;

-- Exercício 7 (Inner Product)
SELECT id, titulo, embedding <#> '[0.8, 0.1, 0.3]' AS produto_interno
FROM documentos
ORDER BY embedding <#> '[0.8, 0.1, 0.3]'
LIMIT 3;

-- =========================================================
-- PARTE 4 — ÍNDICES VETORIAIS
-- =========================================================

-- Exercício 8
CREATE INDEX ON documentos USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 50);

-- Exercício 9
DROP INDEX IF EXISTS documentos_embedding_idx;
CREATE INDEX documentos_embedding_idx
ON documentos USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Exercício 10
EXPLAIN ANALYZE
SELECT * FROM documentos
ORDER BY embedding <=> '[0.8, 0.1, 0.3]'
LIMIT 3;

-- =========================================================
-- PARTE 5 — BM25 E CONSULTAS HÍBRIDAS
-- =========================================================

-- Exercício 11
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX documentos_conteudo_idx
ON documentos
USING gin (conteudo gin_trgm_ops);

-- Exercício 12
SELECT id, titulo, similarity(conteudo, 'inteligência') AS score
FROM documentos
ORDER BY score DESC
LIMIT 3;

-- Exercício 13 (Combinação Híbrida)
SELECT id, titulo,
    0.7 * (1 - (embedding <=> '[0.8, 0.1, 0.3]')) +
    0.3 * similarity(conteudo, 'inteligência') AS score_hibrido
FROM documentos
ORDER BY score_hibrido DESC
LIMIT 5;

-- =========================================================
-- PARTE 6 — AVANÇADO
-- =========================================================

-- Exercício 14
INSERT INTO documentos (titulo, conteudo, embedding)
SELECT 'Doc ' || i, 'Conteúdo aleatório ' || i,
       ARRAY[random(), random(), random()]::vector(3)
FROM generate_series(1,100) AS s(i);

-- Exercício 15
ALTER TABLE documentos ADD COLUMN embedding_norm VECTOR(3);

UPDATE documentos
SET embedding_norm = embedding / sqrt(embedding <#> embedding);

-- Exercício 16
CREATE OR REPLACE FUNCTION atualiza_norm()
RETURNS trigger AS $$
BEGIN
  NEW.embedding_norm := NEW.embedding / sqrt(NEW.embedding <#> NEW.embedding);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_norm
BEFORE INSERT OR UPDATE ON documentos
FOR EACH ROW
EXECUTE FUNCTION atualiza_norm();

-- Exercício 17
ALTER TABLE documentos ADD COLUMN metadados JSONB;

UPDATE documentos
SET metadados = jsonb_build_object('autor', 'Ricardo', 'categoria', 'IA', 'data', now())
WHERE id <= 5;

-- Exercício 18
SELECT id, titulo
FROM documentos
WHERE metadados->>'categoria' = 'IA'
AND embedding <=> '[0.8, 0.1, 0.3]' < 0.2;

-- =========================================================
-- PARTE 7 — VISUALIZAÇÃO
-- =========================================================

-- Exercício 19
SELECT AVG(embedding <=> d2.embedding) AS media_similaridade
FROM documentos d1, documentos d2
WHERE d1.id <> d2.id;

-- Exercício 20
CREATE VIEW vw_top_similares AS
SELECT d1.id AS id_origem, d2.id AS id_similar,
       d1.titulo AS titulo_origem, d2.titulo AS titulo_similar,
       d1.embedding <=> d2.embedding AS distancia
FROM documentos d1, documentos d2
WHERE d1.id <> d2.id
ORDER BY d1.id, distancia
LIMIT 3;