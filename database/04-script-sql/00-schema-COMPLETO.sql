-- =============================================================================
-- SISTEMA DE GESTIÓN DE GRANJA - SCRIPT DE CREACIÓN DE BASE DE DATOS
-- Motor: MySQL 8.0+
-- Codificación: UTF-8
-- =============================================================================

DROP DATABASE IF EXISTS granja_db;
CREATE DATABASE granja_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE granja_db;

-- =============================================================================
-- 1. CATÁLOGOS (tablas de referencia, pocos registros, cambian poco)
-- =============================================================================

-- Roles de los empleados (veterinario, peón, encargado, admin, etc.)
CREATE TABLE roles (
    id_rol          INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(50) NOT NULL UNIQUE,
    descripcion     VARCHAR(200),
    fecha_creacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Especies (Bovino, Ovino, Porcino, Equino, Aves, etc.)
CREATE TABLE especies (
    id_especie      INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(50) NOT NULL UNIQUE,
    nombre_cientifico VARCHAR(100),
    descripcion     VARCHAR(200)
) ENGINE=InnoDB;

-- Razas (asociadas a una especie: Holstein -> Bovino, Merino -> Ovino, etc.)
CREATE TABLE razas (
    id_raza         INT AUTO_INCREMENT PRIMARY KEY,
    id_especie      INT NOT NULL,
    nombre          VARCHAR(80) NOT NULL,
    descripcion     VARCHAR(200),
    UNIQUE KEY uk_raza_especie (id_especie, nombre),
    CONSTRAINT fk_raza_especie
        FOREIGN KEY (id_especie) REFERENCES especies(id_especie)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Ubicaciones físicas (corrales, potreros, establos)
CREATE TABLE ubicaciones (
    id_ubicacion    INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(80) NOT NULL UNIQUE,
    tipo            ENUM('CORRAL','POTRERO','ESTABLO','GALPON','OTRO') NOT NULL,
    capacidad_max   INT,
    descripcion     VARCHAR(200),
    activa          BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- Tipos de actividad (ordeñe, alimentación, vacunación, limpieza, etc.)
CREATE TABLE tipos_actividad (
    id_tipo_actividad INT AUTO_INCREMENT PRIMARY KEY,
    nombre            VARCHAR(60) NOT NULL UNIQUE,
    requiere_animales BOOLEAN NOT NULL DEFAULT FALSE,
    descripcion       VARCHAR(200)
) ENGINE=InnoDB;

-- =============================================================================
-- 2. EMPLEADOS Y USUARIOS
-- =============================================================================

CREATE TABLE empleados (
    id_empleado        INT AUTO_INCREMENT PRIMARY KEY,
    documento          VARCHAR(30) UNIQUE,
    nombre             VARCHAR(80) NOT NULL,
    apellido           VARCHAR(80) NOT NULL,
    id_rol             INT NOT NULL,
    telefono           VARCHAR(30),
    email              VARCHAR(120),
    fecha_contratacion DATE NOT NULL,
    fecha_baja         DATE NULL,
    activo             BOOLEAN NOT NULL DEFAULT TRUE,
    observaciones      VARCHAR(255),
    CONSTRAINT fk_empleado_rol
        FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_fechas_empleado
        CHECK (fecha_baja IS NULL OR fecha_baja >= fecha_contratacion)
) ENGINE=InnoDB;

CREATE INDEX idx_empleado_activo ON empleados(activo);
CREATE INDEX idx_empleado_rol    ON empleados(id_rol);

-- Usuarios para autenticación (no todo empleado tiene login)
CREATE TABLE usuarios (
    id_usuario      INT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(50) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,    -- usar BCrypt en Java
    id_empleado     INT NULL UNIQUE,
    es_admin        BOOLEAN NOT NULL DEFAULT FALSE,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso   DATETIME NULL,
    intentos_fallidos TINYINT NOT NULL DEFAULT 0,
    CONSTRAINT fk_usuario_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =============================================================================
-- 3. ANIMALES Y SU TRAZABILIDAD
-- =============================================================================

CREATE TABLE animales (
    id_animal           INT AUTO_INCREMENT PRIMARY KEY,
    identificador_unico VARCHAR(30) NOT NULL UNIQUE,   -- arete / chip / caravana
    id_raza             INT NOT NULL,
    id_ubicacion        INT NULL,
    fecha_nacimiento    DATE NOT NULL,
    sexo                ENUM('M','H') NOT NULL,
    peso_kg             DECIMAL(7,2),
    estado_salud        ENUM('SANO','OBSERVACION','ENFERMO','CRITICO')
                        NOT NULL DEFAULT 'SANO',
    estado              ENUM('ACTIVO','VENDIDO','FALLECIDO','TRASLADADO')
                        NOT NULL DEFAULT 'ACTIVO',
    fecha_registro      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observaciones       VARCHAR(255),
    CONSTRAINT fk_animal_raza
        FOREIGN KEY (id_raza) REFERENCES razas(id_raza)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_animal_ubicacion
        FOREIGN KEY (id_ubicacion) REFERENCES ubicaciones(id_ubicacion)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_fecha_nac
        CHECK (fecha_nacimiento <= CURRENT_DATE)
) ENGINE=InnoDB;

CREATE INDEX idx_animal_estado       ON animales(estado);
CREATE INDEX idx_animal_estado_salud ON animales(estado_salud);
CREATE INDEX idx_animal_raza         ON animales(id_raza);
CREATE INDEX idx_animal_ubicacion    ON animales(id_ubicacion);

-- Eventos del ciclo de vida del animal: ventas, fallecimientos, traslados
CREATE TABLE eventos_animal (
    id_evento       INT AUTO_INCREMENT PRIMARY KEY,
    id_animal       INT NOT NULL,
    tipo_evento     ENUM('VENTA','FALLECIMIENTO','TRASLADO','INGRESO') NOT NULL,
    fecha_evento    DATE NOT NULL,
    motivo          VARCHAR(200),
    valor           DECIMAL(12,2),                -- precio en venta
    contraparte     VARCHAR(120),                 -- comprador / destino
    id_empleado     INT NULL,                     -- responsable del registro
    fecha_registro  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_evento_animal
        FOREIGN KEY (id_animal) REFERENCES animales(id_animal)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_evento_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_evento_animal ON eventos_animal(id_animal);
CREATE INDEX idx_evento_fecha  ON eventos_animal(fecha_evento);

-- Historial de estado de salud (alimenta al Notificador)
CREATE TABLE historial_salud (
    id_historial    INT AUTO_INCREMENT PRIMARY KEY,
    id_animal       INT NOT NULL,
    estado_salud    ENUM('SANO','OBSERVACION','ENFERMO','CRITICO') NOT NULL,
    severidad       ENUM('BAJA','MEDIA','ALTA','URGENTE') NOT NULL DEFAULT 'BAJA',
    diagnostico     VARCHAR(255),
    tratamiento     VARCHAR(255),
    id_empleado     INT NULL,                     -- veterinario / responsable
    fecha_registro  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atendido        BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_salud_animal
        FOREIGN KEY (id_animal) REFERENCES animales(id_animal)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_salud_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_salud_animal_fecha ON historial_salud(id_animal, fecha_registro);
CREATE INDEX idx_salud_severidad    ON historial_salud(severidad, atendido);

-- =============================================================================
-- 4. ACTIVIDADES RURALES
-- =============================================================================

CREATE TABLE actividades (
    id_actividad      INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_actividad INT NOT NULL,
    id_empleado       INT NOT NULL,
    fecha             DATE NOT NULL,
    hora              TIME NOT NULL,
    descripcion       VARCHAR(255),
    fecha_registro    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_actividad_tipo
        FOREIGN KEY (id_tipo_actividad) REFERENCES tipos_actividad(id_tipo_actividad)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_actividad_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_actividad_fecha    ON actividades(fecha);
CREATE INDEX idx_actividad_empleado ON actividades(id_empleado);
CREATE INDEX idx_actividad_tipo     ON actividades(id_tipo_actividad);

-- Tabla puente N:M entre actividades y animales
-- (una vacunación puede involucrar muchos animales; un animal participa en muchas actividades)
CREATE TABLE actividad_animal (
    id_actividad    INT NOT NULL,
    id_animal       INT NOT NULL,
    observacion     VARCHAR(200),
    PRIMARY KEY (id_actividad, id_animal),
    CONSTRAINT fk_aa_actividad
        FOREIGN KEY (id_actividad) REFERENCES actividades(id_actividad)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_aa_animal
        FOREIGN KEY (id_animal) REFERENCES animales(id_animal)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =============================================================================
-- 5. LOGS DEL SISTEMA (espejo en BD de los archivos .txt)
-- =============================================================================

CREATE TABLE logs_sistema (
    id_log          BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha_hora      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    nivel           ENUM('INFO','WARN','ERROR','CRITICAL') NOT NULL,
    usuario         VARCHAR(50),                 -- username que ejecutó la acción
    accion          VARCHAR(80) NOT NULL,        -- LOGIN, ALTA_ANIMAL, BAJA_EMPLEADO, etc.
    entidad         VARCHAR(50),                 -- tabla afectada
    id_entidad      VARCHAR(30),                 -- id del registro afectado
    mensaje         VARCHAR(500),
    detalle_error   TEXT
) ENGINE=InnoDB;

CREATE INDEX idx_log_fecha   ON logs_sistema(fecha_hora);
CREATE INDEX idx_log_nivel   ON logs_sistema(nivel);
CREATE INDEX idx_log_usuario ON logs_sistema(usuario);

-- =============================================================================
-- 6. VISTAS ÚTILES PARA REPORTES (extras de nota adicional)
-- =============================================================================

-- Cantidad de animales activos por especie
CREATE OR REPLACE VIEW v_animales_por_especie AS
SELECT  e.nombre              AS especie,
        COUNT(a.id_animal)    AS total_activos
FROM    especies e
LEFT JOIN razas    r ON r.id_especie = e.id_especie
LEFT JOIN animales a ON a.id_raza    = r.id_raza AND a.estado = 'ACTIVO'
GROUP BY e.id_especie, e.nombre;

-- Animales que requieren atención urgente (alimenta al Notificador)
CREATE OR REPLACE VIEW v_animales_atencion_urgente AS
SELECT  a.id_animal,
        a.identificador_unico,
        e.nombre                AS especie,
        r.nombre                AS raza,
        a.estado_salud,
        hs.severidad,
        hs.diagnostico,
        hs.fecha_registro       AS fecha_diagnostico
FROM    animales a
JOIN    razas    r  ON r.id_raza    = a.id_raza
JOIN    especies e  ON e.id_especie = r.id_especie
JOIN    historial_salud hs ON hs.id_animal = a.id_animal
WHERE   a.estado = 'ACTIVO'
  AND   hs.atendido = FALSE
  AND   hs.severidad IN ('ALTA','URGENTE')
ORDER BY FIELD(hs.severidad,'URGENTE','ALTA'), hs.fecha_registro DESC;

-- Empleados más activos (cantidad de actividades registradas)
CREATE OR REPLACE VIEW v_empleados_mas_activos AS
SELECT  emp.id_empleado,
        CONCAT(emp.nombre, ' ', emp.apellido) AS empleado,
        rol.nombre                            AS rol,
        COUNT(act.id_actividad)               AS total_actividades
FROM    empleados emp
LEFT JOIN roles rol  ON rol.id_rol = emp.id_rol
LEFT JOIN actividades act ON act.id_empleado = emp.id_empleado
GROUP BY emp.id_empleado, emp.nombre, emp.apellido, rol.nombre
ORDER BY total_actividades DESC;

-- Resumen de actividades por fecha
CREATE OR REPLACE VIEW v_actividades_por_fecha AS
SELECT  act.fecha,
        ta.nombre                             AS tipo_actividad,
        COUNT(act.id_actividad)               AS cantidad
FROM    actividades act
JOIN    tipos_actividad ta ON ta.id_tipo_actividad = act.id_tipo_actividad
GROUP BY act.fecha, ta.nombre
ORDER BY act.fecha DESC, ta.nombre;

-- =============================================================================
-- 7. DATOS INICIALES (seed)
-- =============================================================================

INSERT INTO roles (nombre, descripcion) VALUES
    ('ADMIN',       'Administrador del sistema'),
    ('VETERINARIO', 'Profesional veterinario'),
    ('ENCARGADO',   'Encargado de la granja'),
    ('PEON',        'Peón rural');

INSERT INTO especies (nombre, nombre_cientifico) VALUES
    ('Bovino',  'Bos taurus'),
    ('Ovino',   'Ovis aries'),
    ('Porcino', 'Sus scrofa domesticus'),
    ('Equino',  'Equus caballus'),
    ('Aves',    'Gallus gallus domesticus');

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

INSERT INTO ubicaciones (nombre, tipo, capacidad_max) VALUES
    ('Corral 1',     'CORRAL',  50),
    ('Corral 2',     'CORRAL',  50),
    ('Potrero Norte','POTRERO', 200),
    ('Potrero Sur',  'POTRERO', 200),
    ('Establo A',    'ESTABLO', 30),
    ('Galpón Aves',  'GALPON',  500);

INSERT INTO tipos_actividad (nombre, requiere_animales) VALUES
    ('Ordeñe',       TRUE),
    ('Alimentación', TRUE),
    ('Vacunación',   TRUE),
    ('Desparasitado',TRUE),
    ('Limpieza',     FALSE),
    ('Mantenimiento',FALSE),
    ('Esquila',      TRUE),
    ('Pesaje',       TRUE);

-- Usuario administrador por defecto
-- IMPORTANTE: el password_hash es un placeholder. Generar uno real con BCrypt en Java
-- (ej: BCrypt.hashpw("admin123", BCrypt.gensalt())) y reemplazarlo, o crear el usuario
-- desde la propia aplicación.
INSERT INTO empleados (documento, nombre, apellido, id_rol, telefono, email, fecha_contratacion)
VALUES ('00000000', 'Admin', 'Sistema', 1, '0000000000', 'admin@granja.local', CURRENT_DATE);

INSERT INTO usuarios (username, password_hash, id_empleado, es_admin)
VALUES ('admin', '$2a$10$REEMPLAZAR_CON_HASH_BCRYPT_REAL', 1, TRUE);

-- =============================================================================
-- 8. TRIGGER DE CONSISTENCIA: sincroniza animales.estado_salud con historial_salud
-- =============================================================================

DELIMITER $$

CREATE TRIGGER trg_actualiza_estado_salud
AFTER INSERT ON historial_salud
FOR EACH ROW
BEGIN
    UPDATE animales
    SET    estado_salud = NEW.estado_salud
    WHERE  id_animal    = NEW.id_animal;
END$$

DELIMITER ;

-- =============================================================================
-- FIN DEL SCRIPT
-- =============================================================================
