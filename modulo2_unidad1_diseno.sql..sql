-- ==============================================================
-- Archivo: modulo2_unidad1_diseño.sql
-- Propósito: Creación de tablas para sistema de gestión de ventas
-- ==============================================================

-- 1. Definición de la Tabla de Clientes
CREATE TABLE clientes (
    id_cliente INT,                -- INT: Número entero, ideal para identificadores porque no llevan decimales.
    nombre VARCHAR(100),           -- VARCHAR(100): Texto variable hasta 100 caracteres. Optimiza el espacio de almacenamiento.
    perfil_bio TEXT,               -- TEXT: Permite textos muy largos sin un límite estricto, ideal para notas o biografías.
    fecha_registro DATE            -- DATE: Guarda exclusivamente año-mes-día, ya que para el registro no nos interesa la hora exacta.
);

-- 2. Definición de la Tabla de Productos
CREATE TABLE productos (
    id_producto INT,               -- INT: Número entero para identificar al producto.
    descripcion VARCHAR(255),      -- VARCHAR(255): Texto de longitud media, es el estándar de la industria para descripciones cortas.
    precio DECIMAL(10, 2),         -- DECIMAL(10, 2): Fundamental para dinero. Soporta 10 dígitos en total, reservando 2 para los centavos. (No se usa FLOAT para evitar errores de redondeo).
    esta_activo BIT                -- BIT: Es un tipo de dato en SQL Server que solo acepta 0 o 1 (Falso/Verdadero). Es la forma más eficiente de saber si está a la venta.
);
