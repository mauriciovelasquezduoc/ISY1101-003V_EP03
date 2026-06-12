-- ============================================================
-- Inicialización de la base de datos: alumnos
-- Alineado con AlumnoEntity.java (tabla: alumnos)
-- ============================================================

-- Crear tabla principal
CREATE TABLE IF NOT EXISTS alumnos (
    id        BIGSERIAL    PRIMARY KEY,
    nombre    VARCHAR(100) NOT NULL,
    apellido  VARCHAR(100) NOT NULL
);

-- Datos de ejemplo para desarrollo
INSERT INTO alumnos (nombre, apellido) VALUES
    ('Juan',    'Pérez'),
    ('Ana',     'López'),
    ('Carlos',  'Soto'),
    ('María',   'González'),
    ('Pedro',   'Ramírez'),
    ('Sofía',   'Muñoz'),
    ('Diego',   'Torres'),
    ('Valentina','Flores');
