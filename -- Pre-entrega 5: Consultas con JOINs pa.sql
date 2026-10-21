-- Pre-entrega 5: Consultas con JOINs para el proyecto RetailPro
-- Autor: Gaston Alborja
-- Fecha de preparacion: 2026-10-21
-- Motor: Azure SQL Edge (Docker), sintaxis T-SQL de SQL Server.
-- Base: Ventas_Tech_DB, la misma utilizada para la pre-entrega 4.
-- Solo se consultan datos; este archivo no crea ni elimina tablas.
-- El importe utiliza el precio registrado en la venta, no el precio actual.
-- Cada registro de ventas representa un pedido de un producto.
-- Alias de tablas: v = ventas; c = clientes; p = productos; cat = categorias.

USE Ventas_Tech_DB;
GO

-- ============================================================
-- CONSULTA 1: VISTA BASE DEL PROYECTO (INNER JOIN)
-- Proposito: reunir los datos necesarios para analizar ventas en Power BI.
-- La dimension clientes aporta ciudad como atributo geografico existente.
-- Categoria permite agrupar y ciudad_cliente permite filtrar el reporte.
-- No se atribuye una region ni un segmento que el esquema no almacena.
-- ============================================================
SELECT v.id_venta,
       v.fecha_venta,
       c.id_cliente,
       c.nombre AS nombre_cliente,
       c.ciudad AS ciudad_cliente,
       p.id_producto,
       p.nombre_producto,
       cat.nombre_categoria AS categoria,
       v.cantidad,
       v.precio_unitario,
       v.cantidad * v.precio_unitario AS total_venta
FROM dbo.ventas AS v
INNER JOIN dbo.clientes AS c ON v.id_cliente = c.id_cliente
INNER JOIN dbo.productos AS p ON v.id_producto = p.id_producto
INNER JOIN dbo.categorias AS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
-- Hallazgo: Se integran las 34 ventas de enero-junio de 2024, por 17028.00,
-- con 5 clientes y 6 productos; la base enriquecida conserva toda la facturacion.
GO

-- ============================================================
-- CONSULTA 2: CLIENTES SIN VENTAS (LEFT JOIN)
-- Proposito: detectar clientes sin primera compra para acciones de CRM.
-- Se busca NULL en la PK de ventas: indica que no hubo coincidencia.
-- ============================================================
SELECT c.id_cliente,
       c.nombre AS nombre_cliente,
       c.email,
       c.fecha_registro
FROM dbo.clientes AS c
LEFT JOIN dbo.ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro, c.id_cliente;
-- Hallazgo: Aparecen 0 de los 5 clientes: todos tienen al menos una compra.
-- CRM no tiene casos sin primera compra en estos datos; puede evaluar fidelizacion.
GO

-- ============================================================
-- CONSULTA 3: PRODUCTOS SIN VENTAS (LEFT JOIN)
-- Proposito: identificar articulos sin movimiento para el area de producto.
-- LEFT JOIN con categorias tambien conserva un producto sin categoria coincidente.
-- ============================================================
SELECT p.id_producto,
       p.nombre_producto,
       cat.nombre_categoria AS categoria,
       p.precio
FROM dbo.productos AS p
LEFT JOIN dbo.ventas AS v ON p.id_producto = v.id_producto
LEFT JOIN dbo.categorias AS cat ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL
ORDER BY p.id_producto;
-- Hallazgo: Aparecen 0 de los 6 productos: todo el catalogo registra ventas.
-- Producto no detecta articulos sin movimiento historico; conviene revisar su rotacion.
GO

-- ============================================================
-- CONSULTA 4: CONSOLIDADO POR ORIGEN (UNION ALL)
-- Proposito: comparar la facturacion de los dos trimestres del primer semestre de 2024.
-- canal se CREA con un literal en cada SELECT; no existe en las tablas.
-- Las etiquetas representan periodos de origen, no canales comerciales reales.
-- Los intervalos no se superponen: cada venta del semestre se cuenta una vez.
-- Mismas columnas en ambos SELECT: fecha, importe y etiqueta de origen.
-- ============================================================
SELECT canal,
       COUNT(*) AS cantidad_pedidos,
       SUM(total) AS total_canal
FROM (
    SELECT fecha_venta,
           cantidad * precio_unitario AS total,
           N'Primer trimestre 2024' AS canal
    FROM dbo.ventas
    WHERE fecha_venta >= '20240101' AND fecha_venta < '20240401'

    UNION ALL

    SELECT fecha_venta,
           cantidad * precio_unitario AS total,
           N'Segundo trimestre 2024' AS canal
    FROM dbo.ventas
    WHERE fecha_venta >= '20240401' AND fecha_venta < '20240701'
) AS consolidado
GROUP BY canal
ORDER BY canal;
-- Hallazgo: El segundo trimestre factura 8798.00 en 15 pedidos, frente a 8230.00
-- en 19 del primero; genera 568.00 mas con menos pedidos, por lo que conviene revisar el ticket.
GO