-- ============================================================
--  GRANJA DIGITAL — Schema unificado
--  Proyecto 3º DAM · Tercer trimestre
--  SGBD: MySQL 8.x
--
--  Decisiones de diseño:
--   · Nombre de BD: "granja"  (coincide con Aiven y con server.js)
--   · Nombres de tabla: singular (animal, empleado, actividad)
--     → Los DAOs de Java ya están escritos con estos nombres.
--     → El server.js se actualiza para coincidir (ver README).
--   · actividad.tipo: ENUM controlado → sincronizado con la
--     clase Java TipoActividad.
--   · animal.estado_salud: VARCHAR ('buena','regular','grave','critica')
--     → sincronizado con el modelo Java Animal.
--   · id_empleado en actividad es nullable con ON DELETE SET NULL
--     → si se borra un empleado, sus actividades no se pierden.
--   · Vista vista_actividades → el servidor web la usa para
--     mostrar empleado y lista de animales con un solo SELECT.
-- ============================================================

DROP DATABASE IF EXISTS granja;

CREATE DATABASE granja
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE granja;

-- ============================================================
-- TABLA: empleado
-- Personal de la granja: veterinarios, peones, encargados...
-- ============================================================
CREATE TABLE empleado (
    id                  INT             AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(80)     NOT NULL,
    rol                 VARCHAR(30)     NOT NULL,
    telefono            VARCHAR(20)     NULL,
    fecha_contratacion  DATE            NOT NULL,
    CONSTRAINT chk_empleado_rol
        CHECK (rol IN ('veterinario', 'peon', 'encargado', 'administrativo', 'otro'))
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: animal
-- Cada animal registrado en la granja.
-- El campo "estado" reproduce el enum EstadoAnimal de Java.
-- El campo "estado_salud" usa los mismos valores que el modelo Java.
-- ============================================================
CREATE TABLE animal (
    id                  INT             AUTO_INCREMENT PRIMARY KEY,
    especie             VARCHAR(40)     NOT NULL,
    raza                VARCHAR(40)     NOT NULL,
    fecha_nacimiento    DATE            NOT NULL,
    identificador       VARCHAR(30)     NOT NULL UNIQUE,
    estado_salud        VARCHAR(20)     NOT NULL DEFAULT 'buena',
    ubicacion           VARCHAR(40)     NULL,
    estado              ENUM('ACTIVO','VENDIDO','FALLECIDO','TRASLADADO')
                                        NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT chk_animal_salud
        CHECK (estado_salud IN ('buena', 'regular', 'grave', 'critica'))
) ENGINE=InnoDB;

-- Índices para acelerar filtros frecuentes
CREATE INDEX idx_animal_especie ON animal(especie);
CREATE INDEX idx_animal_estado  ON animal(estado);

-- ============================================================
-- TABLA: actividad
-- Tareas diarias: ordeños, vacunaciones, alimentación, limpieza...
-- "tipo" es ENUM → sincronizado con la clase Java TipoActividad.
-- id_empleado nullable: si se borra el empleado, la actividad
-- queda registrada pero sin responsable (ON DELETE SET NULL).
-- ============================================================
CREATE TABLE actividad (
    id              INT     AUTO_INCREMENT PRIMARY KEY,
    fecha           DATE    NOT NULL,
    hora            TIME    NOT NULL,
    tipo            ENUM('ORDENIE','ALIMENTACION','VACUNACION','LIMPIEZA','OTRA')
                            NOT NULL,
    descripcion     VARCHAR(255) NULL,
    id_empleado     INT     NULL,
    CONSTRAINT fk_actividad_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleado(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- Índices para filtros por fecha y tipo (los más habituales en la app)
CREATE INDEX idx_actividad_fecha ON actividad(fecha);
CREATE INDEX idx_actividad_tipo  ON actividad(tipo);

-- ============================================================
-- TABLA: actividad_animal  (relación N:M)
-- Una actividad puede involucrar a varios animales y
-- un animal puede aparecer en varias actividades.
-- ============================================================
CREATE TABLE actividad_animal (
    id_actividad    INT NOT NULL,
    id_animal       INT NOT NULL,
    PRIMARY KEY (id_actividad, id_animal),
    CONSTRAINT fk_aa_actividad
        FOREIGN KEY (id_actividad) REFERENCES actividad(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_aa_animal
        FOREIGN KEY (id_animal) REFERENCES animal(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: usuario  (extra: autenticación de administradores)
-- No es obligatoria en el enunciado; se deja preparada para
-- el extra de "autenticación básica".
-- ============================================================
CREATE TABLE usuario (
    id          INT             AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(40)     NOT NULL UNIQUE,
    clave_hash  VARCHAR(255)    NOT NULL,
    rol         ENUM('ADMIN','OPERADOR') NOT NULL DEFAULT 'OPERADOR',
    activo      BOOLEAN         NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- ============================================================
-- VISTA: vista_actividades
-- Une actividad + empleado + lista de animales.
-- La usa server.js (granja-web) para mostrar la información
-- completa de cada actividad con un único SELECT *.
-- Columnas que expone al servidor web:
--   · id, fecha, hora, tipo, descripcion, id_empleado
--   · empleado      → nombre del responsable
--   · animales      → identificadores separados por coma
-- ============================================================
CREATE OR REPLACE VIEW vista_actividades AS
SELECT
    a.id,
    a.fecha,
    a.hora,
    a.tipo,
    a.descripcion,
    a.id_empleado,
    e.nombre  AS empleado,
    GROUP_CONCAT(
        an.identificador
        ORDER BY an.identificador
        SEPARATOR ', '
    )         AS animales
FROM actividad          a
LEFT JOIN empleado        e  ON a.id_empleado   = e.id
LEFT JOIN actividad_animal aa ON aa.id_actividad = a.id
LEFT JOIN animal          an ON aa.id_animal     = an.id
GROUP BY
    a.id, a.fecha, a.hora, a.tipo,
    a.descripcion, a.id_empleado, e.nombre;

-- ============================================================
-- Comprobación rápida (se puede comentar antes de entregar)
-- ============================================================
SHOW TABLES;
