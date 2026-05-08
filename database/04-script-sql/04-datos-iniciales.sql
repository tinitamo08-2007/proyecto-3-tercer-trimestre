-- =============================================================================
-- 04 - DATOS INICIALES
-- Sistema de Gestión de Granja - Catálogos, usuarios y dataset de prueba
-- =============================================================================
-- Dependencias:
--   - 01-schema.sql   (tablas)
--   - 03-triggers.sql (trg_actualiza_estado_salud sincroniza animales.estado_salud
--                      cuando se inserta historial; debe estar creado antes).
--
-- NO es idempotente: si ya hay datos, los INSERTs van a fallar por restricciones
-- UNIQUE / PK. Para repoblar desde cero ejecutar 99-drop.sql + 01..04 en orden.
--
-- Resumen del dataset:
--   - 18 empleados (1 admin + 17 más, dos dados de baja)
--   -  8 usuarios
--   - 80 animales repartidos en todas las especies y razas
--   - 10 eventos_animal (ventas, fallecimientos, traslados, ingresos)
--   - 25 entradas de historial_salud (incluye casos para el Notificador)
--   - 50 actividades a lo largo de ~4 semanas
--   - ~280 vínculos actividad_animal
--   - 25 logs_sistema de ejemplo
-- =============================================================================

USE granja_db;

-- =============================================================================
-- 1. CATÁLOGOS BASE
-- =============================================================================

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

-- =============================================================================
-- 2. EMPLEADOS
-- =============================================================================
-- IMPORTANTE: el password_hash de los usuarios es un placeholder.
-- Generar hashes reales con BCrypt desde Java:
--     BCrypt.hashpw("admin123", BCrypt.gensalt())
-- y reemplazarlos, o crear los usuarios desde la propia aplicación.
-- =============================================================================

-- Usuario administrador del sistema (id_empleado = 1)
INSERT INTO empleados (id_empleado, documento, nombre, apellido, id_rol, telefono, email, fecha_contratacion) VALUES
( 1, '00000000', 'Admin', 'Sistema', 1, '0000000000', 'admin@granja.local', CURRENT_DATE);

-- Veterinarios (rol 2)
INSERT INTO empleados (id_empleado, documento, nombre, apellido, id_rol, telefono, email, fecha_contratacion) VALUES
( 2, '20123456', 'María',    'González',  2, '3001234567', 'maria.gonzalez@granja.local',    '2022-03-15'),
( 3, '19876543', 'Carlos',   'Rodríguez', 2, '3009876543', 'carlos.rodriguez@granja.local',  '2021-08-01'),
( 4, '21334455', 'Lucía',    'Vargas',    2, '3016677889', 'lucia.vargas@granja.local',      '2023-02-10');

-- Encargados (rol 3)
INSERT INTO empleados (id_empleado, documento, nombre, apellido, id_rol, telefono, email, fecha_contratacion) VALUES
( 5, '25678910', 'Pedro',    'Martínez',  3, '3014561234', 'pedro.martinez@granja.local',    '2020-01-10'),
( 6, '27891234', 'Ana',      'Fernández', 3, '3015674891', 'ana.fernandez@granja.local',     '2023-05-20'),
( 7, '26554433', 'Ricardo',  'Hernández', 3, '3017788990', 'ricardo.hernandez@granja.local', '2021-11-05');

-- Peones (rol 4)
INSERT INTO empleados (id_empleado, documento, nombre, apellido, id_rol, telefono, email, fecha_contratacion) VALUES
( 8, '30112233', 'Juan',     'Pérez',     4, '3201112233', 'juan.perez@granja.local',        '2024-02-01'),
( 9, '31223344', 'Luis',     'Gómez',     4, '3202223344', NULL,                             '2024-06-15'),
(10, '32334455', 'Roberto',  'Silva',     4, '3203334455', NULL,                             '2025-01-08'),
(11, '33445566', 'Sofía',    'Castro',    4, '3204445566', 'sofia.castro@granja.local',      '2025-03-12'),
(12, '34556677', 'Diego',    'Morales',   4, '3205556677', NULL,                             '2025-09-01'),
(13, '35667788', 'Laura',    'Ruiz',      4, '3206667788', 'laura.ruiz@granja.local',        '2024-11-20'),
(14, '36778899', 'Andrés',   'Jiménez',   4, '3207778899', 'andres.jimenez@granja.local',    '2023-08-14'),
(15, '37889900', 'Carolina', 'López',     4, '3208889900', 'carolina.lopez@granja.local',    '2024-09-03'),
(16, '38990011', 'Fernando', 'Mendoza',   4, '3209990011', NULL,                             '2025-05-22'),
(17, '39001122', 'Valeria',  'Suárez',    4, '3210001122', 'valeria.suarez@granja.local',    '2024-07-08');

-- Empleados dados de baja (para probar reportes históricos y filtros por activo)
INSERT INTO empleados (id_empleado, documento, nombre, apellido, id_rol, telefono, fecha_contratacion, fecha_baja, activo, observaciones) VALUES
(18, '29998877', 'Miguel', 'Torres',    4, '3209998877', '2022-01-15', '2025-12-31', FALSE, 'Renunció por motivos personales'),
(19, '28887766', 'Patricia','Romero',   4, '3208887766', '2021-04-12', '2025-08-20', FALSE, 'Cambio de actividad laboral');

-- =============================================================================
-- 3. USUARIOS DEL SISTEMA
-- =============================================================================

INSERT INTO usuarios (username, password_hash, id_empleado, es_admin, ultimo_acceso) VALUES
('admin',      '$2a$10$REEMPLAZAR_CON_HASH_BCRYPT_REAL', 1,  TRUE,  '2026-05-08 06:30:45'),
('mgonzalez',  '$2a$10$REEMPLAZAR_CON_HASH_BCRYPT_REAL', 2,  FALSE, '2026-05-08 07:15:00'),
('crodriguez', '$2a$10$REEMPLAZAR_CON_HASH_BCRYPT_REAL', 3,  FALSE, '2026-05-07 09:20:11'),
('lvargas',    '$2a$10$REEMPLAZAR_CON_HASH_BCRYPT_REAL', 4,  FALSE, '2026-05-06 14:00:30'),
('pmartinez',  '$2a$10$REEMPLAZAR_CON_HASH_BCRYPT_REAL', 5,  FALSE, '2026-05-08 05:45:00'),
('afernandez', '$2a$10$REEMPLAZAR_CON_HASH_BCRYPT_REAL', 6,  FALSE, '2026-05-05 16:10:00'),
('rhernandez', '$2a$10$REEMPLAZAR_CON_HASH_BCRYPT_REAL', 7,  FALSE, '2026-05-08 06:00:00'),
('jperez',     '$2a$10$REEMPLAZAR_CON_HASH_BCRYPT_REAL', 8,  FALSE, '2026-05-08 05:25:00');

