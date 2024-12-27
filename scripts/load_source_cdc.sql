CREATE SCHEMA postgres;

-- Define o PATH
SET search_path TO postgres;

-- Cria um usuário no banco de dados (será usado para o Airbyte conectar no banco de dados)
CREATE USER airbyte PASSWORD 'my_pwd';

-- Permite que o usuário criado use o schema
GRANT USAGE ON SCHEMA postgres TO airbyte;

-- Concede privilégio de select as tabelas
GRANT SELECT ON ALL TABLES IN SCHEMA postgres TO airbyte;

-- Altera os privilegios
ALTER DEFAULT PRIVILEGES IN SCHEMA postgres GRANT SELECT ON TABLES TO airbyte;

-- Altera o usuário para permitir o replication login
ALTER USER airbyte REPLICATION LOGIN;

-- Cria uma tabela
CREATE TABLE cursos(id INTEGER, NAME VARCHAR(200), PRIMARY KEY (id));

-- Insere registros no banco de dados
INSERT INTO cursos VALUES(1000, 'FCD');
INSERT INTO cursos VALUES(1001, 'FED');
INSERT INTO cursos VALUES(1002, 'FADA');
INSERT INTO cursos VALUES(1003, 'FAD');
INSERT INTO cursos VALUES(1004, 'FEI');
INSERT INTO cursos VALUES(1005, 'FEM');

-- Select na tabela
SELECT * FROM cursos;

-- Cria um slot de replicação
SELECT pg_create_logical_replication_slot('airbyte_slot', 'pgoutput');

-- Cria a publicação para a tabela
CREATE PUBLICATION pub1 FOR TABLE cursos;

-- Manipula dados na tabela (execute depois de iniciar a conexão no Airbyte)
INSERT INTO cursos VALUES(1006, 'FIAMED');
DELETE FROM cursos WHERE NAME = 'FEI';

-- Cria a tabela na fonte
CREATE TABLE tb_cliente(
  id integer PRIMARY KEY,
  nome VARCHAR(200),
  updated_at timestamp DEFAULT NOW() NOT NULL
);

-- Insere alguns registros
INSERT INTO tb_cliente(id, nome) VALUES(1, 'Bob');
INSERT INTO tb_cliente(id, nome) VALUES(2, 'Maria');
INSERT INTO tb_cliente(id, nome) VALUES(3, 'Joana');

-- Verifica os registros
SELECT * FROM tb_cliente;

-- Cria a função
CREATE OR REPLACE FUNCTION dsa_fn_set_timestamp()
RETURNS TRIGGER AS '
 BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
 END;
'
LANGUAGE plpgsql;

-- Cria a trigger
CREATE TRIGGER dsa_tr_set_timestamp
  BEFORE UPDATE ON tb_cliente
  FOR EACH ROW
  EXECUTE PROCEDURE dsa_fn_set_timestamp();

SELECT * FROM tb_cliente;

UPDATE tb_cliente 
SET nome = 'Carolina' 
WHERE id = 2;

SELECT * FROM tb_cliente;

UPDATE tb_cliente 
SET nome = 'Fernando' 
WHERE id = 1;

SELECT * FROM tb_cliente;

UPDATE tb_cliente 
SET nome = 'Ana' 
WHERE id = 3;

SELECT * FROM tb_cliente;

INSERT INTO tb_cliente(id, nome) VALUES(4, 'Zico');

SELECT * FROM tb_cliente;