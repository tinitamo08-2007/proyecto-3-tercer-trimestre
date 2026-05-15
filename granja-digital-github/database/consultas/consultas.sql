-- ===================================================================
--  GRANJA DIGITAL - Consultas más usadas
--  Estas son las consultas que se ejecutan desde la aplicación Java
--  y las que se podrán reutilizar en la versión web.
-- ===================================================================

USE granja;

-- -------------------------------------------------------------------
-- 1. Listado completo de animales (orden por ID)
-- -------------------------------------------------------------------
SELECT id, especie, raza, fecha_nacimiento, identificador,
       estado_salud, ubicacion, estado
FROM animales
ORDER BY id;

-- -------------------------------------------------------------------
-- 2. Animales activos en un corral concreto (parametrizable)
-- -------------------------------------------------------------------
SELECT id, especie, raza, identificador
FROM animales
WHERE estado = 'ACTIVO'
  AND ubicacion = 'Corral 1';

-- -------------------------------------------------------------------
-- 3. Cuántos animales hay por especie (reporte agregado)
-- -------------------------------------------------------------------
SELECT especie, COUNT(*) AS total
FROM animales
GROUP BY especie
ORDER BY total DESC;

-- -------------------------------------------------------------------
-- 4. Animales en estado de salud preocupante
-- -------------------------------------------------------------------
SELECT id, especie, raza, identificador, estado_salud, ubicacion
FROM animales
WHERE estado_salud IN ('grave', 'critica')
  AND estado = 'ACTIVO';

-- -------------------------------------------------------------------
-- 5. Empleados con su número de actividades realizadas
-- -------------------------------------------------------------------
SELECT e.id, e.nombre, e.rol, COUNT(a.id) AS total_actividades
FROM empleados e
LEFT JOIN actividades a ON a.id_empleado = e.id
GROUP BY e.id, e.nombre, e.rol
ORDER BY total_actividades DESC;

-- -------------------------------------------------------------------
-- 6. Actividades de una fecha concreta (con el nombre del empleado)
-- -------------------------------------------------------------------
SELECT a.id, a.fecha, a.hora, a.tipo_actividad, a.descripcion,
       e.nombre AS empleado
FROM actividades a
JOIN empleados e ON a.id_empleado = e.id
WHERE a.fecha = '2026-05-10'
ORDER BY a.hora;

-- -------------------------------------------------------------------
-- 7. Animales que participaron en una actividad concreta
-- -------------------------------------------------------------------
SELECT an.id, an.especie, an.identificador
FROM actividad_animal aa
JOIN animales an ON aa.id_animal = an.id
WHERE aa.id_actividad = 1;

-- -------------------------------------------------------------------
-- 8. Todas las actividades en las que ha participado un animal
-- -------------------------------------------------------------------
SELECT a.id, a.fecha, a.hora, a.tipo_actividad, a.descripcion
FROM actividades a
JOIN actividad_animal aa ON a.id = aa.id_actividad
WHERE aa.id_animal = 1
ORDER BY a.fecha DESC, a.hora DESC;

-- -------------------------------------------------------------------
-- 9. Empleados más activos en los últimos 30 días
-- -------------------------------------------------------------------
SELECT e.nombre, COUNT(a.id) AS actividades_mes
FROM empleados e
JOIN actividades a ON a.id_empleado = e.id
WHERE a.fecha >= CURDATE() - INTERVAL 30 DAY
GROUP BY e.id, e.nombre
ORDER BY actividades_mes DESC;

-- -------------------------------------------------------------------
-- 10. Resumen de actividades por tipo
-- -------------------------------------------------------------------
SELECT tipo_actividad, COUNT(*) AS total
FROM actividades
GROUP BY tipo_actividad
ORDER BY total DESC;

-- -------------------------------------------------------------------
-- 11. Promedio de actividades diarias en el mes actual
-- -------------------------------------------------------------------
SELECT ROUND(COUNT(*) / GREATEST(DAY(LAST_DAY(CURDATE())), 1), 2) AS media_diaria
FROM actividades
WHERE YEAR(fecha) = YEAR(CURDATE())
  AND MONTH(fecha) = MONTH(CURDATE());

-- -------------------------------------------------------------------
-- 12. Animales que NUNCA han aparecido en una actividad
-- -------------------------------------------------------------------
SELECT an.id, an.especie, an.identificador
FROM animales an
LEFT JOIN actividad_animal aa ON aa.id_animal = an.id
WHERE aa.id_animal IS NULL;