-- =============================================================================
-- 4. ANIMALES
-- =============================================================================
-- Distribución (80 animales totales):
--   Bovinos:  25 (Holstein 14, Aberdeen Angus 6, Hereford 5)
--   Ovinos:   18 (Merino 10, Corriedale 8)
--   Porcinos: 12 (Yorkshire 7, Duroc 5)
--   Equinos:   5 (Criollo)
--   Aves:     20 (Leghorn)
-- Recordatorio: id_raza 1=Holstein, 2=Aberdeen, 3=Hereford, 4=Merino,
--               5=Corriedale, 6=Yorkshire, 7=Duroc, 8=Criollo, 9=Leghorn
-- Recordatorio: ubicación 1=Corral 1, 2=Corral 2, 3=Potrero Norte,
--               4=Potrero Sur, 5=Establo A, 6=Galpón Aves
-- =============================================================================

-- ----- BOVINOS HOLSTEIN (lecheras, en Establo A) -----
INSERT INTO animales (id_animal, identificador_unico, id_raza, id_ubicacion, fecha_nacimiento, sexo, peso_kg, observaciones) VALUES
( 1, 'AR-0001', 1, 5, '2021-03-15', 'H', 580.50, 'Vaca de alta producción láctea'),
( 2, 'AR-0002', 1, 5, '2020-07-22', 'H', 620.00, 'Vaca lechera principal'),
( 3, 'AR-0003', 1, 5, '2022-01-10', 'H', 545.30, 'Tratamiento veterinario en curso'),
( 4, 'AR-0004', 1, 5, '2021-11-05', 'H', 590.00, NULL),
( 5, 'AR-0005', 1, 5, '2023-04-18', 'H', 510.20, NULL),
( 6, 'AR-0006', 1, 5, '2022-08-30', 'H', 555.00, NULL),
( 7, 'AR-0007', 1, 5, '2024-02-14', 'H', 380.00, 'Vaquilla joven'),
( 8, 'AR-0008', 1, 5, '2023-09-12', 'H', 475.00, NULL),
( 9, 'AR-0009', 1, 5, '2021-05-25', 'H', 605.50, NULL),
(10, 'AR-0010', 1, 5, '2022-12-03', 'H', 565.00, 'Recuperada de observación'),
(11, 'AR-0011', 1, 5, '2023-07-19', 'H', 495.00, NULL),
(12, 'AR-0012', 1, 5, '2024-05-08', 'H', 350.00, 'Vaquilla en crecimiento'),
(13, 'AR-0013', 1, 5, '2021-10-14', 'H', 615.00, 'Alta producción'),
(14, 'AR-0014', 1, 5, '2022-04-26', 'H', 575.00, NULL);

-- ----- BOVINOS ABERDEEN ANGUS (carne) -----
INSERT INTO animales (id_animal, identificador_unico, id_raza, id_ubicacion, fecha_nacimiento, sexo, peso_kg, estado, observaciones) VALUES
(15, 'AR-0015', 2, NULL, '2023-06-10', 'M', 480.00, 'VENDIDO',   'Vendido a frigorífico San Martín'),
(16, 'AR-0016', 2, NULL, '2023-08-15', 'M', 495.50, 'VENDIDO',   'Vendido a frigorífico San Martín'),
(17, 'AR-0017', 2,    3, '2024-04-20', 'M', 380.00, 'ACTIVO',    NULL),
(18, 'AR-0018', 2,    3, '2024-08-12', 'M', 340.00, 'ACTIVO',    'Novillo joven'),
(19, 'AR-0019', 2,    3, '2024-02-28', 'M', 410.00, 'ACTIVO',    NULL),
(20, 'AR-0020', 2, NULL, '2022-11-30', 'M', 510.00, 'VENDIDO',   'Vendido a frigorífico Pampa');

-- ----- BOVINOS HEREFORD (carne) -----
INSERT INTO animales (id_animal, identificador_unico, id_raza, id_ubicacion, fecha_nacimiento, sexo, peso_kg, estado, observaciones) VALUES
(21, 'AR-0021', 3,    4, '2024-01-08', 'M', 420.00, 'ACTIVO',    NULL),
(22, 'AR-0022', 3, NULL, '2022-03-22', 'H', 510.00, 'FALLECIDO', 'Fallecida por causas naturales'),
(23, 'AR-0023', 3,    4, '2023-12-15', 'M', 445.00, 'ACTIVO',    NULL),
(24, 'AR-0024', 3,    4, '2024-06-30', 'H', 365.00, 'ACTIVO',    NULL),
(25, 'AR-0025', 3,    4, '2023-09-04', 'M', 470.00, 'ACTIVO',    'Reproductor');

-- ----- OVINOS MERINO (Potrero Norte) -----
INSERT INTO animales (id_animal, identificador_unico, id_raza, id_ubicacion, fecha_nacimiento, sexo, peso_kg, observaciones) VALUES
(26, 'AR-0026', 4, 3, '2024-03-10', 'H',  55.00, NULL),
(27, 'AR-0027', 4, 3, '2023-11-25', 'H',  62.30, NULL),
(28, 'AR-0028', 4, 3, '2024-05-18', 'H',  48.50, NULL),
(29, 'AR-0029', 4, 3, '2023-09-30', 'M',  78.00, 'Carnero reproductor'),
(30, 'AR-0030', 4, 3, '2024-02-08', 'H',  52.40, 'Atención urgente requerida'),
(31, 'AR-0031', 4, 3, '2024-06-15', 'H',  46.00, NULL),
(32, 'AR-0032', 4, 3, '2023-12-22', 'H',  58.50, NULL),
(33, 'AR-0033', 4, 3, '2024-04-09', 'H',  51.00, NULL),
(34, 'AR-0034', 4, 3, '2024-08-20', 'M',  68.00, 'Carnero joven'),
(35, 'AR-0035', 4, 3, '2024-07-03', 'H',  47.50, NULL);

