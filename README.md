# Proyecto 3 · Tercer Trimestre — Granja Digital

Sistema de gestión para una granja digital desarrollado de forma interdisciplinar entre las asignaturas de **Programación**, **Bases de Datos**, **Sistemas Informáticos** y **Lenguaje de Marcas**.

Permite registrar y consultar animales, empleados y actividades diarias a través de una aplicación de consola en Java y una aplicación web con Node.js, ambas conectadas a la misma base de datos MySQL.

---

## Integrantes del equipo

| Nombre | Rama de trabajo |
|--------|----------------|
| Valentina | `rama_valentina` |
| Juan | `rama_juan` |

---

## Estructura del repositorio

```
proyecto-3-tercer-trimestre/
│
├── granja-digital-github/          ← Módulo Java (Programación + BD)
│   ├── app/
│   │   └── src/granja/
│   │       ├── controlador/        ← Principal.java, ControladorGranja.java
│   │       ├── modelo/             ← Animal, Empleado, Actividad, enums
│   │       ├── dao/                ← AnimalDAO, EmpleadoDAO, ActividadDAO, ConexionBD
│   │       ├── vista/              ← VistaConsola.java
│   │       ├── util/               ← RegistroLog, CopiaSeguridadUtil, Exportadores...
│   │       └── excepciones/        ← DatoInvalidoException, RegistroNoEncontradoException
│   ├── database/
│   │   ├── scripts/                ← SQL de creación e inserción de datos
│   │   ├── consultas/              ← 12 consultas documentadas
│   │   └── diagrams/               ← Diagramas E/R, Relacional y Normalización
│   └── docs/                       ← Memorias y explicación de normalización
│
├── granja-web/                     ← Módulo Web (Lenguaje de Marcas)
│   ├── server.js                   ← Servidor Express + API REST
│   ├── package.json
│   └── public/
│       ├── index.html              ← Frontend (Inicio, Información, Consultas)
│       ├── css/style.css
│       └── js/main.js
│
└── README.md                       ← Este archivo
```

---

## Módulo 1 — Aplicación Java (Programación + Base de Datos)

Aplicación de consola que gestiona la granja mediante menús interactivos. Conecta con MySQL usando JDBC y sigue el patrón MVC con capa DAO.

### Requisitos

- Java 17 o superior
- Eclipse IDE (recomendado) o IntelliJ
- MySQL 8.x en ejecución (local o Aiven)
- Maven (incluido en Eclipse)

### Pasos para ejecutar

**1. Clonar el repositorio**
```bash
git clone https://github.com/tinitamo08-2007/proyecto-3-tercer-trimestre.git
```

**2. Crear la base de datos**

Abre MySQL Workbench y ejecuta en este orden:
```
granja-digital-github/database/scripts/script_creacion.sql
granja-digital-github/database/scripts/script_datos_ejemplo.sql
```
> Para Aiven basta con ejecutar `script_creacion_aiven.sql`, que incluye los datos de ejemplo.

**3. Configurar la conexión**

Copia el archivo de ejemplo y edítalo con tus datos:
```bash
cp granja-digital-github/app/config.properties.example granja-digital-github/app/config.properties
```
```properties
db.url=jdbc:mysql://localhost:3306/granja
db.usuario=root
db.clave=tu_contraseña
```

**4. Abrir en Eclipse**
```
File → Open Projects from File System → selecciona la carpeta granja-digital-github/app
```

**5. Ejecutar**
```
Clic derecho en Principal.java → Run As → Java Application
```

### Funcionalidades

- Gestión completa de animales (alta, edición, baja, cambio de estado)
- Gestión de empleados (veterinarios, peones, encargados)
- Registro de actividades diarias (ordeño, vacunación, alimentación, limpieza)
- Asociación N:M entre actividades y animales
- Log de todas las acciones en `registros/aplicacion.log`
- Copias de seguridad del estado del sistema
- Exportación de datos a Excel y PDF
- Validación de datos y excepciones personalizadas
- Conexión a BD mediante JDBC con `try-with-resources`

