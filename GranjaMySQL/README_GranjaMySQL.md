# GranjaMySQL

Base de datos en nube de MySQL mediante [`Aiven`](https://aiven.io/) para el 3º proyecto DAM integrado: **Digitalización de la Granja - sistema de administración**. Es una parte pilar del proyecto, junto al programa Java [`Programacion/GranjaDigital`](../Programacion/GranjaDigital) y la aplicación web [`granja-web`](../granja-web).

---

## Conexión

| Campo            | Valor                                         |
|------------------|-----------------------------------------------|
| Connection name  | `GranjaMySQL`                                 |
| Hostname         | `granja-mysql-granjamysql.j.aivencloud.com`   |
| Port             | `18071`                                       |
| Username         | `avnadmin`                                    |
| Password         | `████████████████████████████████████`        |
| Default schema   | `granja`                                      |

> Configuración de los datos formal de la plantilla arriba, consulta a la contraseña correspondiente a cada usuario.
>
> **!!IMPORTANTE!! Ampliar el límite de latencia de conexión entre 2000 a 4000(ms) en nuestro caso de conexión remota.**
>
> Según la **rebuilding**(reconstrucción) de Aiven, es posible que los usuarios que utilicen la base de datos gratuita de Aiven se encuentren con un proceso de reconstrucción prolongado (que dura aproximadamente 10 minutos); durante ese tiempo, al establecer una conexión remota, es posible que aparezca el error `getaddrinfo ENOTFOUND ...`.

---

## Estructura

Cuatro tablas y una vista.

La vista vista_actividades (no aparece como entidad porque no es tabla): hace LEFT JOIN entre actividades, empleados y actividad_animal + animales para que granja-web pueda mostrar las columnas empleado y animales con un único SELECT *. 

Diagrama resumido:
![alt text](diagrama.jpeg)

### `empleados`
Personal de la granja: veterinarios, peones, encargados...

| Columna             | Tipo          | Notas                                |
|---------------------|---------------|--------------------------------------|
| `id`                | INT PK AI     |                                      |
| `nombre`            | VARCHAR(100)  | Obligatorio                          |
| `rol`               | VARCHAR(50)   | "Veterinario", "Peón", "Encargada"…  |
| `telefono`          | VARCHAR(20)   |                                      |
| `fecha_contratacion`| DATE          |                                      |

### `animales`
Cada animal registrado en la granja.

| Columna           | Tipo          | Notas                                                       |
|-------------------|---------------|-------------------------------------------------------------|
| `id`              | INT PK AI     |                                                             |
| `especie`         | VARCHAR(50)   | Obligatorio. "Bovino", "Porcino", "Ovino"…                  |
| `raza`            | VARCHAR(50)   |                                                             |
| `fecha_nacimiento`| DATE          |                                                             |
| `identificador`   | VARCHAR(20)   | Obligatorio y **único** (arete, chip…)                      |
| `estado_salud`    | VARCHAR(50)   | Texto libre: "Sano", "En tratamiento"…                      |
| `ubicacion`       | VARCHAR(100)  | "Corral 1", "Potrero 2"…                                    |
| `estado`          | ENUM          | `ACTIVO` / `VENDIDO` / `FALLECIDO` / `TRASLADADO` (def. ACTIVO). Equivale al enum `EstadoAnimal` de Java. |

### `actividades`
Tareas diarias: ordeños, vacunaciones, alimentación, limpieza…

| Columna          | Tipo          | Notas                                                   |
|------------------|---------------|---------------------------------------------------------|
| `id`             | INT PK AI     |                                                         |
| `fecha`          | DATE          | Obligatoria                                             |
| `hora`           | TIME          |                                                         |
| `tipo_actividad` | VARCHAR(50)   | Obligatorio. Mismo nombre de columna que usa `server.js`|
| `descripcion`    | VARCHAR(255)  | Opcional                                                |
| `id_empleado`    | INT FK        | → `empleados.id`. `ON DELETE SET NULL`                  |

### `actividad_animal`
Tabla puente N:M. Una actividad puede afectar a varios animales y un animal puede aparecer en varias actividades.

| Columna        | Tipo    | Notas                              |
|----------------|---------|------------------------------------|
| `id_actividad` | INT PK  | → `actividades.id` (CASCADE)       |
| `id_animal`    | INT PK  | → `animales.id`    (CASCADE)       |

### `vista_actividades` (vista)
Hace el JOIN entre `actividades`, `empleados` y `actividad_animal` y devuelve dos columnas extra que el frontend espera:

- `empleado` → nombre del empleado responsable.
- `animales` → lista de identificadores separados por coma.

Útil para que `granja-web` muestre las columnas "Responsable" y "Animales" cambiando la línea en `server.js`:

```diff
- 'SELECT * FROM actividades'
+ 'SELECT * FROM vista_actividades'
```

---

## Cómo inicializar la base de datos

### Opción A — Línea de comandos

```bash
cd GranjaMySQL
mysql -u root -p < schema.sql
mysql -u root -p < datos-ejemplo.sql
```

(Se te pedirá la contraseña en cada llamada.)

### Opción B — MySQL Workbench

1. Connectar con la conexión `GranjaMySQL`.
2. *File → Open SQL Script…* → abre `schema.sql` → ejecútalo (rayo amarillo).
3. Repite con `datos-ejemplo.sql`.
4. *Schemas → granja → Tables*: deberías ver `empleados`, `animales`, `actividades`, `actividad_animal`.

### Comprobación rápida

```sql
USE granja;
SELECT especie, COUNT(*) AS total FROM animales GROUP BY especie;
SELECT * FROM vista_actividades;
```

Si las dos consultas devuelven filas, la base está lista.

---

## Archivos

| Archivo              | Para qué sirve                              |
|----------------------|---------------------------------------------|
| `schema.sql`         | Crea la base `granja`, las tablas y la vista. |
| `datos-ejemplo.sql`  | Inserta datos de muestra (los mismos del DEMO de la web). |
| `README.md`          | Este documento.                             |

---

## Relación con el resto del proyecto

- **`granja-web`** ya apunta a `database: 'granja'` en `server.js`, con `user: 'root'` y `password: ''`. Si fijas la contraseña anterior, **Valentina**, recuerda actualizar también `server.js`.
- Connectar con Aiven mediante Java y [`JDBC Driver`](https://dev.mysql.com/downloads/connector/j/) para **`Programacion/GranjaDigital`**. Las clases `Animal`, `Empleado` y `Actividad` ya coinciden en campos con esta base, pero cuando se añada el JDBC, configuralo en `module-info.java` el `require java.sql` para luego la importación en el stack de **Eclipse**; Si trabaja con VS Code solo quitar el archivo.

---

## Notas de diseño

- `tipo_actividad` es VARCHAR (no ENUM) porque el DEMO de la web guarda valores con tilde como "Ordeño", "Vacunación", "Alimentación". El enum equivalente vive en la clase Java `TipoActividad`.
- `ON DELETE SET NULL` en `actividades.id_empleado`: si se borra un empleado, sus actividades quedan huérfanas pero no se pierden.
- `ON DELETE CASCADE` en `actividad_animal`: si se borra una actividad o un animal, sus relaciones puente desaparecen.