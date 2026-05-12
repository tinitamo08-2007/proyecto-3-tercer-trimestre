-- Datos de ejemplo para la base "granja". Reproducen los datos DEMO de
-- granja-web/server.js, así la web muestra contenido real al conectar.
-- Requiere ejecutar antes schema.sql.

USE granja;


-- Empleados
INSERT INTO empleados (nombre, rol, telefono, fecha_contratacion) VALUES
    ('Carlos Martinez', 'Veterinario', '612345678', '2022-03-15'),
    ('Ana Lopez',       'Encargada',   '623456789', '2021-09-01'),
    ('Pedro Sanchez',   'Peon',        '634567890', '2023-01-20');


-- Animales
INSERT INTO animales (especie, raza, fecha_nacimiento, identificador, estado_salud, ubicacion, estado) VALUES
    ('Bovino',  'Holstein', '2020-04-12', 'A-001', 'Sano',           'Corral 1',  'ACTIVO'),
    ('Porcino', 'Duroc',    '2022-07-03', 'A-002', 'Sano',           'Potrero 2', 'ACTIVO'),
    ('Ovino',   'Merino',   '2021-11-25', 'A-003', 'En tratamiento', 'Corral 3',  'ACTIVO');


-- Actividades
INSERT INTO actividades (fecha, hora, tipo_actividad, descripcion, id_empleado) VALUES
    ('2024-05-01', '08:00:00', 'Ordeno',       'Ordeno matinal en sala 1',  2),  -- Ana López
    ('2024-05-01', '09:30:00', 'Vacunacion',   'Refuerzo trimestral',       1),  -- Carlos Martínez
    ('2024-05-02', '07:00:00', 'Alimentacion', 'Reparto de pienso general', 3);  -- Pedro Sánchez


-- Animales involucrados en cada actividad
INSERT INTO actividad_animal (id_actividad, id_animal) VALUES
    (1, 1),                  -- Ordeño → vaca Holstein A-001
    (2, 2), (2, 3),          -- Vacunación → cerdo y oveja
    (3, 1), (3, 2), (3, 3);  -- Alimentación → todos
