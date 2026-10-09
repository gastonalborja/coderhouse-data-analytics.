-- Motor utilizado: Azure SQL Edge (Docker), sintaxis T-SQL compatible con SQL Server.
-- Pre-entrega 3: Ventas Tech. Base solicitada: Ventas_Tech3.
-- Ejecutar el archivo completo. Recrea las tablas y sus datos de ejemplo en esta base.

CREATE DATABASE Ventas_Tech_DB;

USE Ventas_Tech_DB;
GO
IF DB_ID(N'Ventas_Tech3') IS NULL
    EXEC(N'CREATE DATABASE Ventas_Tech3;');
GO
USE Ventas_Tech3;
GO

-- === SECCIÓN 1: DROP ===
-- Orden inverso de dependencias: primero las tablas que contienen las FK.
DROP TABLE IF EXISTS dbo.ventas;
DROP TABLE IF EXISTS dbo.productos;
DROP TABLE IF EXISTS dbo.clientes;
DROP TABLE IF EXISTS dbo.categorias;
GO

-- === SECCIÓN 2: CREATE ===
-- Las categorías se guardan en una tabla independiente (normalización).
CREATE TABLE dbo.categorias (
    id_categoria INT NOT NULL,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200) NULL,
    CONSTRAINT PK_categorias PRIMARY KEY (id_categoria)
);

CREATE TABLE dbo.clientes (
    id_cliente INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NULL,
    ciudad VARCHAR(50) NULL,
    fecha_registro DATE NOT NULL,
    CONSTRAINT PK_clientes PRIMARY KEY (id_cliente),
    CONSTRAINT UQ_clientes_email UNIQUE (email)
);

CREATE TABLE dbo.productos (
    id_producto INT NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    id_categoria INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL CONSTRAINT DF_productos_stock DEFAULT (0),
    activo BIT NOT NULL CONSTRAINT DF_productos_activo DEFAULT (1),
    CONSTRAINT PK_productos PRIMARY KEY (id_producto),
    CONSTRAINT FK_productos_categorias FOREIGN KEY (id_categoria)
        REFERENCES dbo.categorias (id_categoria)
);

CREATE TABLE dbo.ventas (
    id_venta INT NOT NULL,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    fecha_venta DATE NOT NULL,
    CONSTRAINT PK_ventas PRIMARY KEY (id_venta),
    CONSTRAINT FK_ventas_clientes FOREIGN KEY (id_cliente)
        REFERENCES dbo.clientes (id_cliente),
    CONSTRAINT FK_ventas_productos FOREIGN KEY (id_producto)
        REFERENCES dbo.productos (id_producto)
);
GO

-- === SECCIÓN 3: INSERT ===
-- Datos proporcionados por la actividad: 4 + 5 + 6 + 10 = 25 registros.
INSERT INTO dbo.categorias (id_categoria, nombre_categoria, descripcion) VALUES
    (1, N'Computación', N'Laptops, PCs y monitores'),
    (2, N'Accesorios', N'Periféricos y complementos'),
    (3, N'Audio', N'Auriculares y parlantes'),
    (4, N'Almacenamiento', N'Discos y memorias');

INSERT INTO dbo.clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
    (1, N'María López', 'maria@mail.com', N'Buenos Aires', '2024-01-05'),
    (2, N'Carlos Ruiz', 'carlos@mail.com', N'Córdoba', '2024-01-10'),
    (3, N'Ana Gómez', 'ana@mail.com', N'Rosario', '2024-02-01'),
    (4, N'Pedro Sanz', 'pedro@mail.com', N'Mendoza', '2024-02-15'),
    (5, N'Laura Torres', 'laura@mail.com', N'Tucumán', '2024-03-01');

INSERT INTO dbo.productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
    (1, N'Laptop Pro 15', 1, 1200.00, 15, 1),
    (2, N'Mouse Inalámbrico', 2, 28.00, 80, 1),
    (3, N'Monitor 4K 27', 1, 450.00, 12, 1),
    (4, N'Auriculares BT Pro', 3, 120.00, 35, 1),
    (5, N'SSD Externo 1TB', 4, 130.00, 18, 1),
    (6, N'Teclado Mecánico', 2, 95.00, 40, 1);

-- precio_unitario registra el precio aplicado al momento de cada venta.
INSERT INTO dbo.ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    (1, 1, 1, 2, 1200.00, '2024-03-05'),
    (2, 2, 2, 5, 28.00, '2024-03-06'),
    (3, 3, 3, 1, 450.00, '2024-03-07'),
    (4, 1, 4, 2, 120.00, '2024-03-08'),
    (5, 4, 5, 3, 130.00, '2024-03-10'),
    (6, 2, 6, 4, 95.00, '2024-03-11'),
    (7, 5, 1, 1, 1200.00, '2024-03-12'),
    (8, 3, 2, 8, 28.00, '2024-03-13'),
    (9, 4, 4, 1, 120.00, '2024-03-14'),
    (10, 5, 3, 2, 450.00, '2024-03-15');
GO

-- === SECCIÓN 4: VALIDACIÓN ===
SELECT * FROM dbo.categorias ORDER BY id_categoria; -- esperado: 4 filas
SELECT * FROM dbo.clientes ORDER BY id_cliente;     -- esperado: 5 filas
SELECT * FROM dbo.productos ORDER BY id_producto;   -- esperado: 6 filas
SELECT * FROM dbo.ventas ORDER BY id_venta;         -- esperado: 10 filas
GO
