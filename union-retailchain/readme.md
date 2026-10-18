RetailChain: UNION y UNION ALL

Autor: Gaston Alborja  
Fecha de preparación: 18 de octubre de 2026

## Objetivo y archivos

Combinar los inventarios de las sucursales Norte y Sur para obtener un catálogo único y revisar todos los registros de stock.

```text
union-retailchain/
├── schema.sql
├── soluciones.sql
└── README.md
```

`schema.sql` crea las dos tablas y carga los 14 registros de la consigna: 7 por sucursal. `soluciones.sql` contiene las consultas y sus resultados esperados. Los scripts están preparados para SQL Server / Azure SQL Edge. Se ejecuta primero el esquema y después las soluciones, en la misma base elegida para la práctica. Repetir el esquema elimina y recrea las dos tablas de inventario.

GitHub permite guardar y compartir los archivos. Para ejecutar las consultas hay que conectarse al motor SQL desde una herramienta como VS Code o SSMS.

## 1. ¿Cuántas filas devuelve cada consulta y por qué?

La Consulta 1 devuelve 11 filas. Seleccioné `id_producto`, `nombre_producto` y `categoria` porque el objetivo es armar un catálogo de productos, sin mezclarlo con las cantidades de cada sucursal.

Las filas de los productos 103, Monitor 4K 27", 104, Teclado Mecánico, y 106, SSD Externo 1TB, coinciden en esas tres columnas en ambas sucursales. UNION deja una sola aparición de cada una: 14 registros menos 3 repeticiones da 11 filas.

La Webcam HD 1080p aparece con los IDs 107 y 111. Aunque tiene el mismo nombre y categoría, las filas tienen distinto ID y UNION conserva ambas. La consulta no puede decidir por sí sola si son productos distintos o un problema de codificación.

La Consulta 2 devuelve los 14 registros de inventario mediante UNION ALL. Incluí `stock` y una columna `sucursal` para identificar la cantidad y el origen de cada registro. Así se conservan las 5 unidades del monitor en Norte y las 3 de Sur, por ejemplo.

En la Consulta 3 comparé ambos operadores seleccionando exactamente las mismas tres columnas del catálogo. Los conteos son 11 con UNION y 14 con UNION ALL.

Si agregara `stock` al UNION del catálogo, obtendría 14 filas: los productos compartidos tienen cantidades distintas y sus filas ya no serían idénticas. Por ejemplo, el monitor tiene stock 5 en Norte y 3 en Sur. Si agregara la sucursal a ese UNION, también distinguiría ambas filas.

El complemento final muestra 14 registros y 200 unidades de stock. COUNT(*) cuenta filas; SUM(stock) suma las cantidades físicas. Cada sucursal tiene 100 unidades.

## 2. ¿Por qué UNION ALL suele ser más eficiente?

UNION ALL concatena los resultados y conserva las repeticiones. UNION además tiene que detectar y eliminar las filas duplicadas. Para hacerlo, el motor puede usar una ordenación o una operación de hash, según el plan de ejecución. Ese trabajo adicional puede consumir más memoria y procesamiento.

Por eso elegiría UNION ALL cuando necesito todas las filas o sé que las fuentes no se superponen. La diferencia de rendimiento depende del volumen, los índices y el plan; en esta práctica no medí tiempos de ejecución.

## 3. ¿En qué otros casos de negocio usaría cada uno?

Usaría UNION para:

- Armar una lista única de emails a partir de los inscriptos en dos eventos, seleccionando solo el email, para evitar enviar la misma invitación dos veces a quien fue a ambos.
- Unificar códigos de proveedores aprobados por dos áreas de una empresa, seleccionando el código, para obtener el conjunto de proveedores habilitados sin repetirlos.

Usaría UNION ALL para:

- Consolidar marcaciones de entrada y salida de varias oficinas. Dos registros con los mismos valores pueden representar eventos distintos que necesito conservar para auditar.
- Reunir líneas de facturas de distintos meses para calcular ingresos. Eliminar filas por tener los mismos valores podría borrar operaciones válidas y reducir el total.

En los cuatro casos definiría primero qué identifica un registro y si corresponde conservar las repeticiones.

## 4. ¿Qué pasa si las columnas no coinciden?

Cada SELECT de una unión debe devolver la misma cantidad de columnas, en el mismo orden lógico y con tipos compatibles por posición.

Si Norte devuelve `id_producto, nombre_producto, categoria` y Sur devuelve solo `id_producto, nombre_producto`, SQL Server rechaza la consulta porque las listas tienen distinta cantidad de expresiones.

Los tipos no necesitan ser idénticos: SQL Server puede aplicar una conversión implícita si son compatibles. Si la conversión no es posible, devuelve un error de incompatibilidad de tipos o de conversión. Por ejemplo, unir un ID entero con un nombre como 'Laptop Pro 15' en la misma posición puede hacer que intente convertir ese texto en un número y falle.

Incluso si la consulta se ejecuta, mezclar columnas en distinto orden puede producir un resultado incorrecto. Por eso mantengo el mismo orden en ambos SELECT y coloco ORDER BY al final de toda la unión.

## Resultados esperados

| Resultado | Valor |
|---|---:|
| Registros de Norte | 7 |
| Registros de Sur | 7 |
| Catálogo con UNION | 11 filas |
| Inventario con UNION ALL | 14 filas |
| Conteo comparativo UNION | 11 |
| Conteo comparativo UNION ALL | 14 |
| Stock físico total | 200 unidades |
