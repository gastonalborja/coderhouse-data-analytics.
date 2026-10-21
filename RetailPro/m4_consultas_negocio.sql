-- Pre-entrega 4: Consultas SQL de negocio - RetailPro
-- Autor: Gaston Alborja
-- Fecha de preparacion: 2026-10-21
-- Motor utilizado: Azure SQL Edge (Docker), sintaxis T-SQL de SQL Server.
-- Base: Ventas_Tech_DB. Las cuatro consultas solo leen dbo.ventas.
-- En este modelo cada fila de ventas representa un pedido de un producto.

USE Ventas_Tech_DB;
GO

-- ============================================================
-- CONSULTA 1: RESUMEN EJECUTIVO MENSUAL
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
-- AVG calcula el importe promedio por pedido (cantidad * precio).
-- Se incluye el anio para no mezclar meses de distintos anios.
============================================================
SELECT YEAR(fecha_venta) AS anio,
       MONTH(fecha_venta) AS mes,
       SUM(cantidad * precio_unitario) AS total_facturado,
       COUNT(*) AS cantidad_pedidos,
       CAST(AVG(cantidad * precio_unitario) AS DECIMAL(18,2)) AS ticket_promedio
FROM dbo.ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;
GO

-- CONSULTA 2: RANKING DE PRODUCTOS
-- Los cinco IDs que mas facturan, con unidades y total generado.
-- El ID resuelve empates de facturacion con un orden estable.
-- ============================================================
SELECT TOP 5
       id_producto,
       SUM(cantidad) AS unidades_vendidas,
       SUM(cantidad * precio_unitario) AS total_facturado
FROM dbo.ventas
GROUP BY id_producto
ORDER BY total_facturado DESC, id_producto ASC;
GO

--===========================================================
-- CONSULTA 3: CLIENTES RECURRENTES
-- HAVING filtra los grupos de clientes despues de contar pedidos.
-- ============================================================
SELECT id_cliente,
       COUNT(*) AS cantidad_pedidos,
       SUM(cantidad * precio_unitario) AS total_gastado
FROM dbo.ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC, total_gastado DESC, id_cliente ASC;
GO 


-- ============================================================
-- CONSULTA 4: COMPARACION CON EL PROMEDIO MENSUAL
-- Paso 1: sumar la facturacion de cada mes con ventas.
-- Paso 2: AVG(...) OVER () promedia esos totales mensuales.
-- Paso 3: CASE clasifica cada mes. Tambien se contempla la igualdad.
-- El promedio se compara sin redondear; el CAST es solo para mostrarlo.
-- ============================================================
;WITH facturacion_mensual AS (
    SELECT YEAR(fecha_venta) AS anio,
           MONTH(fecha_venta) AS mes,
           SUM(cantidad * precio_unitario) AS total_facturado
    FROM dbo.ventas
    GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
), comparacion_mensual AS (
    SELECT anio,
           mes,
           total_facturado,
           AVG(total_facturado) OVER () AS promedio_mensual_general
    FROM facturacion_mensual
)
SELECT anio,
       mes,
       total_facturado,
       CAST(promedio_mensual_general AS DECIMAL(18,2)) AS promedio_mensual_general,
       CASE
           WHEN total_facturado > promedio_mensual_general THEN N'Por encima'
           WHEN total_facturado < promedio_mensual_general THEN N'Por debajo'
           ELSE N'En el promedio'
       END AS comparacion_con_promedio
FROM comparacion_mensual
ORDER BY anio, mes;
GO

-- ============================================================
-- HALLAZGOS DE NEGOCIO
-- Resultados verificados el 2026-10-21 en Ventas_Tech_DB.
-- Alcance: 34 pedidos, enero-junio de 2024; total facturado: 17028.00.
-- ============================================================
-- 1. El producto 1 lidera la facturacion con 8400.00 y 7 unidades,
--    equivalentes al 49.33% del total del periodo. Conviene priorizar
--    su disponibilidad y vigilar la concentracion de ingresos en ese ID.
--
-- 2. Marzo es el mes de mayor facturacion: 6444.00 en 10 pedidos,
--    con ticket promedio de 644.40. Supera el promedio mensual general
--    de 2838.00. Revisar las acciones comerciales de marzo para evaluar
--    cuales podrian repetirse; estos resultados no demuestran su causa.
--
-- 3. Los cinco clientes registrados son recurrentes: cuatro tienen
--    7 pedidos y uno tiene 6. El cliente 1 acumula el mayor gasto,
--    4723.00 en 7 pedidos. Evaluar acciones de fidelizacion para este
--    cliente y seguimiento de los demas, dentro del periodo analizado.
