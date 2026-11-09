# RetailPro - Data Analytics

RetailPro es mi proyecto académico del curso de Data Analytics. El proyecto reúne el diseño de bases de datos, las consultas SQL orientadas al negocio y la preparación, el modelado y la visualización de datos de ventas en Power BI.

## Herramientas utilizadas

- Azure SQL Edge en Docker como motor de base de datos.
- T-SQL, el dialecto de SQL Server, para escribir las consultas.
- Power BI Desktop para el análisis y la visualización, con Power Query para las transformaciones y DAX para las medidas.
- GitHub para guardar y versionar los archivos.

## Estructura del repositorio

El repositorio reúne ejercicios del curso y entregables de RetailPro.

- [RetailPro/](RetailPro/) contiene las consultas de negocio de la Pre-entrega 4.
- [Pipeline_ETL_Alborja_Gaston.pbix](Pipeline_ETL_Alborja_Gaston.pbix) corresponde a la etapa de Power BI.
- En la raíz y en las demás carpetas hay scripts de prácticas y pre-entregas de distintos módulos.

## Ejecución de los scripts SQL

Antes de ejecutar un script, reviso qué base utiliza y si crea, modifica o solo consulta datos. Los scripts del curso pueden apuntar a bases diferentes.

1. Iniciar el contenedor de Azure SQL Edge en Docker.
2. Conectarse a la instancia con un cliente compatible con T-SQL.
3. Revisar la instrucción `USE` y confirmar que la base y las tablas requeridas existan. Las consultas de las Pre-entregas 4 y 5 apuntan a `Ventas_Tech_DB`.
4. Ejecutar el script correspondiente y validar los resultados.

## Power BI

En Power BI Desktop uso Power Query para preparar los datos. Después modelo las relaciones, creo medidas con DAX y armo visualizaciones para responder preguntas de negocio sobre las ventas.

## Autor

Gastón Alborja
