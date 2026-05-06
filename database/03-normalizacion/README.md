# 03 — Normalización

Este documento justifica que el esquema relacional se encuentra en **Tercera Forma Normal (3FN)**.

## Recordatorio teórico

| Forma | Condición |
|---|---|
| **1FN** | Atributos atómicos, sin grupos repetitivos. Cada celda contiene un solo valor. |
| **2FN** | Está en 1FN y todos los atributos no clave dependen de la clave primaria completa (relevante en PKs compuestas). |
| **3FN** | Está en 2FN y no hay dependencias transitivas (atributos no clave que dependen de otros atributos no clave). |

## Análisis tabla por tabla

### `animales`
- **PK:** `id_animal`
- **1FN:** ✓ Todos los atributos son atómicos. La especie y la raza no se almacenan como string libre sino como FK a tablas separadas.
- **2FN:** ✓ La PK no es compuesta, por lo tanto se cumple trivialmente.
- **3FN:** ✓ No hay dependencias transitivas. La especie del animal NO se almacena directamente en `animales`; se obtiene vía `razas.id_especie`. Esto evita la transitividad `id_animal → id_raza → id_especie`.

### `actividad_animal`
- **PK compuesta:** `(id_actividad, id_animal)`
- **1FN:** ✓
- **2FN:** ✓ El único atributo no clave (`observacion`) depende de la PK completa, no de una parte (la observación es específica a *esta* combinación actividad–animal).
- **3FN:** ✓ No hay dependencias transitivas.

### `razas`
- **PK:** `id_raza`
- **1FN:** ✓
- **2FN:** ✓
- **3FN:** ✓ La especie está como FK; el nombre científico vive en `especies` y no se duplica en `razas`.

### `empleados`
- **PK:** `id_empleado`
- **1FN:** ✓
- **2FN:** ✓
- **3FN:** ✓ El nombre del rol no se almacena en `empleados`; se accede vía `id_rol → roles.nombre`. Si fueran columnas como `rol_nombre` y `rol_descripcion`, habría dependencia transitiva `id_empleado → id_rol → rol_nombre`.

### `usuarios`
- **PK:** `id_usuario`
- **1FN:** ✓ El password se guarda como hash, atómico.
- **2FN:** ✓
- **3FN:** ✓ Los datos personales del usuario no se duplican; se accede vía `id_empleado`.

### `eventos_animal`, `historial_salud`, `actividades`
Mismo análisis: PKs simples, sin grupos repetitivos, sin dependencias transitivas. Datos de animal o empleado se referencian por FK, no se duplican.

## Decisiones explícitas de NO normalizar más

### `animales.estado_salud` "duplica" información de `historial_salud`
Estrictamente hablando, podríamos eliminar la columna y obtener el estado actual con un `SELECT estado_salud FROM historial_salud WHERE id_animal = X ORDER BY fecha_registro DESC LIMIT 1`.

**Decisión:** mantener la columna en `animales` como **denormalización controlada** y sincronizarla por trigger (`trg_actualiza_estado_salud`).

**Justificación:** las consultas más frecuentes del sistema (listar animales con su estado actual, filtrar por estado, alimentar el menú de la consola) se vuelven mucho más rápidas. La consistencia se garantiza por el trigger, no por confiar en que la app actualice ambas tablas.

### Logs en archivo Y en BD
El enunciado pide logs en `.txt`. Adicionalmente mantengo `logs_sistema` en la BD. Esto NO es violación de normalización porque son sistemas distintos: el archivo es a prueba de fallas del motor, la tabla permite consultas SQL. La regla "no duplicar" se aplica dentro del esquema relacional, no entre la BD y los archivos.

## Resumen

Todas las tablas del esquema están en **3FN**. Las únicas redundancias son:
1. `animales.estado_salud` ↔ último registro de `historial_salud` → resuelta por trigger.
2. Logs en archivo y tabla → son medios distintos, no aplica normalización entre ellos.
