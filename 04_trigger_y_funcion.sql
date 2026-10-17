-- =============================================================================
-- 04_trigger_y_funcion.sql
-- Descripción: Función de soporte y Trigger AFTER UPDATE para auditoría pasiva.
-- =============================================================================

-- 1. Función de soporte del trigger
CREATE OR REPLACE FUNCTION fn_auditar_cambio_precio()
RETURNS TRIGGER AS $$
BEGIN
    -- Comparar OLD y NEW para registrar cambios efectivos de precio
    IF OLD.precio IS DISTINCT FROM NEW.precio THEN
        INSERT INTO auditoria_precio (
            id_producto,
            precio_anterior,
            precio_nuevo,
            fecha_hora,
            usuario_bd
        )
        VALUES (
            NEW.id_producto,
            OLD.precio,
            NEW.precio,
            CURRENT_TIMESTAMP,
            CURRENT_USER
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Declaración del Trigger sobre la tabla del catálogo
DROP TRIGGER IF EXISTS trg_auditar_cambio_precio ON producto;

CREATE TRIGGER trg_auditar_cambio_precio
AFTER UPDATE OF precio ON producto
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_cambio_precio();