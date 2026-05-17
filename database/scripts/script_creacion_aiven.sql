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