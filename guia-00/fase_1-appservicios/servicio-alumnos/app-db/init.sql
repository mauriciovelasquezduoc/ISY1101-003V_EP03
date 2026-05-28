-- Crear tabla de alumnos
CREATE TABLE IF NOT EXISTS duoc_alumnos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rut VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL
);

-- Insertar 5 alumnos
INSERT INTO duoc_alumnos (rut, nombre, apellido) VALUES
('12345678-9', 'Juan', 'Pérez'),
('23456789-0', 'María', 'González'),
('34567890-1', 'Carlos', 'Rodríguez'),
('45678901-2', 'Ana', 'Martínez'),
('56789012-3', 'Roberto', 'Sánchez');
