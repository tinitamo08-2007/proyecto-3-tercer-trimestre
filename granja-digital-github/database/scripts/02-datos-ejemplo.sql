-- ============================================================
--  GRANJA DIGITAL — Datos de ejemplo
--  Ejecutar DESPUÉS de 01-schema.sql.
--
--  Incluye datos ricos (7 animales, 4 empleados, 5 actividades)
--  coherentes con los valores demo que usa server.js para que
--  la web muestre contenido real al conectar.
-- ============================================================

USE granja;

-- ============================================================
-- Empleados
-- ============================================================
INSERT INTO empleado (nombre, rol, telefono, fecha_contratacion) VALUES
    ('Maria Lopez',     'veterinario', '666111222', '2022-04-15'),
    ('Juan Perez',      'peon',        '655234567', '2023-09-01'),
    ('Lucia Fernandez', 'encargado',   '644555888', '2021-01-10'),
    ('Carlos Romero',   'peon',        '633998877', '2024-02-20');

-- ============================================================
-- Animales
-- estado_salud: 'buena' | 'regular' | 'grave' | 'critica'
-- estado:       'ACTIVO'| 'VENDIDO' | 'FALLECIDO'| 'TRASLADADO'
-- ============================================================
INSERT INTO animal (especie, raza, fecha_nacimiento, identificador,
                    estado_salud, ubicacion, estado) VALUES
    ('vaca',    'Holstein',         '2022-05-12', 'ARETE-001', 'buena',   'Corral 1',      'ACTIVO'),
    ('vaca',    'Pirenaica',        '2021-11-23', 'ARETE-002', 'buena',   'Corral 1',      'ACTIVO'),
    ('vaca',    'Holstein',         '2023-04-05', 'ARETE-003', 'regular', 'Corral 2',      'ACTIVO'),
    ('oveja',   'Merina',           '2023-02-14', 'ARETE-101', 'buena',   'Potrero Norte', 'ACTIVO'),
    ('oveja',   'Latxa',            '2022-07-30', 'ARETE-102', 'grave',   'Enfermeria',    'ACTIVO'),
    ('cerdo',   'Duroc',            '2024-01-09', 'CHIP-201',  'buena',   'Corral 3',      'ACTIVO'),
    ('gallina', 'Castellana negra', '2024-03-18', 'ANILLA-301','buena',   'Gallinero',     'ACTIVO');

-- ============================================================
-- Actividades
-- tipo: 'ORDENIE'|'ALIMENTACION'|'VACUNACION'|'LIMPIEZA'|'OTRA'
-- ============================================================
INSERT INTO actividad (fecha, hora, tipo, descripcion, id_empleado) VALUES
    ('2026-05-10', '06:30:00', 'ORDENIE',      'Ordenie matutino del corral 1',  2),
    ('2026-05-10', '08:00:00', 'ALIMENTACION', 'Pienso a corrales 1 y 2',        2),
    ('2026-05-10', '10:15:00', 'VACUNACION',   'Refuerzo antiparasitario',       1),
    ('2026-05-10', '17:30:00', 'LIMPIEZA',     'Limpieza del gallinero',         4),
    ('2026-05-11', '06:30:00', 'ORDENIE',      'Ordenie matutino del corral 1',  2);

-- ============================================================
-- Relación actividad ↔ animal
-- ============================================================
-- Ordeñe del 10 → vacas ARETE-001 y ARETE-002
INSERT INTO actividad_animal VALUES (1, 1), (1, 2);
-- Alimentación del 10 → vacas ARETE-001, ARETE-002, ARETE-003
INSERT INTO actividad_animal VALUES (2, 1), (2, 2), (2, 3);
-- Vacunación → oveja ARETE-102 (la que está grave)
INSERT INTO actividad_animal VALUES (3, 5);
-- Limpieza del gallinero → gallina ANILLA-301
INSERT INTO actividad_animal VALUES (4, 7);
-- Ordeñe del 11 → vacas ARETE-001 y ARETE-002
INSERT INTO actividad_animal VALUES (5, 1), (5, 2);

-- ============================================================
-- Usuario admin (extra de autenticación)
-- Sustituir 'pendiente_de_hash' por el hash bcrypt real.
-- ============================================================
INSERT INTO usuario (nombre, clave_hash, rol) VALUES
    ('admin', 'pendiente_de_hash', 'ADMIN');

-- ============================================================
-- Comprobación rápida
-- ============================================================
SELECT 'empleado'  AS tabla, COUNT(*) AS filas FROM empleado
UNION ALL
SELECT 'animal',             COUNT(*)           FROM animal
UNION ALL
SELECT 'actividad',          COUNT(*)           FROM actividad
UNION ALL
SELECT 'actividad_animal',   COUNT(*)           FROM actividad_animal;

SELECT * FROM vista_actividades;