-- ----- OVINOS CORRIEDALE (Potrero Sur) -----
INSERT INTO animales (id_animal, identificador_unico, id_raza, id_ubicacion, fecha_nacimiento, sexo, peso_kg, estado, observaciones) VALUES
(36, 'AR-0036', 5, 4,    '2024-01-22', 'H', 60.50, 'ACTIVO',    NULL),
(37, 'AR-0037', 5, 4,    '2023-12-10', 'H', 58.00, 'ACTIVO',    NULL),
(38, 'AR-0038', 5, 4,    '2024-04-05', 'M', 72.00, 'ACTIVO',    'Carnero joven'),
(39, 'AR-0039', 5, 4,    '2024-07-12', 'H', 50.00, 'ACTIVO',    NULL),
(40, 'AR-0040', 5, 4,    '2023-10-18', 'H', 64.00, 'ACTIVO',    NULL),
(41, 'AR-0041', 5, 4,    '2024-03-25', 'H', 55.00, 'ACTIVO',    NULL),
(42, 'AR-0042', 5, NULL, '2022-08-15', 'H', 65.00, 'FALLECIDO', 'Fallecida por accidente en pastoreo'),
(43, 'AR-0043', 5, 4,    '2024-05-30', 'M', 70.00, 'ACTIVO',    NULL);

-- ----- PORCINOS YORKSHIRE (Corral 1) -----
INSERT INTO animales (id_animal, identificador_unico, id_raza, id_ubicacion, fecha_nacimiento, sexo, peso_kg, observaciones) VALUES
(44, 'AR-0044', 6, 1, '2025-01-15', 'H', 145.00, NULL),
(45, 'AR-0045', 6, 1, '2025-03-20', 'M', 168.00, NULL),
(46, 'AR-0046', 6, 1, '2025-02-08', 'H', 152.00, NULL),
(47, 'AR-0047', 6, 1, '2025-04-12', 'H', 138.00, NULL),
(48, 'AR-0048', 6, 1, '2025-05-05', 'H', 128.00, NULL),
(49, 'AR-0049', 6, 1, '2025-03-02', 'M', 175.00, 'Reproductor'),
(50, 'AR-0050', 6, 1, '2025-06-18', 'H', 115.00, 'Cerda joven');

-- ----- PORCINOS DUROC (Corral 2) -----
INSERT INTO animales (id_animal, identificador_unico, id_raza, id_ubicacion, fecha_nacimiento, sexo, peso_kg, estado, observaciones) VALUES
(51, 'AR-0051', 7,    2, '2025-02-25', 'M', 175.00, 'ACTIVO',    NULL),
(52, 'AR-0052', 7,    2, '2025-01-30', 'H', 160.00, 'ACTIVO',    NULL),
(53, 'AR-0053', 7, NULL, '2024-11-10', 'M', 180.00, 'FALLECIDO', 'Fallecido por enfermedad respiratoria'),
(54, 'AR-0054', 7,    2, '2025-04-22', 'H', 145.00, 'ACTIVO',    NULL),
(55, 'AR-0055', 7,    2, '2025-03-15', 'M', 170.00, 'ACTIVO',    'Engorde');

-- ----- EQUINOS CRIOLLO (Establo A) -----
INSERT INTO animales (id_animal, identificador_unico, id_raza, id_ubicacion, fecha_nacimiento, sexo, peso_kg, estado, observaciones) VALUES
(56, 'AR-0056', 8,    5, '2020-04-15', 'M', 420.00, 'ACTIVO',     'Caballo de trabajo'),
(57, 'AR-0057', 8,    5, '2019-08-20', 'H', 405.00, 'ACTIVO',     NULL),
(58, 'AR-0058', 8, NULL, '2021-06-30', 'M', 415.00, 'TRASLADADO', 'Trasladado a granja vecina'),
(59, 'AR-0059', 8,    5, '2022-09-14', 'H', 395.00, 'ACTIVO',     'Yegua de monta'),
(60, 'AR-0060', 8,    5, '2023-03-08', 'M', 380.00, 'ACTIVO',     NULL);

-- ----- AVES LEGHORN (Galpón Aves) -----
INSERT INTO animales (id_animal, identificador_unico, id_raza, id_ubicacion, fecha_nacimiento, sexo, peso_kg, observaciones) VALUES
(61, 'AR-0061', 9, 6, '2025-08-15', 'H', 1.85, 'Gallina ponedora'),
(62, 'AR-0062', 9, 6, '2025-08-15', 'H', 1.92, 'Gallina ponedora'),
(63, 'AR-0063', 9, 6, '2025-08-15', 'H', 1.78, 'Gallina ponedora'),
(64, 'AR-0064', 9, 6, '2025-08-15', 'H', 1.88, 'Gallina ponedora'),
(65, 'AR-0065', 9, 6, '2025-08-15', 'H', 1.95, 'Gallina ponedora'),
(66, 'AR-0066', 9, 6, '2025-08-15', 'H', 1.82, 'Gallina ponedora'),
(67, 'AR-0067', 9, 6, '2025-08-15', 'M', 2.85, 'Gallo reproductor'),
(68, 'AR-0068', 9, 6, '2025-09-20', 'H', 1.65, 'Gallina joven'),
(69, 'AR-0069', 9, 6, '2025-09-20', 'H', 1.68, 'Gallina joven'),
(70, 'AR-0070', 9, 6, '2025-09-20', 'H', 1.70, 'Gallina joven'),
(71, 'AR-0071', 9, 6, '2025-10-05', 'H', 1.55, 'Pollona en crecimiento'),
(72, 'AR-0072', 9, 6, '2025-10-05', 'H', 1.60, 'Pollona en crecimiento'),
(73, 'AR-0073', 9, 6, '2025-10-05', 'H', 1.58, 'Pollona en crecimiento'),
(74, 'AR-0074', 9, 6, '2025-08-15', 'H', 1.90, 'Gallina ponedora'),
(75, 'AR-0075', 9, 6, '2025-08-15', 'H', 1.86, 'Gallina ponedora'),
(76, 'AR-0076', 9, 6, '2025-08-15', 'H', 1.83, 'Gallina ponedora'),
(77, 'AR-0077', 9, 6, '2025-08-15', 'M', 2.90, 'Gallo reproductor secundario'),
(78, 'AR-0078', 9, 6, '2025-09-20', 'H', 1.72, 'Gallina joven'),
(79, 'AR-0079', 9, 6, '2025-10-05', 'H', 1.62, 'Pollona en crecimiento'),
(80, 'AR-0080', 9, 6, '2025-10-05', 'H', 1.59, 'Pollona en crecimiento');

