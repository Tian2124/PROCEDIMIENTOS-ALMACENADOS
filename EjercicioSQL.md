Objetivo
Implementar y comprobar lógica de negocio dentro de PostgreSQL mediante un procedimiento almacenado, una función escalar y un trigger. Se evaluará que los objetos resuelvan responsabilidades diferentes y funcionen de manera integrada.

Caso: cambios de precios con trazabilidad
Una tienda digital necesita actualizar precios de su catálogo de forma controlada. Antes de aplicar un ajuste porcentual, debe poder calcular el precio resultante sin modificar datos. Al aplicar el ajuste, debe validar los parámetros y la existencia del producto. Cada cambio efectivo de precio debe dejar un registro automático con el valor anterior, el nuevo valor, la fecha y el usuario de la base de datos.

1. Preparación de la base de datos
Use PostgreSQL; documente la versión utilizada. Se recomienda PostgreSQL 18.
Con Chinook, identifique la tabla de pistas, su clave y su precio unitario. Adapte los nombres a la variante instalada; pueden existir nombres snake_case o identificadores entre comillas.
Con una base propia, incluya el SQL de creación y datos semilla para al menos tres productos con identificador, nombre y precio positivo.
Cree una tabla de auditoría con clave primaria, identificador del producto o pista, precio anterior, precio nuevo, fecha/hora y usuario de la base de datos.
Utilice tipos NUMERIC apropiados para los precios. No use datos personales reales ni credenciales en el repositorio o las capturas.
2. Función escalar: calcular el precio ajustado
Implemente una función propia, por ejemplo calcular_precio_ajustado(precio_actual numeric, porcentaje numeric), que devuelva un único valor NUMERIC.

Calcule precio_actual * (1 + porcentaje / 100) y redondee el resultado a dos decimales.
Admita porcentajes entre -50 y 100, ambos incluidos. Un porcentaje negativo representa una reducción.
Rechace parámetros NULL, precios iniciales menores o iguales a cero y porcentajes fuera del rango mediante errores claros.
Rechace también un resultado que, después del redondeo, sea menor o igual a cero.
No modifique ninguna tabla. Demuestre su uso mediante SELECT.
Justifique brevemente por qué es escalar y no una función que devuelve tablas.
3. Procedimiento almacenado: aplicar el cambio
Implemente un procedimiento propio, por ejemplo aplicar_ajuste_precio(id_producto integer, porcentaje numeric), definido con CREATE PROCEDURE y ejecutado con CALL.

Valide que el identificador no sea NULL y que el producto o pista exista.
Obtenga el precio actual y reutilice la función escalar para calcular el precio nuevo. No duplique la fórmula en el procedimiento.
Actualice únicamente el registro solicitado. Los demás productos y los precios históricos deben permanecer sin cambios.
Ante parámetros inválidos, genere un error claro y no deje cambios parciales.
No inserte directamente en la auditoría: esa responsabilidad corresponde al trigger.
No es obligatorio utilizar COMMIT o ROLLBACK dentro del procedimiento. Para esta práctica, deje el control de transacciones al script que ejecuta las pruebas.
4. Trigger: auditar cambios efectivos
Implemente un trigger de fila AFTER UPDATE sobre el catálogo y su función de soporte en PL/pgSQL, con retorno trigger.

Compare OLD y NEW y registre únicamente cambios efectivos de precio. Puede utilizar IS DISTINCT FROM para la comparación.
Inserte automáticamente una fila de auditoría por cada producto cuyo precio cambió. Registre los precios anterior y nuevo, fecha/hora y current_user.
Un UPDATE que asigne el mismo precio no debe producir una nueva fila de auditoría.
El mecanismo debe funcionar tanto al ejecutar CALL como al realizar un UPDATE directo válido sobre el catálogo.
La función de soporte del trigger no cuenta como la función escalar del apartado 2: son objetos con propósitos y tipos de retorno diferentes.
5. Pruebas obligatorias y criterios de aceptación
Incluya las pruebas en archivos SQL ejecutables. Cada caso debe tener comentarios con su propósito, datos utilizados y resultado esperado. En el PDF explique el resultado observado. Aísle las pruebas que generan errores para que no impidan ejecutar las demás; documente si se ejecutan por separado o con transacciones y puntos de restauración.

