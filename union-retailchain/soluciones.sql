-- RetailChain - UNION y UNION ALL
-- Autor: Gaston Alborja
-- Fecha de preparacion: 2026-10-18
-- Ejecutar primero schema.sql en la misma base de datos.

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
