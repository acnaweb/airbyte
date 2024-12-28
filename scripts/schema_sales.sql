

-- Cria o schema
CREATE SCHEMA sales AUTHORIZATION developer;

-- Criação da tabela sales.clientes
CREATE TABLE sales.clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(50),
    sobrenome VARCHAR(50),
    email VARCHAR(100),
    cadastrado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criação da tabela sales.pedidos
CREATE TABLE sales.pedidos (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INT REFERENCES sales.clientes(id_cliente),
    data_pedido DATE,
    valor_pedido NUMERIC(10, 2),
    status VARCHAR(20)
);

-- Inserindo dados na tabela sales.clientes
INSERT INTO sales.clientes (nome, sobrenome, email)
SELECT 
    'Nome' || generate_series(1, 10000),
    'Sobrenome' || generate_series(1, 10000),
    'cliente' || generate_series(1, 10000) || '@teste.com';

-- Verifica os dados
SELECT id_cliente, nome, sobrenome, email 
FROM sales.clientes
ORDER BY id_cliente;

-- Inserindo dados na tabela sales.pedidos
INSERT INTO sales.pedidos (id_cliente, data_pedido, valor_pedido, status)
SELECT 
    (random() * 9999 + 1)::INT,
    NOW() - (random() * 365 * INTERVAL '1 day'),
    (random() * 1000)::NUMERIC(10, 2),
    CASE
        WHEN random() < 0.5 THEN 'concluido'
        ELSE 'pendente'
    END
FROM generate_series(1, 50000);

-- Verifica os dados
SELECT * 
FROM sales.pedidos
ORDER BY id_pedido; 

-- Consulta 1: Junção e Filtros
-- Listar clientes e o número de pedidos de cada um
SELECT c.id_cliente, c.nome, c.sobrenome, COUNT(o.id_pedido) AS num_pedidos
FROM sales.clientes c
JOIN sales.pedidos o ON c.id_cliente = o.id_cliente
WHERE o.status = 'concluido'
GROUP BY c.id_cliente, c.nome, c.sobrenome
ORDER BY num_pedidos DESC;

-- Consulta 2: Junção e Filtros
-- Listar clientes e o número de pedidos de cada um (mas forçando a ordem das tabelas)
EXPLAIN ANALYZE
SELECT c.id_cliente, c.nome, c.sobrenome, num_pedidos
FROM (
  SELECT o.id_cliente, COUNT(o.id_pedido) AS num_pedidos
  FROM sales.pedidos o
  WHERE o.status = 'concluido'
  GROUP BY o.id_cliente
) AS sub
JOIN sales.clientes c ON c.id_cliente = sub.id_cliente
ORDER BY sub.num_pedidos DESC;

-- Consulta 3: Subconsulta Correlacionada
-- Subconsulta para encontrar clientes com o maior valor de pedido
-- Esta é uma query muito ruim, que não consegue retornar os dados corretos!
EXPLAIN ANALYZE
SELECT c.id_cliente, c.nome, c.sobrenome, c.email, (
    SELECT MAX(o.valor_pedido)
    FROM sales.pedidos o
    WHERE o.id_cliente = c.id_cliente
) AS max_order_amount
FROM sales.clientes c
ORDER BY max_order_amount DESC
LIMIT 10;

-- Consulta 3: Índices e Análise de Performance
-- Criação de índices para otimização
-- (CUIDADO! VAMOS MELHORAR A PERFORMANCE DE UMA QUERY RUIM)
CREATE INDEX idx_id_cliente_pedido ON sales.pedidos(id_cliente);
CREATE INDEX idx_pedido_status ON sales.pedidos(status);

-- Consulta 4: Subconsulta Correlacionada
-- Ufa! Agora sim. Query melhorada!
EXPLAIN ANALYZE
SELECT c.id_cliente, c.nome, c.sobrenome, c.email, sub.max_order_amount
FROM sales.clientes c
JOIN (
    SELECT o.id_cliente, MAX(o.valor_pedido) AS max_order_amount
    FROM sales.pedidos o
    GROUP BY o.id_cliente
) sub ON c.id_cliente = sub.id_cliente
ORDER BY sub.max_order_amount DESC
LIMIT 10;

-- Consulta 5: Consulta inicial ineficiente
-- Query Inicial (Ineficiente)
-- A consulta inicial faz múltiplas subconsultas desnecessárias, o que pode tornar a execução lenta.
EXPLAIN ANALYZE
SELECT id_cliente, nome, sobrenome, email, total_pedidos
FROM (
    SELECT 
        c.id_cliente,
        c.nome,
        c.sobrenome,
        c.email,
        (SELECT SUM(o.valor_pedido) FROM sales.pedidos o WHERE o.id_cliente = c.id_cliente) AS total_pedidos
    FROM sales.clientes c
) subquery
WHERE total_pedidos > 1000
ORDER BY total_pedidos DESC
LIMIT 10;

-- Consulta 6: Query Otimizada (Usando CTE)
-- Usando CTE, podemos calcular a soma total dos pedidos por cliente uma vez e depois filtrar os resultados, melhorando a eficiência da consulta.
-- Consulta otimizada usando CTE
EXPLAIN ANALYZE
WITH TotalPedidos AS (
    SELECT 
        o.id_cliente,
        SUM(o.valor_pedido) AS total_pedidos
    FROM sales.pedidos o
    GROUP BY o.id_cliente
)
SELECT 
    c.id_cliente,
    c.nome,
    c.sobrenome,
    c.email,
    t.total_pedidos
FROM sales.clientes c
JOIN TotalPedidos t ON c.id_cliente = t.id_cliente
WHERE t.total_pedidos > 1000
ORDER BY t.total_pedidos DESC
LIMIT 10;







