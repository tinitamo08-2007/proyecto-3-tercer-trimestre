-- =============================================================================
-- 03 - TRIGGERS
-- Sistema de Gestión de Granja - Triggers de consistencia
-- =============================================================================
-- Dependencias: requiere que las tablas existan (ejecutar 01-schema.sql primero).
-- Idempotente: usa DROP TRIGGER IF EXISTS, puede re-ejecutarse sin errores.
-- =============================================================================

USE granja_db;

-- -----------------------------------------------------------------------------
-- trg_actualiza_estado_salud
-- Sincroniza animales.estado_salud con el último registro insertado en
-- historial_salud. Garantiza que la columna desnormalizada (estado actual del
-- animal) refleje siempre el último diagnóstico, sin depender de que la app
-- recuerde actualizar ambas tablas.
-- -----------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_actualiza_estado_salud;

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
-- FIN DEL SCRIPT 03
-- =============================================================================
