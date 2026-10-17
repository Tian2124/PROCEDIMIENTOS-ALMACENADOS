-- =============================================================================
-- 03_procedimiento.sql
-- Descripción: Procedimiento almacenado para aplicar el cambio de precio.
-- =============================================================================

CREATE OR REPLACE PROCEDURE aplicar_ajuste_precio(
    p_id_producto INT,
    p_porcentaje NUMERIC
)
LANGUAGE plpgsql AS $$
DECLARE
    v_precio_actual NUMERIC;
    v_precio_nuevo NUMERIC;
BEGIN
    -- 1. Validar identificador no nulo
    IF p_id_producto IS NULL THEN
        RAISE EXCEPTION 'Error: El ID del producto no puede ser NULL.';
    END IF;

    -- 2. Verificar existencia del producto y obtener precio actual
    SELECT precio INTO v_precio_actual
    FROM producto
    WHERE id_producto = p_id_producto;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Error: El producto con ID % no existe en el catálogo.', p_id_producto;
    END IF;

    -- 3. Reutilizar la función escalar para calcular el precio nuevo
    v_precio_nuevo := calcular_precio_ajustado(v_precio_actual, p_porcentaje);

    -- 4. Actualizar únicamente el registro solicitado
    UPDATE producto
    SET precio = v_precio_nuevo
    WHERE id_producto = p_id_producto;

END;
$$;