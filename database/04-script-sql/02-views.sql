-- =============================================================================
-- 02 - VISTAS
-- Sistema de Gestión de Granja - Vistas para reportes y consultas frecuentes
-- =============================================================================
-- Dependencias: requiere que las tablas existan (ejecutar 01-schema.sql primero).
-- Idempotente: usa CREATE OR REPLACE, puede re-ejecutarse sin errores.
-- =============================================================================

USE granja_db;

-- -----------------------------------------------------------------------------
-- v_animales_por_especie
-- Cantidad de animales activos agrupados por especie.
-- Usado en: reporte "Animales por especie" del menú de la consola.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_animales_por_especie AS
SELECT  e.nombre              AS especie,
        COUNT(a.id_animal)    AS total_activos
FROM    especies e
LEFT JOIN razas    r ON r.id_especie = e.id_especie
LEFT JOIN animales a ON a.id_raza    = r.id_raza AND a.estado = 'ACTIVO'
GROUP BY e.id_especie, e.nombre;

-- -----------------------------------------------------------------------------
-- v_animales_atencion_urgente
-- Animales activos con estado de salud no atendido y severidad ALTA o URGENTE.
-- Usado en: clase Notificador para generar alertas simuladas.
-- -----------------------------------------------------------------------------
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
WHERE   a.estado    = 'ACTIVO'
  AND   hs.atendido = FALSE
  AND   hs.severidad IN ('ALTA','URGENTE')
ORDER BY FIELD(hs.severidad,'URGENTE','ALTA'), hs.fecha_registro DESC;

-- -----------------------------------------------------------------------------
-- v_empleados_mas_activos
-- Ranking de empleados según cantidad de actividades registradas.
-- Usado en: reporte "Empleados más activos" del menú de la consola.
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- v_actividades_por_fecha
-- Resumen diario de actividades, agrupadas por fecha y tipo.
-- Usado en: reporte "Actividades por fecha" del menú de la consola.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_actividades_por_fecha AS
SELECT  act.fecha,
        ta.nombre                             AS tipo_actividad,
        COUNT(act.id_actividad)               AS cantidad
FROM    actividades act
JOIN    tipos_actividad ta ON ta.id_tipo_actividad = act.id_tipo_actividad
GROUP BY act.fecha, ta.nombre
ORDER BY act.fecha DESC, ta.nombre;

-- =============================================================================
-- FIN DEL SCRIPT 02
-- =============================================================================
