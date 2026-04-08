CREATE TABLE customers (
 id_user SERIAL PRIMARY KEY,
 fname VARCHAR NOT NULL,
 lname VARCHAR NOT NULL,
 balance NUMERIC(10, 2) NOT NULL
);

INSERT INTO customers (fname, lname, balance)
VALUES
 ('Esteban', 'Vida', 1700),
 ('Saturnina', 'Sánchez', 500),
 ('Teresa', 'Sosa', 500);


-- Función para capturar balance
CREATE OR REPLACE FUNCTION capturar_balance(p_id INT)
RETURNS NUMERIC AS $$
DECLARE
    current_balance NUMERIC;
BEGIN
    SELECT balance INTO current_balance
    FROM customers
    WHERE id_user = p_id;

    IF current_balance IS NULL THEN
        RAISE EXCEPTION 'Este usuario no existe';
    END IF;

    RETURN current_balance;
END;
$$ LANGUAGE plpgsql;


-- Procedimiento para transferir fondos
CREATE OR REPLACE PROCEDURE transferir_fondos(
    origin INT,
    destino INT,
    monto NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    origin_balance NUMERIC;
BEGIN
    -- Obtener balance del usuario origen
    SELECT balance INTO origin_balance
    FROM customers
    WHERE id_user = origin;

    IF origin_balance IS NULL THEN
        RAISE EXCEPTION 'Usuario origen no existe';
    END IF;

    IF origin_balance < monto THEN
        RAISE EXCEPTION 'Fondos insuficientes';
    END IF;

    -- Descontar al origen
    UPDATE customers
    SET balance = balance - monto
    WHERE id_user = origin;

    -- Acreditar al destino
    UPDATE customers
    SET balance = balance + monto
    WHERE id_user = destino;
END;
$$;


-- Ejemplos de uso
CALL transferir_fondos(1, 2, 200);   -- Esteban transfiere 200 a Saturnina
SELECT * FROM customers;

CALL transferir_fondos(2, 3, 100);   -- Saturnina transfiere 100 a Teresa
SELECT * FROM customers;

-- Consultar balance
SELECT capturar_balance(1);          -- Balance de Esteban

