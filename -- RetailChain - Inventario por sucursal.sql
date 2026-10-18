-- RetailChain - Inventario por sucursal
-- Motor: SQL Server / Azure SQL Edge (T-SQL).
-- Ejecutar en la base elegida para esta practica.

DROP TABLE IF EXISTS inventario_sucursal_norte;
DROP TABLE IF EXISTS inventario_sucursal_sur;
GO

CREATE TABLE inventario_sucursal_norte (
    id_producto     INT,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria       VARCHAR(50),
    stock           INT          NOT NULL
);

CREATE TABLE inventario_sucursal_sur (
    id_producto     INT,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria       VARCHAR(50),
    stock           INT          NOT NULL
);

-- Sucursal Norte
INSERT INTO inventario_sucursal_norte VALUES (101, 'Laptop Pro 15',      'Computación',  8);
INSERT INTO inventario_sucursal_norte VALUES (102, 'Mouse Inalámbrico',  'Accesorios',  30);
INSERT INTO inventario_sucursal_norte VALUES (103, 'Monitor 4K 27"',     'Computación',  5);
INSERT INTO inventario_sucursal_norte VALUES (104, 'Teclado Mecánico',   'Accesorios',  20);
INSERT INTO inventario_sucursal_norte VALUES (105, 'Auriculares BT Pro', 'Audio',       15);

-- Estos productos también existen en la Sucursal Sur (importantes para UNION)
INSERT INTO inventario_sucursal_norte VALUES (106, 'SSD Externo 1TB',    'Almacenamiento', 10);
INSERT INTO inventario_sucursal_norte VALUES (107, 'Webcam HD 1080p',    'Accesorios',  12);

-- Sucursal Sur
INSERT INTO inventario_sucursal_sur VALUES (103, 'Monitor 4K 27"',     'Computación',   3);
INSERT INTO inventario_sucursal_sur VALUES (104, 'Teclado Mecánico',   'Accesorios',   18);
INSERT INTO inventario_sucursal_sur VALUES (106, 'SSD Externo 1TB',    'Almacenamiento', 7);

-- Estos productos son exclusivos de la Sucursal Sur
INSERT INTO inventario_sucursal_sur VALUES (108, 'Laptop Basic 14',    'Computación',   6);
INSERT INTO inventario_sucursal_sur VALUES (109, 'Parlante Bluetooth', 'Audio',        22);
INSERT INTO inventario_sucursal_sur VALUES (110, 'Hub USB-C 7p',       'Accesorios',   35);
INSERT INTO inventario_sucursal_sur VALUES (111, 'Webcam HD 1080p',    'Accesorios',    9);

-- CONSULTA 1: UNION - Catalogo unificado (11 filas).
-- Se omite stock porque es un dato del inventario de cada sucursal.
-- UNION compara todos los campos seleccionados, no solo el ID.
SELECT id_producto, nombre_producto, categoria
FROM inventario_sucursal_norte
UNION
SELECT id_producto, nombre_producto, categoria
FROM inventario_sucursal_sur
ORDER BY id_producto;

-- CONSULTA 2: UNION ALL - Inventario completo (14 filas).
-- Conservamos cada registro con su stock e indicamos su sucursal de origen.
SELECT id_producto, nombre_producto, categoria, stock, 'Norte' AS sucursal
FROM inventario_sucursal_norte
UNION ALL
SELECT id_producto, nombre_producto, categoria, stock, 'Sur' AS sucursal
FROM inventario_sucursal_sur
ORDER BY id_producto, sucursal;

-- CONSULTA 3: COMPARACION DE RESULTADOS.
-- Usamos las mismas tres columnas en ambos conteos para comparar operadores.
-- Resultado: filas_union = 11.
SELECT COUNT(*) AS filas_union
FROM (
    SELECT id_producto, nombre_producto, categoria
    FROM inventario_sucursal_norte
    UNION
    SELECT id_producto, nombre_producto, categoria
    FROM inventario_sucursal_sur
) AS resultado_union;

-- Resultado: filas_union_all = 14.
SELECT COUNT(*) AS filas_union_all
FROM (
    SELECT id_producto, nombre_producto, categoria
    FROM inventario_sucursal_norte
    UNION ALL
    SELECT id_producto, nombre_producto, categoria
    FROM inventario_sucursal_sur
) AS resultado_union_all;


-- COMPLEMENTO: 14 registros de inventario no son 14 unidades de stock.
-- Para saber cuantas unidades fisicas hay se suma stock (200 unidades).
SELECT COUNT(*) AS registros_inventario,
       SUM(stock) AS unidades_stock_total
FROM (
    SELECT stock FROM inventario_sucursal_norte
    UNION ALL
    SELECT stock FROM inventario_sucursal_sur
) AS inventario_completo;