-- =============================================================================
-- 5. EVENTOS DE ANIMALES
-- =============================================================================
-- Justifica los estados VENDIDO / FALLECIDO / TRASLADADO / INGRESO de los animales.
-- =============================================================================

INSERT INTO eventos_animal (id_animal, tipo_evento, fecha_evento, motivo, valor, contraparte, id_empleado) VALUES
(15, 'VENTA',         '2026-04-10', 'Venta para faena',                1850000.00, 'Frigorífico San Martín', 5),
(16, 'VENTA',         '2026-04-10', 'Venta para faena',                1920000.00, 'Frigorífico San Martín', 5),
(20, 'VENTA',         '2026-03-25', 'Venta para faena',                2050000.00, 'Frigorífico Pampa',      5),
(22, 'FALLECIMIENTO', '2026-03-22', 'Causas naturales (vejez)',              NULL, NULL,                     2),
(53, 'FALLECIMIENTO', '2026-04-28', 'Enfermedad respiratoria',               NULL, NULL,                     3),
(42, 'FALLECIMIENTO', '2026-02-14', 'Accidente en pastoreo (caída)',         NULL, NULL,                     4),
(58, 'TRASLADO',      '2026-04-15', 'Traslado por convenio',                 NULL, 'Granja La Esperanza',    5),
( 7, 'INGRESO',       '2024-02-14', 'Compra a criador certificado',     950000.00, 'Cabaña El Trébol',       5),
(34, 'INGRESO',       '2024-08-20', 'Compra de carnero reproductor',    320000.00, 'Cabaña Don Luis',        6),
(49, 'INGRESO',       '2025-03-02', 'Compra de reproductor',            450000.00, 'Granja San José',        7);

-- =============================================================================
-- 6. HISTORIAL DE SALUD
-- =============================================================================
-- ATENCIÓN: el orden de inserción importa. El trigger trg_actualiza_estado_salud
-- pisa animales.estado_salud con cada INSERT. Por eso van en orden cronológico.
--
-- Casos diseñados para alimentar al Notificador (severidad ALTA/URGENTE, NO atendidos):
--   - AR-0003 (id=3):  mastitis activa, ENFERMO+ALTA
--   - AR-0030 (id=30): cojera grave, CRITICO+URGENTE
--   - AR-0004 (id=4):  inflamación articular, ENFERMO+ALTA
--   - AR-0049 (id=49): herida infectada, ENFERMO+ALTA
--
-- Casos resueltos (NO disparan al Notificador):
--   - AR-0010, AR-0052, AR-0027, AR-0067 → terminan SANO
--   - AR-0053 (porcino) empeoró y luego falleció (ver eventos_animal)
-- =============================================================================

INSERT INTO historial_salud (id_animal, estado_salud, severidad, diagnostico, tratamiento, id_empleado, fecha_registro, atendido) VALUES
-- Chequeos de rutina (todos sanos)
( 1, 'SANO',        'BAJA',  'Chequeo de rutina mensual',           NULL,                                   2, '2026-04-05 09:00:00', TRUE),
( 2, 'SANO',        'BAJA',  'Chequeo de rutina mensual',           NULL,                                   2, '2026-04-05 09:15:00', TRUE),
( 6, 'SANO',        'BAJA',  'Chequeo de rutina',                   NULL,                                   2, '2026-04-05 09:30:00', TRUE),
( 9, 'SANO',        'BAJA',  'Chequeo previo a parto',              'Vigilancia diaria',                    2, '2026-04-05 10:00:00', TRUE),
(13, 'SANO',        'BAJA',  'Chequeo de rutina',                   NULL,                                   2, '2026-04-05 10:15:00', TRUE),
(29, 'SANO',        'BAJA',  'Inspección pre-monta',                NULL,                                   2, '2026-04-08 11:00:00', TRUE),
(34, 'SANO',        'BAJA',  'Inspección pre-monta',                NULL,                                   2, '2026-04-08 11:30:00', TRUE),
(56, 'SANO',        'BAJA',  'Chequeo dental',                      NULL,                                   3, '2026-04-09 14:00:00', TRUE),
(57, 'SANO',        'BAJA',  'Chequeo de cascos',                   'Limpieza y limado',                    3, '2026-04-09 14:30:00', TRUE),

-- Caso AR-0010: tuvo observación, ahora recuperada
(10, 'OBSERVACION', 'MEDIA', 'Baja producción láctea',              'Suplemento mineral por 7 días',        2, '2026-04-15 10:30:00', TRUE),
(10, 'SANO',        'BAJA',  'Recuperación tras tratamiento',       'Producción normalizada',               2, '2026-04-25 09:00:00', TRUE),

-- Caso AR-0027: ovino con problema dermatológico resuelto
(27, 'OBSERVACION', 'MEDIA', 'Lesiones cutáneas leves',             'Pomada cicatrizante por 10 días',      4, '2026-04-12 15:00:00', TRUE),
(27, 'SANO',        'BAJA',  'Recuperación completa',               NULL,                                   4, '2026-04-26 15:00:00', TRUE),

-- Caso AR-0053 (porcino que falleció): empeoró progresivamente
(53, 'OBSERVACION', 'MEDIA', 'Tos persistente',                     'Antibiótico de amplio espectro',       3, '2026-04-20 14:00:00', TRUE),
(53, 'ENFERMO',     'ALTA',  'Neumonía bacteriana',                 'Tratamiento intensivo',                3, '2026-04-25 16:00:00', TRUE),

