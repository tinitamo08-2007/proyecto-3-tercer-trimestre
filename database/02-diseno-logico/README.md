# 02 — Diseño Lógico (Modelo Relacional)

## Archivos

- `modelo-relacional.dbml` — Fuente en DBML, editable y visualizable en [dbdiagram.io](https://dbdiagram.io).
- `modelo-relacional.png` — Export del diagrama para incluir en la memoria.
- `transformaciones.md` — Decisiones tomadas al pasar del modelo conceptual al relacional.

## Tablas resultantes

13 tablas agrupadas por dominio:

**Catálogos:** `roles`, `especies`, `razas`, `ubicaciones`, `tipos_actividad`
**Personal:** `empleados`, `usuarios`
**Ganado:** `animales`, `eventos_animal`, `historial_salud`
**Operaciones:** `actividades`, `actividad_animal`
**Auditoría:** `logs_sistema`

## Reglas aplicadas en la transformación E/R → Relacional

### Entidades fuertes → tablas con PK propia
Cada entidad del modelo conceptual se transformó en una tabla con un `id_*` autoincremental como clave primaria sustituta (surrogate key), incluso cuando existe una clave natural (ej: `identificador_unico` del animal). Razón: las claves sustitutas son inmutables y simplifican las FKs.

### Relaciones N:M → tabla puente
La relación "una actividad involucra varios animales" se materializó como `actividad_animal`, con PK compuesta `(id_actividad, id_animal)`.

### Relaciones 1:1 opcionales → FK con UNIQUE
La relación Empleado–Usuario (no todo empleado tiene login) se modeló como `usuarios.id_empleado` con restricción `UNIQUE`, permitiendo NULL.

### Atributos multivaluados / históricos → tablas separadas
- "Estados de salud que ha tenido el animal" → tabla `historial_salud`
- "Eventos en la vida del animal" → tabla `eventos_animal`

### Dominios cerrados → ENUM
Estados (`SANO`, `ENFERMO`, ...), tipos de evento, severidades. Evita strings libres y valida desde el motor.

### Borrado lógico
Tablas `animales` y `empleados` usan columna de estado en lugar de DELETE físico. Razón: mantener historial para reportes (ej. "empleados más activos del año pasado" requiere ver empleados ya dados de baja).

## Restricciones aplicadas

| Tipo | Ejemplo |
|---|---|
| PRIMARY KEY | Toda tabla tiene PK |
| FOREIGN KEY | Con `ON DELETE` apropiado por caso (CASCADE en histórico, RESTRICT en catálogos, SET NULL cuando aplica) |
| UNIQUE | `identificador_unico` del animal, `username`, combinación `(id_especie, nombre)` en razas |
| NOT NULL | Atributos esenciales |
| CHECK | `fecha_baja >= fecha_contratacion`, `fecha_nacimiento <= CURRENT_DATE` |
| DEFAULT | Estados iniciales, timestamps automáticos |

## Índices definidos

Más allá de los índices implícitos por PK/UNIQUE/FK, se agregaron índices secundarios para consultas frecuentes:

- `idx_animal_estado`, `idx_animal_estado_salud` — filtros por estado en reportes
- `idx_actividad_fecha` — búsquedas por rango de fechas
- `idx_salud_severidad` — soporte al Notificador
- `idx_log_fecha`, `idx_log_nivel` — consultas de auditoría
