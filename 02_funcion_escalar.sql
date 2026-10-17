-- =============================================================================
-- 02_funcion_escalar.sql
-- Descripción: Función escalar para calcular el precio ajustado con validaciones.
-- =============================================================================

CREATE OR REPLACE FUNCTION calcular_precio_ajustado(
    precio_actual NUMERIC,
    porcentaje NUMERIC
)
RETURNS NUMERIC AS $$
DECLARE
    precio_calculado NUMERIC;
BEGIN
    -- 1. Validar parámetros no nulos
    IF precio_actual IS NULL OR porcentaje IS NULL THEN
        RAISE EXCEPTION 'Error: Los parámetros precio_actual y porcentaje no pueden ser NULL.';
    END IF;

    -- 2. Validar precio inicial estrictamente positivo
    IF precio_actual <= 0 THEN
        RAISE EXCEPTION 'Error: El precio actual debe ser mayor a cero. Valor recibido: %', precio_actual;
    END IF;

    -- 3. Validar rango de porcentaje permitido (-50 a 100)
    IF porcentaje < -50 OR porcentaje > 100 THEN
        RAISE EXCEPTION 'Error: El porcentaje debe estar entre -50 y 100. Valor recibido: %', porcentaje;
    END IF;

    -- 4. Cálculo del precio ajustado con redondeo a 2 decimales
    precio_calculado := ROUND(precio_actual * (1 + porcentaje / 100.0), 2);

    -- 5. Validar que el resultado final redondeado sea mayor a cero
    IF precio_calculado <= 0 THEN
        RAISE EXCEPTION 'Error: El resultado del precio ajustado debe ser mayor a cero. Calculado: %', precio_calculado;
    END IF;

    RETURN precio_calculado;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
--  Que la función siempre devolverá exactamente el mismo resultado si se le pasan los mismos argumentos de entrada. Su respuesta no depende de datos externos, configuraciones del sistema, ni del paso del tiempo.