-- Caso AR-0052: porcino con problema gastrointestinal resuelto
(52, 'OBSERVACION', 'MEDIA', 'Diarrea aguda',                       'Hidratación + dieta blanda 5 días',    3, '2026-04-22 11:30:00', TRUE),
(52, 'SANO',        'BAJA',  'Recuperación completa',               NULL,                                   3, '2026-04-30 10:00:00', TRUE),

-- Caso AR-0067: gallo con problema en patas, ya tratado
(67, 'OBSERVACION', 'MEDIA', 'Bumblefoot leve en pata derecha',     'Limpieza y vendaje por 1 semana',      4, '2026-04-18 10:00:00', TRUE),
(67, 'SANO',        'BAJA',  'Lesión cicatrizada',                  NULL,                                   4, '2026-04-30 10:30:00', TRUE),

-- Caso AR-0007: vaquilla joven con observación, sigue en seguimiento
( 7, 'OBSERVACION', 'MEDIA', 'Ganancia de peso por debajo del esperado', 'Ajuste de ración + control semanal', 2, '2026-04-28 09:00:00', FALSE),

-- *** CASOS QUE DISPARAN EL NOTIFICADOR (severidad ALTA/URGENTE, atendido=FALSE) ***

-- Caso AR-0003: mastitis activa (ALTA, NO atendido)
( 3, 'ENFERMO', 'ALTA', 'Mastitis subclínica en cuarto trasero izq.',
                        'Antibiótico intramamario + monitoreo diario',
                        2, '2026-05-03 08:30:00', FALSE),

-- Caso AR-0030: cojera grave (URGENTE, NO atendido)
(30, 'CRITICO', 'URGENTE', 'Cojera severa miembro posterior derecho, posible fractura',
                           'Requiere evaluación radiológica urgente',
                           2, '2026-05-07 17:45:00', FALSE),

-- Caso AR-0004: inflamación articular (ALTA, NO atendido)
( 4, 'ENFERMO', 'ALTA', 'Inflamación articular sospechosa',
                        'Pendiente análisis de líquido sinovial',
                        2, '2026-05-08 06:30:00', FALSE),

-- Caso AR-0049: porcino reproductor con herida infectada (ALTA, NO atendido)
(49, 'ENFERMO', 'ALTA', 'Herida en flanco derecho con signos de infección',
                        'Antibiótico inyectable + curación diaria',
                        3, '2026-05-08 07:15:00', FALSE);

-- =============================================================================
-- 7. ACTIVIDADES
-- =============================================================================
-- ~50 actividades a lo largo de aproximadamente un mes.
-- Recordatorio tipos: 1=Ordeñe, 2=Alimentación, 3=Vacunación, 4=Desparasitado,
--                     5=Limpieza, 6=Mantenimiento, 7=Esquila, 8=Pesaje
-- =============================================================================

INSERT INTO actividades (id_actividad, id_tipo_actividad, id_empleado, fecha, hora, descripcion) VALUES
-- Semana del 13 al 19 abr
( 1, 1,  8, '2026-04-13', '05:30:00', 'Ordeñe matutino - vacas Holstein'),
( 2, 1,  9, '2026-04-13', '17:00:00', 'Ordeñe vespertino'),
( 3, 5, 10, '2026-04-14', '08:00:00', 'Limpieza general de establos'),
( 4, 8,  3, '2026-04-15', '09:30:00', 'Pesaje quincenal de bovinos'),
( 5, 1,  8, '2026-04-15', '05:30:00', 'Ordeñe matutino'),
( 6, 2, 11, '2026-04-16', '07:00:00', 'Alimentación matutina ganado lechero'),
( 7, 1,  9, '2026-04-16', '17:00:00', 'Ordeñe vespertino'),
( 8, 6, 13, '2026-04-17', '10:00:00', 'Mantenimiento bebederos potreros'),
( 9, 1,  8, '2026-04-18', '05:30:00', 'Ordeñe matutino'),
(10, 4,  2, '2026-04-19', '09:00:00', 'Desparasitación interna bovinos'),

-- Semana del 20 al 26 abr
(11, 1,  8, '2026-04-20', '05:30:00', 'Ordeñe matutino'),
(12, 5, 12, '2026-04-21', '08:30:00', 'Limpieza galpón aves'),
(13, 3,  2, '2026-04-22', '10:00:00', 'Vacunación brucelosis - vaquillonas'),
(14, 1,  9, '2026-04-22', '17:00:00', 'Ordeñe vespertino'),
(15, 2, 14, '2026-04-23', '07:00:00', 'Alimentación porcinos'),
(16, 1,  8, '2026-04-24', '05:30:00', 'Ordeñe matutino'),
(17, 6, 10, '2026-04-25', '09:00:00', 'Reparación de portones'),
(18, 8,  3, '2026-04-26', '11:00:00', 'Pesaje de novillos para venta'),

-- Semana del 27 abr al 3 may
(19, 1,  8, '2026-04-27', '05:30:00', 'Ordeñe matutino - vacas Holstein'),
(20, 2,  8, '2026-04-27', '07:00:00', 'Alimentación matutina ganado lechero'),
(21, 1,  9, '2026-04-27', '17:00:00', 'Ordeñe vespertino - vacas Holstein'),
(22, 5, 10, '2026-04-28', '08:00:00', 'Limpieza general de establos'),
(23, 3,  2, '2026-04-28', '10:00:00', 'Vacunación antiaftosa - rebaño bovino'),
(24, 1,  8, '2026-04-29', '05:30:00', 'Ordeñe matutino'),
(25, 7, 11, '2026-04-30', '08:30:00', 'Esquila de ovinos Merino'),
(26, 7, 12, '2026-04-30', '13:00:00', 'Esquila de ovinos Corriedale'),
(27, 1,  8, '2026-04-30', '17:00:00', 'Ordeñe vespertino'),
(28, 6, 13, '2026-05-01', '09:00:00', 'Mantenimiento de cercas potrero norte'),
(29, 8,  3, '2026-05-01', '11:00:00', 'Pesaje mensual de novillos'),
(30, 4, 15, '2026-05-02', '08:30:00', 'Desparasitación equinos'),
(31, 1,  9, '2026-05-03', '05:30:00', 'Ordeñe matutino'),