Casos mínimos
Caso	Evidencia requerida
1. Función: aumento y reducción	SELECT que demuestre 10 con 10% = 11.00 y 10 con -50% = 5.00.
2. Función: entradas inválidas	Pruebas independientes para NULL, precio cero o negativo y porcentaje fuera del rango. Muestre el error de cada caso.
3. Procedimiento: cambio válido	Estado antes, CALL, estado después y auditoría. Compruebe que otro producto no cambió.
4. Procedimiento: identificador inexistente	Error claro; precios y auditoría sin cambios producidos por esa llamada.
5. Procedimiento: porcentaje inválido	Error claro y ausencia de cambios parciales.
6. Trigger: UPDATE directo	Un cambio válido realizado sin CALL produce automáticamente su auditoría.
7. Trigger: precio sin cambio	UPDATE con el mismo valor; conteo de auditoría antes y después sin incremento.
8. Integridad transaccional	Dentro de BEGIN, aplique un cambio y muestre su auditoría; ejecute ROLLBACK y compruebe que el precio y la fila de auditoría se revirtieron. Los saltos de una secuencia no se consideran un error.
Use datos de prueba controlados e identificadores que existan en su instalación. No presente capturas de consultas no ejecutadas ni imágenes de resultados esperados como si fueran resultados reales.

6. Repositorio de GitHub
El repositorio debe ser accesible al docente e incluir, como mínimo:

README.md
sql/
  01_preparacion.sql
  02_funcion_escalar.sql
  03_procedimiento.sql
  04_trigger_y_funcion.sql
  05_pruebas.sql
README: contexto del caso, versión de PostgreSQL, forma de conexión, orden de ejecución y explicación de los tres objetos.
Si utiliza Chinook, indique la fuente y el archivo exacto de importación. No basta con escribir «importar Chinook».
El archivo de preparación debe crear la auditoría y las estructuras o datos adicionales necesarios. En una base propia debe incluir esquema y datos semilla.
Incluya el SQL completo de cada objeto, no únicamente capturas o llamadas de ejemplo.
Los scripts deben poder ejecutarse desde el estado inicial documentado. Explique cómo repetir las pruebas de forma segura.
No incluya contraseñas reales, archivos .env con secretos ni cadenas de conexión privadas. Si necesita configuración, publique solo valores de ejemplo.
7. Entregable en Canvas
Suba un único archivo PDF que contenga:

Nombre del estudiante y descripción breve de la base utilizada.
Enlace clicable al repositorio de GitHub, con acceso de lectura para el docente.
Una tabla que identifique el nombre, los parámetros, el resultado o efecto y la responsabilidad de cada objeto.
Capturas legibles que demuestren todos los casos del apartado 5. Se permite agrupar varias evidencias en una captura si se distinguen las consultas y los resultados.
Para cada captura: número de caso, explicación breve, resultado esperado y resultado obtenido. Para cambios de datos incluya antes y después.
Conclusión breve: diferencia entre función escalar, procedimiento y trigger, y por qué la auditoría no depende de que el usuario recuerde ejecutarla.
Las capturas pueden obtenerse desde DataGrip, pgAdmin o psql. Deben mostrar el SQL ejecutado y el resultado o error correspondiente. Un mensaje de «objeto creado» no demuestra por sí solo su funcionamiento.

8. Rúbrica: 5 puntos
Criterios de evaluación
Criterio	Desglose	Puntos
Función escalar	Cálculo y retorno escalar correctos: 0.75. Validaciones y ausencia de modificaciones: 0.50.	1.25
Procedimiento almacenado	CREATE PROCEDURE/CALL y reutilización de la función: 0.50. Actualización del registro correcto: 0.50. Manejo de errores sin cambios parciales: 0.25.	1.25
Trigger y auditoría	Trigger y función de soporte operativos: 0.50. Datos completos y correctos en auditoría: 0.50. No auditar valores sin cambio: 0.25.	1.25
Pruebas y evidencia en PDF	Casos 1 a 5 documentados con resultados: 0.25. Casos 6 a 8 documentados: 0.25. Capturas legibles y explicación de resultados: 0.25.	0.75
Repositorio y reproducibilidad	SQL completo, organizado y accesible: 0.25. README, preparación y orden de ejecución suficientes: 0.25.	0.50
Total	Se otorga crédito parcial por los subcriterios demostrados. Los componentes ausentes o no verificables no reciben el puntaje correspondiente.	5.00
Referencias
[Inglés] PostgreSQL: procedimientos definidos por el usuario.
[Inglés] PostgreSQL: funciones SQL.
[Inglés] PostgreSQL: funciones de trigger, OLD y NEW.
[Inglés] PostgreSQL: CREATE TRIGGER.
[Inglés] Chinook: repositorio de la base de ejemplo.
