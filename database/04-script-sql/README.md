# 04 — Scripts SQL

Scripts de creación, mantenimiento y carga inicial de la base de datos.

## Archivos y orden de ejecución

| Orden | Archivo | Descripción |
|---|---|---|
| 1 | `01-schema.sql` | Crea la BD, tablas, FKs e índices |
| 2 | `02-views.sql` | Vistas para reportes |
| 3 | `03-triggers.sql` | Triggers de consistencia |
| 4 | `04-datos-iniciales.sql` | Catálogos, usuario admin |

## Ejecución desde línea de comandos

```bash
# Crear todo desde cero
mysql -u root -p < 01-schema.sql
mysql -u root -p granja_db < 02-views.sql
mysql -u root -p granja_db < 03-triggers.sql
mysql -u root -p granja_db < 04-datos-iniciales.sql

# O en una sola línea
cat 01-schema.sql 02-views.sql 03-triggers.sql 04-datos-iniciales.sql | mysql -u root -p
```

## Ejecución desde MySQL Workbench

1. File -> Open SQL Script -> seleccionar el archivo en orden.
2. Ejecutar con el rayo amarillo o (Ctrl+Enter).

## Verificación

Tras ejecutar todos los scripts, deberías ver:

```sql
USE granja_db;
SHOW TABLES;
-- 13 tablas

SELECT COUNT(*) FROM roles;          -- 4
SELECT COUNT(*) FROM especies;       -- 5
SELECT COUNT(*) FROM razas;          -- 9
SELECT COUNT(*) FROM ubicaciones;    -- 6
SELECT COUNT(*) FROM tipos_actividad;-- 8
SELECT COUNT(*) FROM usuarios WHERE es_admin = TRUE; -- 1
```

## Reset rápido durante el desarrollo

```bash
mysql -u root -p < 99-drop.sql
mysql -u root -p < 01-schema.sql
mysql -u root -p granja_db < 02-views.sql
mysql -u root -p granja_db < 03-triggers.sql
mysql -u root -p granja_db < 04-datos-iniciales.sql
```

## Importante

- El usuario `admin` se crea con un `password_hash` placeholder. **Reemplazar por un hash BCrypt real generado desde Java**, o crear el usuario desde la propia aplicación al iniciar por primera vez.
- Los scripts asumen permisos para `CREATE DATABASE`. Si tu cuenta MySQL no los tiene, pedirle a un admin que cree `granja_db` y ajustar el primer `USE` de cada script.
