-- =============================================================================
-- 05_pruebas.sql
-- Descripción: Script ejecutable con todos los casos de prueba mínimos.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- CASO 1: Función: Aumento y reducción
-- -----------------------------------------------------------------------------
SELECT calcular_precio_ajustado(10.00, 10) AS aumento_10_porc;   -- Esperado: 11.00
SELECT calcular_precio_ajustado(10.00, -50) AS reduccion_50_porc; -- Esperado: 5.00


-- -----------------------------------------------------------------------------
-- CASO 2: Función: Entradas inválidas (Ejecutar de forma independiente)
-- -----------------------------------------------------------------------------
-- NULL:
-- SELECT calcular_precio_ajustado(NULL, 10);
-- Precio cero o negativo:
-- SELECT calcular_precio_ajustado(0, 10);
-- Porcentaje fuera de rango:
-- SELECT calcular_precio_ajustado(10, 101);


-- -----------------------------------------------------------------------------
-- CASO 3: Procedimiento: Cambio válido
-- -----------------------------------------------------------------------------
-- Estado ANTES
SELECT * FROM producto WHERE id_producto IN (1, 2);

-- Ejecutar ajuste
CALL aplicar_ajuste_precio(1, 20.00);

-- Estado DESPUÉS (El producto 1 cambia de 10.00 a 12.00; el producto 2 permanece igual)
SELECT * FROM producto WHERE id_producto IN (1, 2);
SELECT * FROM auditoria_precio;


-- -----------------------------------------------------------------------------
-- CASO 4: Procedimiento: Identificador inexistente
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    CALL aplicar_ajuste_precio(9999, 10.00);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error esperado: %', SQLERRM;
END $$;


-- -----------------------------------------------------------------------------
-- CASO 5: Procedimiento: Porcentaje inválido
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    CALL aplicar_ajuste_precio(1, 150.00);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error esperado: %', SQLERRM;
END $$;


-- -----------------------------------------------------------------------------
-- CASO 6: Trigger: UPDATE directo
-- -----------------------------------------------------------------------------
UPDATE producto SET precio = 15.00 WHERE id_producto = 2;

-- Comprobar auditoría generada automáticamente
SELECT * FROM auditoria_precio WHERE id_producto = 2;


-- -----------------------------------------------------------------------------
-- CASO 7: Trigger: Precio sin cambio
-- -----------------------------------------------------------------------------
SELECT COUNT(*) AS total_antes FROM auditoria_precio;

-- Asignar el mismo precio actual
UPDATE producto SET precio = 15.00 WHERE id_producto = 2;

SELECT COUNT(*) AS total_despues FROM auditoria_precio; -- Debe mantenerse igual


-- -----------------------------------------------------------------------------
-- CASO 8: Integridad transaccional (BEGIN... ROLLBACK)
-- -----------------------------------------------------------------------------
BEGIN;

CALL aplicar_ajuste_precio(3, 10.00); -- Cambia producto 3 de 100.00 a 110.00

-- Verificar cambios temporales
SELECT * FROM producto WHERE id_producto = 3;
SELECT * FROM auditoria_precio WHERE id_producto = 3;

ROLLBACK;

-- Verificar restauración de datos y reversión de auditoría
SELECT * FROM producto WHERE id_producto = 3;
SELECT * FROM auditoria_precio WHERE id_producto = 3;