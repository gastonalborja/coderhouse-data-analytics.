-- MiniStore - Soluciones con Outer JOINs
-- Autor: Gaston Alborja
-- Fecha de preparacion: 2026-10-15
-- Motor: SQL Server / Azure SQL Edge (T-SQL).
-- Ejecutar primero schema.sql.

create database MiniStore


USE MiniStore;
GO

-- INICIO DEL ESQUEMA
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
GO

CREATE TABLE productos (
    producto_id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2)
);

-- Sin FOREIGN KEY a proposito: la actividad incluye una venta huerfana.
CREATE TABLE ventas (
    venta_id INT PRIMARY KEY,
    producto_id INT,
    cliente_id INT,
    cantidad INT NOT NULL,
    fecha_venta DATE NOT NULL
);
GO

INSERT INTO productos VALUES (101, 'Laptop Pro 15', 'Computación', 1200.00);
INSERT INTO productos VALUES (102, 'Mouse Inalámbrico', 'Accesorios', 28.00);
INSERT INTO productos VALUES (103, 'Monitor 4K 27"', 'Computación', 450.00);
INSERT INTO productos VALUES (104, 'Teclado Mecánico', 'Accesorios', 95.00);
INSERT INTO productos VALUES (105, 'Auriculares BT Pro', 'Audio', 120.00);
INSERT INTO productos VALUES (106, 'SSD Externo 1TB', 'Almacenamiento', 130.00);
INSERT INTO productos VALUES (107, 'Webcam HD 1080p', 'Accesorios', 85.00);
-- Productos nunca vendidos.
INSERT INTO productos VALUES (108, 'Hub USB-C 7p', 'Accesorios', 45.00);
INSERT INTO productos VALUES (109, 'Parlante Bluetooth', 'Audio', 60.00);

INSERT INTO ventas VALUES (1, 101, 201, 2, '2024-01-05');
INSERT INTO ventas VALUES (2, 102, 202, 5, '2024-01-08');
INSERT INTO ventas VALUES (3, 103, 203, 1, '2024-01-12');
INSERT INTO ventas VALUES (4, 101, 201, 1, '2024-02-03');
INSERT INTO ventas VALUES (5, 104, 204, 3, '2024-02-10');
INSERT INTO ventas VALUES (6, 105, 202, 2, '2024-02-18');
INSERT INTO ventas VALUES (7, 106, 205, 3, '2024-03-05');
INSERT INTO ventas VALUES (8, 102, 203, 8, '2024-03-12');
INSERT INTO ventas VALUES (9, 107, 204, 2, '2024-03-20');
-- Producto 999: no existe en el catalogo.
INSERT INTO ventas VALUES (10, 999, 205, 1, '2024-03-25');
GO

-- ================= PARTE 2: CONSULTAS =================


-- CONSULTA 1: LEFT JOIN
-- Todos los productos y sus ventas asociadas.
-- Esperado: 11 filas con 9 productos distintos; 108 y 109 sin venta.
SELECT p.producto_id,
       p.nombre,
       p.categoria,
       p.precio,
       v.venta_id,
       v.cantidad,
       v.fecha_venta
FROM productos AS p
LEFT JOIN ventas AS v ON p.producto_id = v.producto_id
ORDER BY p.producto_id, v.venta_id;

-- Filtro adicional: que productos nunca fueron vendidos? (2 filas).
SELECT p.producto_id,
       p.nombre,
       p.categoria,
       v.venta_id
FROM productos AS p
LEFT JOIN ventas AS v ON p.producto_id = v.producto_id
WHERE v.venta_id IS NULL
ORDER BY p.producto_id;

-- CONSULTA 2: RIGHT JOIN
-- Productos a la izquierda; ventas a la derecha.
-- Conserva las 10 ventas, incluida la del producto inexistente 999.
-- Se muestran ambos producto_id para distinguir el origen de cada valor.
SELECT v.venta_id,
       v.producto_id AS producto_id_en_venta,
       p.producto_id AS producto_id_en_catalogo,
       p.nombre,
       v.cliente_id,
       v.cantidad,
       v.fecha_venta
FROM productos AS p
RIGHT JOIN ventas AS v ON p.producto_id = v.producto_id
ORDER BY v.venta_id;

-- Filtro adicional: ventas sin producto en el catalogo (1 fila).
SELECT v.venta_id,
       v.producto_id AS producto_id_en_venta,
       p.producto_id AS producto_id_en_catalogo,
       p.nombre,
       v.cliente_id,
       v.cantidad,
       v.fecha_venta
FROM productos AS p
RIGHT JOIN ventas AS v ON p.producto_id = v.producto_id
WHERE p.producto_id IS NULL
ORDER BY v.venta_id;

-- CONSULTA 3: FULL OUTER JOIN
-- Auditoria completa: 12 filas = 9 coincidencias + 2 productos + 1 venta.
-- COALESCE conserva el ID disponible incluso en la venta del producto 999.
SELECT COALESCE(p.producto_id, v.producto_id) AS producto_id_auditado,
       p.producto_id AS producto_id_en_catalogo,
       p.nombre,
       v.venta_id,
       v.producto_id AS producto_id_en_venta,
       v.cliente_id,
       v.cantidad,
       v.fecha_venta,
       CASE
           WHEN p.producto_id IS NULL THEN 'Venta sin producto'
           WHEN v.venta_id IS NULL THEN 'Producto sin ventas'
           ELSE 'Coincidencia'
       END AS estado
FROM productos AS p
FULL OUTER JOIN ventas AS v ON p.producto_id = v.producto_id
ORDER BY COALESCE(p.producto_id, v.producto_id), v.venta_id;

-- Filtro adicional: solo los 3 casos sin coincidencia.
SELECT COALESCE(p.producto_id, v.producto_id) AS producto_id_auditado,
       p.nombre,
       v.venta_id,
       CASE
           WHEN p.producto_id IS NULL THEN 'Venta sin producto'
           ELSE 'Producto sin ventas'
       END AS estado
FROM productos AS p
FULL OUTER JOIN ventas AS v ON p.producto_id = v.producto_id
WHERE p.producto_id IS NULL OR v.venta_id IS NULL
ORDER BY COALESCE(p.producto_id, v.producto_id), v.venta_id;
GO


