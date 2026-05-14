# 🐄 Granja Digital

Sistema integral de gestión para una explotación ganadera. Proyecto integrado de **1.º DAM** (Programación + Bases de Datos).

Permite registrar y consultar **animales, empleados y actividades diarias**, con persistencia en MySQL, logs en archivo y exportación a CSV, Excel y PDF.

---

## 🛠️ Stack técnico

| Capa | Tecnología |
|---|---|
| Lenguaje | Java 21 (JavaSE-21) |
| IDE | Eclipse IDE |
| Base de datos | MySQL 8.x (probado en local y Aiven) |
| Driver | mysql-connector-j 9.0.0 |
| Excel | Apache POI 5.2.5 |
| PDF | iText 5.5.13 |
| Build | Manual (lib/) o Maven (pom.xml) |

---

## Estructura del repositorio

```
granja-digital/
├── app/                     Aplicación Java
│   ├── src/granja/
│   │   ├── controlador/     Principal y ControladorGranja
│   │   ├── dao/             ConexionBD, AnimalDAO, EmpleadoDAO, ActividadDAO
│   │   ├── modelo/          POJOs (Animal, Empleado, Actividad, enums)
│   │   ├── excepciones/     Excepciones personalizadas
│   │   ├── util/            Logs, copias, validador, exportadores
│   │   └── vista/           VistaConsola
│   ├── lib/                 (vacío; se llena con descargar_librerias.bat)
│   ├── config.properties.example
│   ├── descargar_librerias.bat / .ps1
│   ├── pom.xml              Alternativa Maven
│   └── .classpath, .project Configuración Eclipse
├── database/
│   ├── scripts/             *.sql (creación + datos de ejemplo)
│   ├── consultas/           consultas.sql (12 consultas reutilizables)
│   └── diagrams/            E/R, relacional, normalización (SVG + PNG)
├── docs/
│   ├── Memoria_General_GranjaDigital.docx
│   ├── Memoria_BD_GranjaDigital.docx
│   └── Normalizacion_explicacion.md
├── .gitignore
├── LICENSE
└── README.md
```

---

## Cómo ejecutarlo

### 1. Importar el proyecto en Eclipse
`File → Open Projects from File System...` y selecciona la carpeta `app/`.

### 2. Descargar las 16 librerías
Doble clic en `app/descargar_librerias.bat`. Las descarga automáticamente a `app/lib/`.

> Si Windows bloquea PowerShell, abre PowerShell como administrador y ejecuta `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

### 3. Crear la base de datos
Abre **MySQL Workbench** y ejecuta:

```bash
mysql -u root -p < database/scripts/script_creacion.sql
mysql -u root -p granja_digital < database/scripts/script_datos_ejemplo.sql
```

O usa la variante para Aiven (`script_creacion_aiven.sql`) si trabajas en la nube.

### 4. Configurar credenciales
Copia `app/config.properties.example` a `app/config.properties` y edita:

```properties
db.url=jdbc:mysql://localhost:3306/granja_digital?useSSL=false&serverTimezone=UTC
db.usuario=root
db.clave=TU_PASSWORD_AQUI
```

> El archivo `config.properties` está en `.gitignore` para que nunca subas credenciales reales.

### 5. Ejecutar
Botón derecho sobre `Principal.java` → `Run As → Java Application`. Aparece el menú principal con 7 opciones.

---

## Diseño de la base de datos

4 tablas en **3FN**: `empleado`, `animal`, `actividad`, `actividad_animal`. Una relación 1:N (empleado → actividad) y una N:M (actividad ↔ animal) resuelta con tabla intermedia.

| Diagrama | Archivo |
|---|---|
| Entidad/Relación | [database/diagrams/diagrama_er.png](database/diagrams/diagrama_er.png) |
| Relacional con PK/FK | [database/diagrams/diagrama_relacional.png](database/diagrams/diagrama_relacional.png) |
| Proceso de normalización | [database/diagrams/diagrama_normalizacion.png](database/diagrams/diagrama_normalizacion.png) |

La memoria completa (E/R, paso a relacional, 3FN, decisiones de diseño, scripts y consultas) está en `docs/Memoria_BD_GranjaDigital.docx`.

---

##  Funcionalidades

- ✅ CRUD completo de animales, empleados y actividades
- ✅ Cambio de estado del animal (VENDIDO / FALLECIDO / TRASLADADO)
- ✅ Reportes: animales por especie, actividades por fecha
- ✅ Logs en `registros/aplicacion.log` con nivel INFO/WARN/ERROR
- ✅ Respaldos diarios en CSV (3 archivos por día)
- ✅ Exportación a **Excel** (.xlsx) con Apache POI
- ✅ Exportación a **PDF** con iText
- ✅ Manejo de excepciones personalizadas (`DatoInvalidoException`, `RegistroNoEncontradoException`)
- ✅ Conexión configurable mediante `config.properties` (local o Aiven)

---

## 🔮 Versión Web (futura)

El esquema y las consultas SQL están preparados para alimentar una **futura versión web** Node.js/Express sin rediseñar la capa de datos. Ejemplo de endpoint:

```javascript
app.get('/api/animales', async (req, res) => {
  const [rows] = await db.query('SELECT * FROM animal ORDER BY id');
  res.json(rows);
});
```

---

##  Cumplimiento del enunciado

Todos los requisitos del enunciado están cubiertos (ver tabla en `docs/Memoria_General_GranjaDigital.docx`, sección 13). Incluye los siguientes extras:

- Exportación a Excel y PDF
- Reportes por consola

