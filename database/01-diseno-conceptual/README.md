# 01 — Diseño Conceptual (Modelo Entidad/Relación)

## Archivos

- `modelo-er.drawio` — Fuente editable del diagrama (abrir con [draw.io](https://app.diagrams.net) o VS Code con la extensión Draw.io Integration).
- `modelo-er.png` — Export para incluir en la memoria.
- `entidades-y-relaciones.md` — Listado textual de entidades y relaciones.

## Entidades identificadas

| Entidad | Justificación |
|---|---|
| **Animal** | Núcleo del sistema. Cada individuo del rebaño es una instancia. |
| **Empleado** | Persona que trabaja en la granja y ejecuta actividades. |
| **Actividad** | Hecho registrado: ordeñe, vacunación, alimentación, etc. |
| **Ubicación** | Lugar físico donde están los animales (corral/potrero). |
| **Especie / Raza** | Catálogos para clasificar animales. Se separan porque una especie tiene N razas. |
| **Rol** | Catálogo de cargos del empleado. |
| **Usuario** | Credenciales de acceso al sistema. Se separa de Empleado porque no todo empleado tiene login. |
| **EventoAnimal** | Registro histórico de venta/fallecimiento/traslado de un animal. |
| **HistorialSalud** | Evolución sanitaria del animal. Permite trazabilidad y alimenta el Notificador. |

## Relaciones principales

- Un **Empleado** *tiene* un **Rol** (N:1)
- Un **Empleado** *puede tener* un **Usuario** (1:1, opcional)
- Una **Raza** *pertenece a* una **Especie** (N:1)
- Un **Animal** *es de una* **Raza** y *está en una* **Ubicación** (N:1, N:1)
- Un **Empleado** *registra* **Actividades** (1:N)
- Una **Actividad** *involucra a* varios **Animales** y un **Animal** *participa en* varias **Actividades** (N:M)
- Un **Animal** *tiene* historial de **EventoAnimal** y **HistorialSalud** (1:N)

## Decisiones de diseño y por qué

### ¿Por qué separar Especie y Raza?
Un atributo "raza" como string libre genera datos sucios ("Holstein", "holstein", "Holsten"). Separar en dos catálogos relacionados permite validación, reportes agrupados por especie y agregar razas sin tocar código.

### ¿Por qué Usuario es una entidad aparte de Empleado?
Solo algunos empleados (admin, encargado) necesitan login. Si pusiéramos `username`/`password` directamente en Empleado, quedarían columnas NULL para la mayoría. Además, Usuario tiene atributos propios (intentos fallidos, último acceso) que no aplican a un peón sin acceso al sistema.

### ¿Por qué EventoAnimal en lugar de simplemente cambiar el estado del Animal?
Si solo cambiamos `estado = 'VENDIDO'`, perdemos el cuándo, a quién, por cuánto y quién lo registró. EventoAnimal preserva la historia y soporta auditoría.

### ¿Por qué HistorialSalud es N:1 con Animal y no un atributo?
La salud cambia en el tiempo. Un campo `estado_salud` en Animal solo guarda el ahora; HistorialSalud guarda toda la evolución y es la fuente para el Notificador (alertas por severidad ALTA/URGENTE).

## Notación usada

- Entidades: rectángulos
- Atributos: óvalos (clave subrayada)
- Relaciones: rombos
- Cardinalidades: notación min..max (Chen) o (1,N) / (0,1)
