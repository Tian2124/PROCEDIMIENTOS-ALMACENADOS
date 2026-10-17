-- 1. Tabla de Catálogo de Productos (Base propia)
CREATE TABLE IF NOT EXISTS producto (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    precio NUMERIC(10,2) NOT NULL CHECK (precio > 0)
);

-- Datos semilla iniciales
INSERT INTO producto (nombre, precio)
SELECT 'Producto A', 10.00 WHERE NOT EXISTS (SELECT 1 FROM producto WHERE id_producto = 1);
INSERT INTO producto (nombre, precio)
SELECT 'Producto B', 25.50 WHERE NOT EXISTS (SELECT 1 FROM producto WHERE id_producto = 2);
INSERT INTO producto (nombre, precio)
SELECT 'Producto C', 100.00 WHERE NOT EXISTS (SELECT 1 FROM producto WHERE id_producto = 3);


-- 2. Tabla de Auditoría de Cambios de Precio
DROP TABLE IF EXISTS auditoria_precio CASCADE;

CREATE TABLE auditoria_precio (
    id_auditoria SERIAL PRIMARY KEY,
    id_producto INT NOT NULL,
    precio_anterior NUMERIC(10,2) NOT NULL,
    precio_nuevo NUMERIC(10,2) NOT NULL,
    fecha_hora TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    usuario_bd VARCHAR(100) DEFAULT CURRENT_USER NOT NULL
);