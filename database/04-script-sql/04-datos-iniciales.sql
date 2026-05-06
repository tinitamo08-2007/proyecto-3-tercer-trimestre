-- =============================================================================
-- 04 - DATOS INICIALES
-- Sistema de Gestión de Granja - Catálogos base y usuario administrador
-- =============================================================================
-- Dependencias: requiere que las tablas existan (ejecutar 01-schema.sql primero).
-- NO es idempotente: si ya hay datos, los INSERTs van a fallar por restricciones
-- UNIQUE. Si necesitás recargar, ejecutá primero 99-drop.sql + 01-schema.sql.
-- =============================================================================

USE granja_db;

-- -----------------------------------------------------------------------------
-- Roles disponibles en el sistema
-- -----------------------------------------------------------------------------
INSERT INTO roles (nombre, descripcion) VALUES
    ('ADMIN',       'Administrador del sistema'),
    ('VETERINARIO', 'Profesional veterinario'),
    ('ENCARGADO',   'Encargado de la granja'),
    ('PEON',        'Peón rural');

-- -----------------------------------------------------------------------------
-- Especies presentes en la granja
-- -----------------------------------------------------------------------------
INSERT INTO especies (nombre, nombre_cientifico) VALUES
    ('Bovino',  'Bos taurus'),
    ('Ovino',   'Ovis aries'),
    ('Porcino', 'Sus scrofa domesticus'),
    ('Equino',  'Equus caballus'),
    ('Aves',    'Gallus gallus domesticus');

-- -----------------------------------------------------------------------------
-- Razas asociadas a cada especie
-- -----------------------------------------------------------------------------
INSERT INTO razas (id_especie, nombre) VALUES
    (1, 'Holstein'),
    (1, 'Aberdeen Angus'),
    (1, 'Hereford'),
    (2, 'Merino'),
    (2, 'Corriedale'),
    (3, 'Yorkshire'),
    (3, 'Duroc'),
    (4, 'Criollo'),
    (5, 'Leghorn');

-- -----------------------------------------------------------------------------
-- Ubicaciones físicas de la granja
-- -----------------------------------------------------------------------------
INSERT INTO ubicaciones (nombre, tipo, capacidad_max) VALUES
    ('Corral 1',     'CORRAL',  50),
    ('Corral 2',     'CORRAL',  50),
    ('Potrero Norte','POTRERO', 200),
    ('Potrero Sur',  'POTRERO', 200),
    ('Establo A',    'ESTABLO', 30),
    ('Galpón Aves',  'GALPON',  500);

-- -----------------------------------------------------------------------------
-- Tipos de actividad que se pueden registrar
-- -----------------------------------------------------------------------------
INSERT INTO tipos_actividad (nombre, requiere_animales) VALUES
    ('Ordeñe',        TRUE),
    ('Alimentación',  TRUE),
    ('Vacunación',    TRUE),
    ('Desparasitado', TRUE),
    ('Limpieza',      FALSE),
    ('Mantenimiento', FALSE),
    ('Esquila',       TRUE),
    ('Pesaje',        TRUE);

-- -----------------------------------------------------------------------------
-- Usuario administrador por defecto
-- -----------------------------------------------------------------------------
-- IMPORTANTE: el password_hash de abajo es un placeholder.
-- Generar un hash real con BCrypt desde Java:
--     BCrypt.hashpw("admin123", BCrypt.gensalt())
-- y reemplazarlo, o crear el usuario desde la propia aplicación al iniciar
-- por primera vez.
-- -----------------------------------------------------------------------------
INSERT INTO empleados (documento, nombre, apellido, id_rol, telefono, email, fecha_contratacion)
VALUES ('00000000', 'Admin', 'Sistema', 1, '0000000000', 'admin@granja.local', CURRENT_DATE);

INSERT INTO usuarios (username, password_hash, id_empleado, es_admin)
VALUES ('admin', '$2a$10$REEMPLAZAR_CON_HASH_BCRYPT_REAL', 1, TRUE);

-- =============================================================================
-- FIN DEL SCRIPT 04
-- =============================================================================
