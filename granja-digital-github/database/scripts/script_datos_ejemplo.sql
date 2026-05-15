-- ===================================================================
--  GRANJA DIGITAL - Datos de ejemplo
--  Ejecuta primero script_creacion.sql.
-- ===================================================================

USE granja;

-- =========================
-- Empleados
-- =========================
INSERT INTO empleado (nombre, rol, telefono, fecha_contratacion) VALUES
 ('María López',       'veterinario', '666111222', '2022-04-15'),
 ('Juan Pérez',        'peon',        '655234567', '2023-09-01'),
 ('Lucía Fernández',   'encargado',   '644555888', '2021-01-10'),
 ('Carlos Romero',     'peon',        '633998877', '2024-02-20'),
 ('Sofia Ruiz', 'veterinario', '611222333', '2023-06-01');

-- =========================
-- Animales
-- =========================
INSERT INTO animal (especie, raza, fecha_nacimiento, identificador,
                    estado_salud, ubicacion, estado) VALUES
 ('vaca',     'Holstein',          '2022-05-12', 'ARETE-001', 'buena',   'Corral 1',     'ACTIVO'),
 ('vaca',     'Pirenaica',         '2021-11-23', 'ARETE-002', 'buena',   'Corral 1',     'ACTIVO'),
 ('vaca',     'Holstein',          '2023-04-05', 'ARETE-003', 'regular', 'Corral 2',     'ACTIVO'),
 ('oveja',    'Merina',            '2023-02-14', 'ARETE-101', 'buena',   'Potrero Norte','ACTIVO'),
 ('oveja',    'Latxa',             '2022-07-30', 'ARETE-102', 'grave',   'Enfermería',   'ACTIVO'),
 ('cerdo',    'Duroc',             '2024-01-09', 'CHIP-201',  'buena',   'Corral 3',     'ACTIVO'),
 ('gallina',  'Castellana negra',  '2024-03-18', 'ANILLA-301','buena',   'Gallinero',    'ACTIVO'),
 ('caballo', 'Pura Sangre', '2020-08-10', 'CHIP-501', 'buena',   'Establo 1', 'ACTIVO'),
 ('cabra',   'Murciana',    '2023-05-22', 'ARETE-201', 'buena',  'Potrero Norte', 'ACTIVO');

-- =========================
-- Actividades
-- =========================
INSERT INTO actividad (fecha, hora, tipo, descripcion, id_empleado) VALUES
 ('2026-05-10', '06:30', 'ORDENIE',      'Ordeñe matutino del corral 1',   2),
 ('2026-05-10', '08:00', 'ALIMENTACION', 'Pienso a corrales 1 y 2',        2),
 ('2026-05-10', '10:15', 'VACUNACION',   'Refuerzo antiparasitario',       1),
 ('2026-05-10', '17:30', 'LIMPIEZA',     'Limpieza del gallinero',         4),
 ('2026-05-11', '06:30', 'ORDENIE',      'Ordeñe matutino del corral 1',   2),
 ('2026-05-12', '07:00', 'ALIMENTACION', 'Pienso matutino general', 2),
 ('2026-05-12', '11:00', 'LIMPIEZA',     'Limpieza corrales 1 y 2', 3);

-- =========================
-- Relación actividad - animal
-- =========================
-- Ordeñe matutino del 10 -> vacas 1, 2
INSERT INTO actividad_animal VALUES (1, 1), (1, 2);
-- Alimentación del 10 -> vacas 1, 2, 3
INSERT INTO actividad_animal VALUES (2, 1), (2, 2), (2, 3);
-- Vacunación -> oveja "grave" (5)
INSERT INTO actividad_animal VALUES (3, 5);
-- Limpieza del gallinero -> gallina (7) (afectado por el entorno)
INSERT INTO actividad_animal VALUES (4, 7);
-- Ordeñe del 11 -> vacas 1, 2
INSERT INTO actividad_animal VALUES (5, 1), (5, 2);

INSERT INTO actividad_animal VALUES (6, 1), (6, 2), (6, 3);

INSERT INTO actividad_animal VALUES (7, 1), (7, 2);

-- (Opcional) Usuario admin para el extra de autenticación.
-- La columna clave_hash debería ir cifrada; aquí dejamos un placeholder
-- para el ejercicio.
INSERT INTO usuario (nombre, clave_hash, rol) VALUES
 ('admin', 'pendiente_de_hash', 'ADMIN');
