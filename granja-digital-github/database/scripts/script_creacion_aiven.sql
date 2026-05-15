-- ===================================================================
--  GRANJA DIGITAL - Script para BD Aiven (esquema 'granja')
-- ===================================================================

USE granja;

-- Borrado defensivo de tablas previas
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS actividad_animal;
DROP TABLE IF EXISTS actividad;
DROP TABLE IF EXISTS animal;
DROP TABLE IF EXISTS empleado;
DROP TABLE IF EXISTS usuario;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE empleado (
    id                  INT             AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(80)     NOT NULL,
    rol                 VARCHAR(30)     NOT NULL,
    telefono            VARCHAR(20)     NULL,
    fecha_contratacion  DATE            NOT NULL
) ENGINE=InnoDB;

CREATE TABLE animal (
    id                  INT             AUTO_INCREMENT PRIMARY KEY,
    especie             VARCHAR(40)     NOT NULL,
    raza                VARCHAR(40)     NOT NULL,
    fecha_nacimiento    DATE            NOT NULL,
    identificador       VARCHAR(30)     NOT NULL UNIQUE,
    estado_salud        VARCHAR(20)     NOT NULL DEFAULT 'buena',
    ubicacion           VARCHAR(40)     NULL,
    estado              ENUM('ACTIVO','VENDIDO','FALLECIDO','TRASLADADO')
                                        NOT NULL DEFAULT 'ACTIVO'
) ENGINE=InnoDB;

CREATE INDEX idx_animal_especie ON animal(especie);
CREATE INDEX idx_animal_estado  ON animal(estado);

CREATE TABLE actividad (
    id              INT     AUTO_INCREMENT PRIMARY KEY,
    fecha           DATE    NOT NULL,
    hora            TIME    NOT NULL,
    tipo            ENUM('ORDENIE','ALIMENTACION','VACUNACION','LIMPIEZA','OTRA')
                            NOT NULL,
    descripcion     VARCHAR(255) NULL,
    id_empleado     INT     NULL,
    FOREIGN KEY (id_empleado) REFERENCES empleado(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX idx_actividad_fecha ON actividad(fecha);
CREATE INDEX idx_actividad_tipo  ON actividad(tipo);

CREATE TABLE actividad_animal (
    id_actividad    INT NOT NULL,
    id_animal       INT NOT NULL,
    PRIMARY KEY (id_actividad, id_animal),
    FOREIGN KEY (id_actividad) REFERENCES actividad(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_animal) REFERENCES animal(id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE usuario (
    id          INT             AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(40)     NOT NULL UNIQUE,
    clave_hash  VARCHAR(255)    NOT NULL,
    rol         ENUM('ADMIN','OPERADOR') NOT NULL DEFAULT 'OPERADOR',
    activo      BOOLEAN         NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE OR REPLACE VIEW vista_actividades AS
SELECT
    a.id, a.fecha, a.hora, a.tipo,
    a.descripcion, a.id_empleado,
    e.nombre AS empleado,
    GROUP_CONCAT(an.identificador ORDER BY an.identificador SEPARATOR ', ') AS animales
FROM actividad a
LEFT JOIN empleado        e  ON a.id_empleado   = e.id
LEFT JOIN actividad_animal aa ON aa.id_actividad = a.id
LEFT JOIN animal          an ON aa.id_animal     = an.id
GROUP BY a.id, a.fecha, a.hora, a.tipo, a.descripcion, a.id_empleado, e.nombre;

-- Datos de ejemplo
INSERT INTO empleado (nombre, rol, telefono, fecha_contratacion) VALUES
 ('Maria Lopez',       'veterinario', '666111222', '2022-04-15'),
 ('Juan Perez',        'peon',        '655234567', '2023-09-01'),
 ('Lucia Fernandez',   'encargado',   '644555888', '2021-01-10'),
 ('Carlos Romero',     'peon',        '633998877', '2024-02-20');

INSERT INTO animal (especie, raza, fecha_nacimiento, identificador,
                    estado_salud, ubicacion, estado) VALUES
 ('vaca',     'Holstein',          '2022-05-12', 'ARETE-001', 'buena',   'Corral 1',     'ACTIVO'),
 ('vaca',     'Pirenaica',         '2021-11-23', 'ARETE-002', 'buena',   'Corral 1',     'ACTIVO'),
 ('vaca',     'Holstein',          '2023-04-05', 'ARETE-003', 'regular', 'Corral 2',     'ACTIVO'),
 ('oveja',    'Merina',            '2023-02-14', 'ARETE-101', 'buena',   'Potrero Norte','ACTIVO'),
 ('oveja',    'Latxa',             '2022-07-30', 'ARETE-102', 'grave',   'Enfermeria',   'ACTIVO'),
 ('cerdo',    'Duroc',             '2024-01-09', 'CHIP-201',  'buena',   'Corral 3',     'ACTIVO'),
 ('gallina',  'Castellana negra',  '2024-03-18', 'ANILLA-301','buena',   'Gallinero',    'ACTIVO');

INSERT INTO actividad (fecha, hora, tipo, descripcion, id_empleado) VALUES
 ('2026-05-10', '06:30', 'ORDENIE',      'Ordenie matutino del corral 1',  2),
 ('2026-05-10', '08:00', 'ALIMENTACION', 'Pienso a corrales 1 y 2',         2),
 ('2026-05-10', '10:15', 'VACUNACION',   'Refuerzo antiparasitario',        1),
 ('2026-05-10', '17:30', 'LIMPIEZA',     'Limpieza del gallinero',          4),
 ('2026-05-11', '06:30', 'ORDENIE',      'Ordenie matutino del corral 1',   2);

INSERT INTO actividad_animal VALUES (1, 1), (1, 2);
INSERT INTO actividad_animal VALUES (2, 1), (2, 2), (2, 3);
INSERT INTO actividad_animal VALUES (3, 5);
INSERT INTO actividad_animal VALUES (4, 7);
INSERT INTO actividad_animal VALUES (5, 1), (5, 2);

INSERT INTO usuario (nombre, clave_hash, rol) VALUES
 ('admin', 'pendiente_de_hash', 'ADMIN');
