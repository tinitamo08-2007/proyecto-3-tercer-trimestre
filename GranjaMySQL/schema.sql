-- GranjaMySQL · esquema de la base de datos "granja".
-- Conexión default: granja-mysql-granjamysql.j.aivencloud.com:18071, user=avnadmin.

DROP DATABASE IF EXISTS granja;

CREATE DATABASE granja
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_spanish_ci;

USE granja;


-- Empleados (va primero porque actividades la referencia)
CREATE TABLE empleados (
    id                 INT AUTO_INCREMENT PRIMARY KEY,
    nombre             VARCHAR(100) NOT NULL,
    rol                VARCHAR(50),
    telefono           VARCHAR(20),
    fecha_contratacion DATE
);


-- Animales. "estado" reproduce el enum EstadoAnimal del programa Java.
CREATE TABLE animales (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    especie          VARCHAR(50)  NOT NULL,
    raza             VARCHAR(50),
    fecha_nacimiento DATE,
    identificador    VARCHAR(20)  NOT NULL UNIQUE,
    estado_salud     VARCHAR(50),
    ubicacion        VARCHAR(100),
    estado           ENUM('ACTIVO','VENDIDO','FALLECIDO','TRASLADADO')
                     NOT NULL DEFAULT 'ACTIVO'
);


-- Actividades. Usamos "tipo_actividad" para que coincida con server.js.
CREATE TABLE actividades (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    fecha          DATE NOT NULL,
    hora           TIME,
    tipo_actividad VARCHAR(50) NOT NULL,
    descripcion    VARCHAR(255),
    id_empleado    INT,
    CONSTRAINT fk_actividad_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleados(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);


-- Tabla puente N:M entre actividades y animales.
CREATE TABLE actividad_animal (
    id_actividad INT NOT NULL,
    id_animal    INT NOT NULL,
    PRIMARY KEY (id_actividad, id_animal),
    CONSTRAINT fk_aa_actividad
        FOREIGN KEY (id_actividad) REFERENCES actividades(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_aa_animal
        FOREIGN KEY (id_animal)    REFERENCES animales(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- Vista que junta la actividad con el nombre del empleado y los animales,
-- para que granja-web pueda mostrar las columnas "empleado" y "animales"
-- con SELECT * FROM vista_actividades.
CREATE OR REPLACE VIEW vista_actividades AS
SELECT
    a.id,
    a.fecha,
    a.hora,
    a.tipo_actividad,
    a.descripcion,
    a.id_empleado,
    e.nombre AS empleado,
    GROUP_CONCAT(an.identificador ORDER BY an.identificador SEPARATOR ', ') AS animales
FROM actividades a
LEFT JOIN empleados        e  ON a.id_empleado   = e.id
LEFT JOIN actividad_animal aa ON aa.id_actividad = a.id
LEFT JOIN animales         an ON aa.id_animal    = an.id
GROUP BY a.id, a.fecha, a.hora, a.tipo_actividad, a.descripcion, a.id_empleado, e.nombre;
