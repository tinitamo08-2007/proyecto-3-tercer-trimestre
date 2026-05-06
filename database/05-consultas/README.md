# 05 — Consultas

Catálogo de consultas SQL utilizadas por la aplicación Java y la versión Web.

## Archivos

| Archivo | Uso |
|---|---|
| `consultas-java.sql` | Consultas invocadas desde los DAOs de la app de consola |
| `consultas-web.sql` | Consultas usadas por los endpoints de la versión web |
| `consultas-reportes.sql` | Reportes adicionales (extras de nota) |

## Convención

Cada consulta tiene un encabezado tipo:

```sql
-- ID:          Q-ANI-001
-- Nombre:      listarAnimalesActivos
-- Descripción: Devuelve todos los animales con estado ACTIVO,
--              incluyendo especie, raza y ubicación.
-- Usado en:    AnimalDAO.listar()
-- Parámetros:  ninguno
-- Retorna:     id_animal, identificador_unico, especie, raza, ubicacion, estado_salud

SELECT  a.id_animal, a.identificador_unico, e.nombre AS especie, ...
FROM    animales a
JOIN    razas r     ON r.id_raza = a.id_raza
JOIN    especies e  ON e.id_especie = r.id_especie
LEFT JOIN ubicaciones u ON u.id_ubicacion = a.id_ubicacion
WHERE   a.estado = 'ACTIVO';
```

El ID `Q-XXX-NNN` permite referenciar la consulta desde el código Java en comentarios:
```java
// Ver: database/05-consultas/consultas-java.sql @ Q-ANI-001
```

## Categorías de IDs

| Prefijo | Dominio |
|---|---|
| `Q-ANI-` | Animales |
| `Q-EMP-` | Empleados |
| `Q-ACT-` | Actividades |
| `Q-USR-` | Usuarios / autenticación |
| `Q-LOG-` | Logs y auditoría |
| `Q-REP-` | Reportes |

## Buenas prácticas

- **Siempre usar `PreparedStatement` desde Java**, nunca concatenar valores en el SQL. Las consultas en estos archivos usan `?` como placeholder.
- Las consultas que afectan datos (INSERT, UPDATE, DELETE) deben ejecutarse dentro de transacciones cuando se relacionan con otras tablas (ej: registrar venta = INSERT en `eventos_animal` + UPDATE de `animales.estado`).
- Para reportes pesados, preferir las vistas definidas en `04-script-sql/02-views.sql` antes que reescribir el JOIN.