-- Semana del 4 al 8 may
(32, 1,  9, '2026-05-04', '05:30:00', 'Ordeñe matutino'),
(33, 2, 11, '2026-05-04', '07:00:00', 'Alimentación porcinos'),
(34, 1,  8, '2026-05-04', '17:00:00', 'Ordeñe vespertino'),
(35, 4,  2, '2026-05-05', '09:30:00', 'Desparasitación interna ovinos'),
(36, 1,  9, '2026-05-05', '05:30:00', 'Ordeñe matutino'),
(37, 5, 12, '2026-05-05', '14:00:00', 'Limpieza galpón aves'),
(38, 1,  8, '2026-05-06', '05:30:00', 'Ordeñe matutino'),
(39, 2, 13, '2026-05-06', '07:30:00', 'Recolección y clasificación de huevos'),
(40, 6, 10, '2026-05-06', '15:00:00', 'Reparación bebederos automáticos'),
(41, 3,  4, '2026-05-06', '11:00:00', 'Vacunación New Castle - aves'),
(42, 1,  9, '2026-05-07', '05:30:00', 'Ordeñe matutino'),
(43, 8,  3, '2026-05-07', '10:00:00', 'Pesaje de cerdos para venta'),
(44, 1,  8, '2026-05-07', '17:00:00', 'Ordeñe vespertino'),
(45, 5, 16, '2026-05-07', '08:30:00', 'Limpieza corrales porcinos'),
(46, 1,  9, '2026-05-08', '05:30:00', 'Ordeñe matutino'),
(47, 2, 11, '2026-05-08', '07:00:00', 'Alimentación matutina general'),
(48, 2, 14, '2026-05-08', '07:30:00', 'Recolección de huevos'),
(49, 6, 17, '2026-05-08', '09:00:00', 'Mantenimiento sistema de riego'),
(50, 4,  2, '2026-05-08', '11:00:00', 'Aplicación de antiparasitario externo aves');

-- =============================================================================
-- 8. VÍNCULOS ACTIVIDAD ↔ ANIMAL
-- =============================================================================
-- Solo se vinculan actividades con tipos que requieren_animales=TRUE.
-- =============================================================================

-- Ordeñes (act 1, 2, 5, 7, 9, 11, 14, 16, 19, 21, 24, 27, 31, 32, 34, 36, 38, 42, 44, 46):
-- involucran las 14 vacas Holstein lecheras (id 1-14)
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), (1, 11), (1, 13), (1, 14),
(2, 1), (2, 2), (2, 4), (2, 5), (2, 6), (2, 8), (2, 9), (2, 10), (2, 11), (2, 13), (2, 14),
(5, 1), (5, 2), (5, 4), (5, 5), (5, 6), (5, 8), (5, 9), (5, 10), (5, 11), (5, 13), (5, 14),
(7, 1), (7, 2), (7, 4), (7, 5), (7, 6), (7, 8), (7, 9), (7, 10), (7, 11), (7, 13), (7, 14),
(9, 1), (9, 2), (9, 4), (9, 5), (9, 6), (9, 8), (9, 9), (9, 10), (9, 11), (9, 13), (9, 14),
(11, 1), (11, 2), (11, 4), (11, 5), (11, 6), (11, 8), (11, 9), (11, 10), (11, 11), (11, 13), (11, 14),
(14, 1), (14, 2), (14, 4), (14, 5), (14, 6), (14, 8), (14, 9), (14, 10), (14, 11), (14, 13), (14, 14),
(16, 1), (16, 2), (16, 4), (16, 5), (16, 6), (16, 8), (16, 9), (16, 10), (16, 11), (16, 13), (16, 14),
(19, 1), (19, 2), (19, 4), (19, 5), (19, 6), (19, 8), (19, 9), (19, 10), (19, 11), (19, 13), (19, 14),
(21, 1), (21, 2), (21, 4), (21, 5), (21, 6), (21, 8), (21, 9), (21, 10), (21, 11), (21, 13), (21, 14),
(24, 1), (24, 2), (24, 4), (24, 5), (24, 6), (24, 8), (24, 9), (24, 10), (24, 11), (24, 13), (24, 14),
(27, 1), (27, 2), (27, 4), (27, 5), (27, 6), (27, 8), (27, 9), (27, 10), (27, 11), (27, 13), (27, 14),
(31, 1), (31, 2), (31, 4), (31, 5), (31, 6), (31, 8), (31, 9), (31, 10), (31, 11), (31, 13), (31, 14),
(32, 1), (32, 2), (32, 4), (32, 5), (32, 6), (32, 8), (32, 9), (32, 10), (32, 11), (32, 13), (32, 14),
(34, 1), (34, 2), (34, 4), (34, 5), (34, 6), (34, 8), (34, 9), (34, 10), (34, 11), (34, 13), (34, 14),
(36, 1), (36, 2), (36, 4), (36, 5), (36, 6), (36, 8), (36, 9), (36, 10), (36, 11), (36, 13), (36, 14),
(38, 1), (38, 2), (38, 4), (38, 5), (38, 6), (38, 8), (38, 9), (38, 10), (38, 11), (38, 13), (38, 14),
(42, 1), (42, 2), (42, 4), (42, 5), (42, 6), (42, 8), (42, 9), (42, 10), (42, 11), (42, 13), (42, 14),
(44, 1), (44, 2), (44, 4), (44, 5), (44, 6), (44, 8), (44, 9), (44, 10), (44, 11), (44, 13), (44, 14),
(46, 1), (46, 2), (46, 4), (46, 5), (46, 6), (46, 8), (46, 9), (46, 10), (46, 11), (46, 13), (46, 14);

-- Alimentación matutina ganado lechero (act 6, 20, 47): incluye vacas en lactancia
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
( 6, 1), ( 6, 2), ( 6, 3), ( 6, 4), ( 6, 5), ( 6, 6), ( 6, 7), ( 6, 8), ( 6, 9), ( 6, 10), ( 6, 11), ( 6, 12), ( 6, 13), ( 6, 14),
(20, 1), (20, 2), (20, 3), (20, 4), (20, 5), (20, 6), (20, 7), (20, 8), (20, 9), (20, 10), (20, 11), (20, 12), (20, 13), (20, 14),
(47, 1), (47, 2), (47, 3), (47, 4), (47, 5), (47, 6), (47, 7), (47, 8), (47, 9), (47, 10), (47, 11), (47, 12), (47, 13), (47, 14);

