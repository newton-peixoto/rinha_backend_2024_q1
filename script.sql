CREATE UNLOGGED TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY NOT NULL,
    nome VARCHAR(50) NOT NULL,
    limite INTEGER NOT NULL,
    saldo INTEGER NOT NULL
);

CREATE UNLOGGED TABLE IF NOT EXISTS transacoes (
    id SERIAL PRIMARY KEY NOT NULL,
    tipo CHAR(1) NOT NULL,
    descricao VARCHAR(10) NOT NULL,
    valor INTEGER NOT NULL,
    cliente_id INTEGER NOT NULL,
    realizada_em TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cliente_id
ON transacoes(cliente_id);

create index on transacoes (id DESC)

INSERT INTO clientes (nome, limite, saldo)
VALUES
    ('Newton', 100000, 0),
    ('Joe', 80000, 0),
    ('Doe', 1000000, 0),
    ('Amy', 10000000, 0),
    ('Mel', 500000, 0);

CREATE OR REPLACE FUNCTION debitar(
	cliente_id_tx INT,
	valor_tx INT,
	descricao_tx VARCHAR(10))
RETURNS TABLE (
	novo_saldo INT,
	possui_erro BOOL,
	mensagem VARCHAR(20),
	limite INT
	)
LANGUAGE plpgsql
AS $$
DECLARE
	saldo_atual int;
	limite_atual int;
BEGIN
	PERFORM pg_advisory_xact_lock(cliente_id_tx);
	SELECT 
		c.limite,
		COALESCE(c.saldo, 0)
	INTO
		limite_atual,
		saldo_atual
	FROM clientes c
	WHERE c.id = cliente_id_tx;

	IF saldo_atual - valor_tx >= limite_atual * -1 THEN
		INSERT INTO transacoes
			VALUES(DEFAULT, 'd',descricao_tx,  valor_tx, cliente_id_tx, NOW());
		
		UPDATE clientes 
		SET saldo = saldo - valor_tx
		WHERE id = cliente_id_tx;

		RETURN QUERY
			SELECT
				saldo,
				FALSE,
				'ok'::VARCHAR(20),
				clientes.limite 
			FROM clientes
			WHERE id = cliente_id_tx;
	ELSE
		RETURN QUERY
			SELECT
				saldo,
				TRUE,
				'saldo insuficente'::VARCHAR(20),
				clientes.limite
			FROM clientes
			WHERE id = cliente_id_tx;
	END IF;
END;
$$;

CREATE OR REPLACE FUNCTION creditar(
	cliente_id_tx INT,
	valor_tx INT,
	descricao_tx VARCHAR(10))
RETURNS TABLE (
	novo_saldo INT,
	possui_erro BOOL,
	mensagem VARCHAR(20),
    limite INT
	)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(cliente_id_tx);

	INSERT INTO transacoes
		VALUES(DEFAULT, 'c',descricao_tx,  valor_tx, cliente_id_tx, NOW());

	RETURN QUERY
		UPDATE clientes
		SET saldo = saldo + valor_tx
		WHERE id = cliente_id_tx
		RETURNING saldo, FALSE, 'ok'::VARCHAR(20), clientes.limite ;
END;
$$;


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;