### Tecnologías

- Java 17 · JDBC · MySQL Connector/J
- Maven · Eclipse IDE
- Apache POI (Excel) · iText (PDF)

---

## Módulo 2 — Base de Datos

Diseño completo del modelo relacional, normalizado hasta 3FN.

### Esquema de tablas

| Tabla | Descripción |
|-------|-------------|
| `empleado` | Personal de la granja (veterinario, peón, encargado...) |
| `animal` | Animales registrados con especie, raza, identificador y estado |
| `actividad` | Tareas diarias con fecha, hora y tipo (ENUM) |
| `actividad_animal` | Tabla puente N:M entre actividades y animales |
| `usuario` | Autenticación básica de administradores |
| `vista_actividades` | Vista con JOIN de actividad + empleado + animales |

### Archivos de base de datos

```
granja-digital-github/database/
├── scripts/
│   ├── script_creacion.sql         ← Crea BD y tablas (MySQL local)
│   ├── script_creacion_aiven.sql   ← Crea BD y tablas + datos (Aiven)
│   └── script_datos_ejemplo.sql    ← Inserta datos de prueba
├── consultas/
│   └── consultas.sql               ← 12 consultas documentadas
└── diagrams/
    ├── diagrama_er.png             ← Diagrama Entidad/Relación
    ├── diagrama_relacional.png     ← Esquema Relacional
    └── diagrama_normalizacion.png  ← Proceso de normalización 0FN → 3FN
```

La explicación detallada del proceso de normalización está en:
`granja-digital-github/docs/Normalizacion_explicacion.md`

---

## Módulo 3 — Aplicación Web (Lenguaje de Marcas)

Aplicación web que consulta la base de datos en tiempo real mediante una API REST con Node.js y Express. Si no hay conexión a MySQL, funciona con datos de demostración.

### Requisitos

- Node.js v18 o superior

### Pasos para ejecutar

**1. Instalar dependencias**
```bash
cd granja-web
npm install
```

**2. Configurar contraseña de BD**

Edita `server.js` y sustituye el valor de `password` con la contraseña real de Aiven.

**3. Arrancar el servidor**
```bash
node server.js
```

**4. Abrir en el navegador**
```
http://localhost:3000
```

### Secciones de la aplicación

- **Inicio** — estadísticas generales en tiempo real (animales, empleados, actividades)
- **Información** — tablas de animales, empleados y actividades cargadas desde MySQL
- **Consultas** — formulario con validaciones para filtrar datos por especie, rol, fecha o estado de salud

### API REST

| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/api/animales` | Listado de animales |
| `GET` | `/api/empleados` | Listado de empleados |
| `GET` | `/api/actividades` | Actividades con JOIN (vía `vista_actividades`) |
| `GET` | `/api/stats` | Totales generales |
| `POST` | `/api/consulta` | Consulta filtrada por tipo y valor |

### Tecnologías

- HTML5 · CSS3 · Bootstrap 5 · JavaScript
- Node.js · Express.js · mysql2

---

## Módulo 4 — Sistemas Informáticos (Docker)

> 🔧 En desarrollo

Dockerización de la base de datos con persistencia en el sistema físico mediante volúmenes Docker.

---

## Ramas de GitHub

| Rama | Uso |
|------|-----|
| `main` | Versión estable del proyecto |
| `rama_juan` | Trabajo individual de Juan |
| `rama_valentina` | Trabajo individual de Valentina |

---

## Documentación

Las memorias del proyecto se encuentran en:

```
granja-digital-github/docs/
├── Memoria_General_GranjaDigital.docx   ← Memoria global del proyecto
├── Memoria_BD_GranjaDigital.docx        ← Memoria específica de base de datos
└── Normalizacion_explicacion.md         ← Proceso de normalización paso a paso
```