-- Pesaje quincenal bovinos (act 4): bovinos seleccionados
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
( 4,  7), ( 4, 12), ( 4, 17), ( 4, 18), ( 4, 19), ( 4, 21), ( 4, 23), ( 4, 24), ( 4, 25);

-- Desparasitación bovinos (act 10)
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
(10, 1), (10, 2), (10, 3), (10, 4), (10, 5), (10, 6), (10, 7), (10, 8), (10, 9), (10, 10), (10, 11), (10, 12), (10, 13), (10, 14),
(10, 17), (10, 18), (10, 19), (10, 21), (10, 23), (10, 24), (10, 25);

-- Vacunación brucelosis vaquillonas (act 13): hembras jóvenes
INSERT INTO actividad_animal (id_actividad, id_animal, observacion) VALUES
(13,  7, 'Aplicada sin reacción'),
(13, 12, 'Aplicada sin reacción'),
(13, 24, 'Aplicada sin reacción');

-- Alimentación porcinos (act 15, 33)
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
(15, 44), (15, 45), (15, 46), (15, 47), (15, 48), (15, 49), (15, 50), (15, 51), (15, 52), (15, 54), (15, 55),
(33, 44), (33, 45), (33, 46), (33, 47), (33, 48), (33, 49), (33, 50), (33, 51), (33, 52), (33, 54), (33, 55);

-- Pesaje novillos para venta (act 18)
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
(18, 17), (18, 18), (18, 19), (18, 21), (18, 23), (18, 25);

-- Vacunación antiaftosa (act 23): todos los bovinos activos
INSERT INTO actividad_animal (id_actividad, id_animal, observacion) VALUES
(23,  1, 'Aplicada sin reacción'),
(23,  2, 'Aplicada sin reacción'),
(23,  4, 'Aplicada sin reacción'),
(23,  5, 'Aplicada sin reacción'),
(23,  6, 'Aplicada sin reacción'),
(23,  7, 'Aplicada sin reacción'),
(23,  8, 'Aplicada sin reacción'),
(23,  9, 'Aplicada sin reacción'),
(23, 10, 'Aplicada sin reacción'),
(23, 11, 'Aplicada sin reacción'),
(23, 12, 'Aplicada sin reacción'),
(23, 13, 'Aplicada sin reacción'),
(23, 14, 'Aplicada sin reacción'),
(23, 17, 'Aplicada sin reacción'),
(23, 18, 'Aplicada sin reacción'),
(23, 19, 'Aplicada sin reacción'),
(23, 21, 'Aplicada sin reacción'),
(23, 23, 'Aplicada sin reacción'),
(23, 24, 'Aplicada sin reacción'),
(23, 25, 'Aplicada sin reacción');

-- Esquila Merinos (act 25)
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
(25, 26), (25, 27), (25, 28), (25, 29), (25, 30), (25, 31), (25, 32), (25, 33), (25, 34), (25, 35);

-- Esquila Corriedales (act 26)
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
(26, 36), (26, 37), (26, 38), (26, 39), (26, 40), (26, 41), (26, 43);

-- Pesaje mensual novillos (act 29)
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
(29, 17), (29, 18), (29, 19), (29, 21), (29, 23), (29, 24), (29, 25);

-- Desparasitación equinos (act 30)
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
(30, 56), (30, 57), (30, 59), (30, 60);

-- Desparasitación ovinos (act 35)
INSERT INTO actividad_animal (id_actividad, id_animal, observacion) VALUES
(35, 26, NULL), (35, 27, NULL), (35, 28, NULL), (35, 29, NULL),
(35, 30, 'Aplicación con cuidado por su estado'),
(35, 31, NULL), (35, 32, NULL), (35, 33, NULL), (35, 34, NULL), (35, 35, NULL),
(35, 36, NULL), (35, 37, NULL), (35, 38, NULL), (35, 39, NULL),
(35, 40, NULL), (35, 41, NULL), (35, 43, NULL);

-- Recolección de huevos (act 39, 48): aves ponedoras
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
(39, 61), (39, 62), (39, 63), (39, 64), (39, 65), (39, 66), (39, 74), (39, 75), (39, 76),
(48, 61), (48, 62), (48, 63), (48, 64), (48, 65), (48, 66), (48, 74), (48, 75), (48, 76);

-- Vacunación New Castle aves (act 41)
INSERT INTO actividad_animal (id_actividad, id_animal, observacion) VALUES
(41, 61, 'Vía ocular'),
(41, 62, 'Vía ocular'),
(41, 63, 'Vía ocular'),
(41, 64, 'Vía ocular'),
(41, 65, 'Vía ocular'),
(41, 66, 'Vía ocular'),
(41, 67, 'Vía ocular'),
(41, 68, 'Vía ocular'),
(41, 69, 'Vía ocular'),
(41, 70, 'Vía ocular'),
(41, 71, 'Vía ocular'),
(41, 72, 'Vía ocular'),
(41, 73, 'Vía ocular'),
(41, 74, 'Vía ocular'),
(41, 75, 'Vía ocular'),
(41, 76, 'Vía ocular'),
(41, 77, 'Vía ocular'),
(41, 78, 'Vía ocular'),
(41, 79, 'Vía ocular'),
(41, 80, 'Vía ocular');

-- Pesaje cerdos para venta (act 43)
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
(43, 44), (43, 45), (43, 46), (43, 47), (43, 48), (43, 49), (43, 50), (43, 51), (43, 52), (43, 54), (43, 55);

-- Antiparasitario externo aves (act 50)
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
(50, 61), (50, 62), (50, 63), (50, 64), (50, 65), (50, 66), (50, 67),
(50, 68), (50, 69), (50, 70), (50, 71), (50, 72), (50, 73),
(50, 74), (50, 75), (50, 76), (50, 77), (50, 78), (50, 79), (50, 80);

-- =============================================================================
-- 9. LOGS DEL SISTEMA
-- =============================================================================
-- Muestra de eventos típicos: logins, altas, modificaciones, errores.
-- =============================================================================

