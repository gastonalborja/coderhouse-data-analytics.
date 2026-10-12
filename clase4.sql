select id_venta, cantidad, precio_unitario, id_cliente
        from ventas 
        where id_cliente = 1 or id_cliente = 2 id_cliente = 3;

        -- o se puede usar la cláusula IN para simplificar la consulta:
        select id_venta, cantidad, precio_unitario, id_cliente
        from ventas 
        where id_cliente IN (1, 2, 3);


    --coindicion no posible:
    select id_venta, cantidad, precio_unitario, id_cliente
        from ventas 
        where id_cliente = 1 and id_cliente = 5;  --es imposible que un cliente tenga dos id_cliente diferentes al mismo tiempo, por lo que esta consulta no devolverá resultados. 

  
  --ORDER BY
    select id_venta,
    cantidad * precio_unitario as total
    from ventas
    order by total desc;  --ordenar de mayor a menor
  

   select id_venta,
    cantidad * precio_unitario as total
    from ventas
    order by total asc;  --ordenar de menor a mayor. Pero hay que aclararlo



select id_venta,
    cantidad * precio_unitario as total
    from ventas
    where total >500;  --esta consulta no funcionará porque no se puede usar un alias en la cláusula WHERE. En su lugar, se debe repetir la expresión: slect id_venta,
     
     -- en su lugar hay que cambiar el alias por la expresión completa en la cláusula WHERE:
     select id_venta
     from ventas
     where cantidad * precio_unitario > 500;  --esta consulta funcionará correctamente y devolverá todas las ventas cuyo total sea mayor a 500.


SELECT COUNT(*) AS cantidad_de_ventas
FROM ventas;
-- aca se crea un alias para la columna que devuelve la cantidad de ventas, lo que facilita la lectura del resultado.

select * from ventas 

SELECT  SUM(cantidad) AS unidades_vendidas,
         SUM(cantidad * precio_unitario) AS total_ventas
FROM ventas;

SELECT AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas;

select * from ventas 


select
    id_cliente,
    sum (cantidad * precio_unitario) as total
from ventas;
--Column 'ventas.id_cliente' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

--Primero hay que agrupar por id_cliente para poder sumar el total de ventas por cliente: GROUP BY
select
    id_cliente,
    sum (cantidad * precio_unitario) as total
from ventas
group by id_cliente
ORDER BY total;


--EN detalle GROUP BY:
-- G1.1  Ampliar el dataset a seis meses. De paso, repaso del INSERT.
--       Repetible: primero borra lo que haya agregado antes.
DELETE FROM ventas WHERE id_venta > 10;

INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    (11, 2, 2,  3,   28.00, '2024-01-12'),
    (12, 3, 6,  1,   95.00, '2024-01-18'),
    (13, 1, 4,  2,  120.00, '2024-01-25'),
    (14, 5, 2,  4,   28.00, '2024-01-30'),
    (15, 4, 3,  1,  450.00, '2024-02-05'),
    (16, 2, 5,  2,  130.00, '2024-02-09'),
    (17, 1, 6,  3,   95.00, '2024-02-14'),
    (18, 3, 4,  1,  120.00, '2024-02-20'),
    (19, 5, 2,  5,   28.00, '2024-02-27'),
    (20, 1, 1,  1, 1200.00, '2024-04-03'),
    (21, 3, 3,  2,  450.00, '2024-04-08'),
    (22, 2, 4,  3,  120.00, '2024-04-15'),
    (23, 5, 5,  2,  130.00, '2024-04-19'),
    (24, 4, 6,  2,   95.00, '2024-04-24'),
    (25, 1, 2,  6,   28.00, '2024-04-29'),
    (26, 2, 1,  2, 1200.00, '2024-05-06'),
    (27, 4, 3,  1,  450.00, '2024-05-11'),
    (28, 3, 5,  3,  130.00, '2024-05-17'),
    (29, 5, 4,  1,  120.00, '2024-05-23'),
    (30, 1, 6,  2,   95.00, '2024-05-28'),
    (31, 3, 1,  1, 1200.00, '2024-06-04'),
    (32, 2, 2, 10,   28.00, '2024-06-11'),
    (33, 4, 4,  2,  120.00, '2024-06-18'),
    (34, 5, 3,  1,  450.00, '2024-06-25');

select * from ventas;

select count(*) as ventas, count(distinct month(fecha_venta)) as meses
from ventas;
go

select *
from ventas;

SELECT
    YEAR(fecha_venta) AS anio,
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS facturacion,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;


--HAVING
select *
from ventas;

SELECT id_cliente,
    COUNT(*) AS pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
    --case when lo aplico para hacer una subconsulta. 
    FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1  --filtra los clientes que hayan realizado más de  una compra.
ORDER BY pedidos desc;  --ordenar de mayor a menor por cantidad de pedidos.


-- H.3  CASE WHEN. ES la Consulta 4 del entregable.
select*
from ventas;

SELECT YEAR(fecha_venta)   AS anio,
       MONTH(fecha_venta)  AS mes,
       SUM(cantidad * precio_unitario) AS facturacion,
       CASE WHEN SUM(cantidad * precio_unitario) >
                 (SELECT AVG(total_mes) --subconsulta que calcula el promedio de facturación mensual
                  FROM  (SELECT SUM(cantidad * precio_unitario) AS total_mes --Segunda subconsulta que calcula la facturación mensual
                         FROM   ventas
                         GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)) t)
            THEN 'Por encima'
            ELSE 'Por debajo'
       END                 AS comparativa
FROM   ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;
GO