INSERT INTO logs_sistema (fecha_hora, nivel, usuario, accion, entidad, id_entidad, mensaje, detalle_error) VALUES
('2026-04-20 08:00:23.123', 'INFO',     'admin',      'LOGIN',                  'usuarios',        '1',    'Inicio de sesión exitoso',                            NULL),
('2026-04-20 08:15:45.456', 'INFO',     'admin',      'ALTA_ANIMAL',            'animales',        '78',   'Se registró nuevo animal AR-0078',                    NULL),
('2026-04-21 09:30:12.789', 'INFO',     'mgonzalez',  'LOGIN',                  'usuarios',        '2',    'Inicio de sesión exitoso',                            NULL),
('2026-04-21 10:15:00.000', 'INFO',     'mgonzalez',  'ALTA_ACTIVIDAD',         'actividades',     '12',   'Registro de limpieza galpón aves',                    NULL),
('2026-04-22 14:23:11.789', 'WARN',     'pmartinez',  'INTENTO_LOGIN',          'usuarios',        NULL,   'Intento de login con contraseña incorrecta',          NULL),
('2026-04-23 09:00:00.000', 'INFO',     'crodriguez', 'LOGIN',                  'usuarios',        '3',    'Inicio de sesión exitoso',                            NULL),
('2026-04-25 16:45:32.111', 'INFO',     'crodriguez', 'ALTA_HISTORIAL_SALUD',   'historial_salud', '15',   'Registro de neumonía en AR-0053',                     NULL),
('2026-04-28 11:00:00.000', 'INFO',     'crodriguez', 'EVENTO_ANIMAL',          'eventos_animal',  '5',    'Animal AR-0053 marcado como FALLECIDO',               NULL),
('2026-04-29 13:30:00.000', 'ERROR',    'admin',      'ERROR_BD',               NULL,              NULL,   'Error temporal de conexión a la base de datos',       'java.sql.SQLException: Connection timeout after 30000ms'),
('2026-05-01 08:00:23.123', 'INFO',     'admin',      'LOGIN',                  'usuarios',        '1',    'Inicio de sesión exitoso',                            NULL),
('2026-05-01 08:15:45.456', 'INFO',     'admin',      'ALTA_ANIMAL',            'animales',        '80',   'Se registró nuevo animal AR-0080',                    NULL),
('2026-05-02 14:23:11.789', 'WARN',     'pmartinez',  'INTENTO_LOGIN',          'usuarios',        NULL,   'Intento de login con contraseña incorrecta',          NULL),
('2026-05-03 09:00:00.000', 'INFO',     'mgonzalez',  'LOGIN',                  'usuarios',        '2',    'Inicio de sesión exitoso',                            NULL),
('2026-05-03 10:45:32.111', 'INFO',     'mgonzalez',  'ALTA_HISTORIAL_SALUD',   'historial_salud', '20',   'Diagnóstico de mastitis registrado en AR-0003',       NULL),
('2026-05-04 16:30:00.000', 'ERROR',    'admin',      'ERROR_ARCHIVO',          NULL,              NULL,   'Error al escribir log diario',                        'java.io.IOException: Permission denied: /var/log/granja.log'),
('2026-05-05 07:50:12.234', 'INFO',     'pmartinez',  'LOGIN',                  'usuarios',        '5',    'Inicio de sesión exitoso',                            NULL),
('2026-05-05 08:30:15.567', 'INFO',     'pmartinez',  'ALTA_ACTIVIDAD',         'actividades',     '35',   'Registro de actividad de desparasitación',            NULL),
('2026-05-06 11:22:33.890', 'WARN',     'admin',      'RESPALDO_GENERADO',      NULL,              NULL,   'Respaldo diario generado: 80 animales, 50 actividades', NULL),
('2026-05-06 14:00:00.000', 'INFO',     'lvargas',    'LOGIN',                  'usuarios',        '4',    'Inicio de sesión exitoso',                            NULL),
('2026-05-06 15:30:45.000', 'INFO',     'lvargas',    'EDIT_ANIMAL',            'animales',        '7',    'Actualización de observaciones en AR-0007',           NULL),
('2026-05-07 13:45:00.000', 'INFO',     'admin',      'BAJA_EMPLEADO',          'empleados',       '18',   'Empleado dado de baja: Miguel Torres',                NULL),
('2026-05-07 18:00:55.000', 'CRITICAL', 'mgonzalez',  'ANIMAL_ESTADO_CRITICO',  'animales',        '30',   'Animal AR-0030 marcado como CRITICO',                 NULL),
('2026-05-08 06:30:45.123', 'INFO',     'mgonzalez',  'LOGIN',                  'usuarios',        '2',    'Inicio de sesión exitoso',                            NULL),
('2026-05-08 06:45:00.000', 'INFO',     'mgonzalez',  'ALTA_HISTORIAL_SALUD',   'historial_salud', '25',   'Diagnóstico de inflamación articular en AR-0004',     NULL),
('2026-05-08 07:20:00.000', 'INFO',     'crodriguez', 'ALTA_HISTORIAL_SALUD',   'historial_salud', '26',   'Diagnóstico de herida infectada en AR-0049',          NULL);

-- =============================================================================
-- VERIFICACIÓN POST-CARGA
-- =============================================================================
-- Después de ejecutar este script, las siguientes consultas deberían devolver:
--
--   SELECT COUNT(*) FROM empleados;                       --  19
--   SELECT COUNT(*) FROM usuarios;                        --   8
--   SELECT COUNT(*) FROM animales;                        --  80
--   SELECT COUNT(*) FROM animales WHERE estado='ACTIVO';  --  73
--   SELECT COUNT(*) FROM eventos_animal;                  --  10
--   SELECT COUNT(*) FROM historial_salud;                 --  25
--   SELECT COUNT(*) FROM actividades;                     --  50
--   SELECT COUNT(*) FROM actividad_animal;                -- ~280
--   SELECT COUNT(*) FROM logs_sistema;                    --  25
--   SELECT COUNT(*) FROM v_animales_atencion_urgente;     --   4 (Notificador)
-- =============================================================================

-- =============================================================================
-- FIN DEL SCRIPT 04
-- =============================================================================
