# Granja Digital — Proyecto 3 · Tercer Trimestre

Sistema de gestión para una explotación ganadera desarrollado de forma interdisciplinar entre las asignaturas de **Programación**, **Bases de Datos**, **Sistemas Informáticos** y **Lenguaje de Marcas**.

Permite registrar y consultar animales, empleados y actividades diarias a través de una aplicación de consola en Java y una aplicación web con Node.js, ambas conectadas a la misma base de datos MySQL.

---

## Integrantes del equipo

| Nombre    | Rama de trabajo     | Módulo                         |
|-----------|---------------------|--------------------------------|
| Valentina | `rama_valentina`    | Aplicación Java                |
| Juan      | `rama_juan`         | Base de Datos                  |
| César     | `Rama_César`        | Aplicación Web                 |
| Alejandro | `Rama_Alejandro`    | Aplicación Java / Integración  |
| Stefan    | `Rama_Stefan`       | Sistemas Informáticos (Docker) |

---

## Estructura del repositorio

```
proyecto-3-tercer-trimestre/
│
├── granja-digital-github/               ← Módulo Java (Programación)
│   └── app/
│       ├── pom.xml                      ← Dependencias Maven
│       ├── config.properties.example    ← Plantilla de credenciales (sin secretos)
│       └── src/granja/
│           ├── controlador/             ← Principal.java · ControladorGranja.java
│           ├── modelo/                  ← Animal · Empleado · Actividad · enums
│           ├── dao/                     ← AnimalDAO · EmpleadoDAO · ActividadDAO · ConexionBD
│           ├── vista/                   ← VistaConsola.java
│           ├── util/                    ← RegistroLog · CopiaSeguridadUtil · Exportadores
│           └── excepciones/             ← DatoInvalidoException · RegistroNoEncontradoException
│
├── database/                            ← Módulo Base de Datos
│   ├── scripts/
│   │   ├── script_creacion.sql          ← Crea tablas en MySQL local
│   │   ├── script_creacion_aiven.sql    ← Crea tablas + datos en Aiven
│   │   └── script_datos_ejemplo.sql     ← Inserta datos de prueba
│   ├── consultas/
│   │   └── consultas.sql               ← 12 consultas documentadas
│   ├── diagrams/
│   │   ├── diagrama_er.png/svg          ← Diagrama Entidad/Relación
│   │   ├── diagrama_relacional.png/svg  ← Esquema Relacional
│   │   └── diagrama_normalizacion.png/svg
│   └── docs/
│       ├── Memoria_BD_GranjaDigital.docx
│       └── Normalizacion_explicacion.md
│
├── granja-web/                          ← Módulo Web (Lenguaje de Marcas)
│   ├── server.js                        ← Servidor Express + API REST
│   ├── package.json
│   └── public/
│       ├── index.html                   ← Frontend (Inicio · Información · Consultas)
│       ├── css/style.css
│       └── js/main.js
│
├── docker_db/                   ← Módulo Docker (Sistemas Informáticos)
│   ├── Dockerfile                       ← Imagen MySQL personalizada
│   ├── docker-compose.yml               ← Servicios, volúmenes y red
│   ├── .env                            
│   └── mysql_data/                      ← Datos persistentes en el host
│
└── README.md
```

---

## Módulo 1 — Aplicación Java

Aplicación de consola que gestiona la granja mediante menús interactivos. Usa el patrón **MVC con capa DAO** y se conecta a MySQL a través de JDBC.

### Requisitos previos

- Java 17 o superior
- Eclipse IDE (recomendado) o IntelliJ IDEA
- MySQL 8.x en ejecución
- Maven (incluido en Eclipse)

### Cómo ejecutar

**1. Clonar el repositorio**
```bash
git clone https://github.com/tinitamo08-2007/proyecto-3-tercer-trimestre.git
```

**2. Crear la base de datos** (ver Módulo 2 más abajo)

**3. Configurar la conexión a la BD**

Copia el archivo de ejemplo y edítalo con tus credenciales:
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
File → Open Projects from File System
Seleccionar la carpeta: granja-digital-github/app
```

**5. Ejecutar**
```
Clic derecho en Principal.java → Run As → Java Application
```

### Funcionalidades

- Alta, edición, baja y cambio de estado de animales
- Gestión de empleados por rol (veterinario, peón, encargado)
- Registro de actividades diarias con empleado y animales involucrados
- Log automático de todas las acciones en `registros/aplicacion.log`
- Copia de seguridad del estado del sistema
- Exportación de datos a Excel (Apache POI) y PDF (iText)
- Validación de datos con excepciones personalizadas
- Conexión segura a BD con `try-with-resources`

### Dependencias Maven

| Librería            | Versión   | Uso                   |
|---------------------|-----------|-----------------------|
| `mysql-connector-j` | 9.0.0     | Conexión JDBC a MySQL |
| `poi` + `poi-ooxml` | 5.2.5     | Exportación a Excel   |
| `itextpdf`          | 5.5.13.3  | Exportación a PDF     |

---

## Módulo 2 — Base de Datos

Diseño completo del modelo relacional normalizado hasta **3FN**.

### Tablas del esquema

| Tabla               | Descripción                                             |
|---------------------|---------------------------------------------------------|
| `empleado`          | Personal de la granja (veterinario, peón, encargado...) |
| `animal`            | Animales con especie, raza, identificador y estado      |
| `actividad`         | Tareas diarias con fecha, hora y tipo (ENUM)            |
| `actividad_animal`  | Relación N:M entre actividades y animales               |
| `vista_actividades` | Vista con JOIN de actividad + empleado + animales       |

### Cómo crear la base de datos

Opción A — MySQL local:
```sql
source database/scripts/script_creacion.sql
source database/scripts/script_datos_ejemplo.sql
```

Opción B — Aiven (nube):
```sql
source database/scripts/script_creacion_aiven.sql
```

### Documentación del diseño

Toda la documentación está en `database/docs/` y `database/diagrams/`:

- Diagrama E/R — entidades, atributos y relaciones
- Esquema relacional — tablas con claves primarias y foráneas
- Normalización — proceso paso a paso de 0FN a 3FN (ver también `Normalizacion_explicacion.md`)
- 12 consultas documentadas en `database/consultas/consultas.sql`, usables desde Java y desde la web

---

## Módulo 3 — Aplicación Web

Aplicación web que consulta la BD en tiempo real a través de una API REST con Node.js y Express. Si MySQL no está disponible, funciona automáticamente con datos de demostración.

### Requisitos previos

- Node.js v18 o superior — https://nodejs.org

### Cómo ejecutar

**1. Instalar dependencias**
```bash
cd granja-web
npm install
```

**2. Configurar la contraseña de la BD**

Abre `granja-web/server.js` y sustituye el valor de `password` por la contraseña real de Aiven. No subir la contraseña real al repositorio; usar una variable de entorno.

**3. Arrancar el servidor**
```bash
node server.js
```

Para desarrollo con recarga automática:
```bash
npm run dev
```

**4. Abrir en el navegador**
```
http://localhost:3000
```

### Secciones de la aplicación

| Sección     | Contenido                                                                       |
|-------------|---------------------------------------------------------------------------------|
| Inicio      | Estadísticas en tiempo real: total de animales, sanos, empleados y actividades  |
| Información | Tablas de animales, empleados y actividades cargadas desde MySQL                |
| Consultas   | Formulario con validaciones para filtrar por especie, rol, fecha o estado       |

### API REST

| Método | Ruta                | Descripción                                  |
|--------|---------------------|----------------------------------------------|
| `GET`  | `/api/animales`     | Todos los animales                           |
| `GET`  | `/api/empleados`    | Todos los empleados                          |
| `GET`  | `/api/actividades`  | Actividades con JOIN via `vista_actividades` |
| `GET`  | `/api/stats`        | Totales generales                            |
| `POST` | `/api/consulta`     | Consulta filtrada por tipo y valor           |

### Tecnologías

- HTML5 · CSS3 · Bootstrap 5 · JavaScript (Fetch API)
- Node.js · Express.js · mysql2

---

## Módulo 4 — Sistemas Informáticos (Docker)

Dockerización de la base de datos MySQL con persistencia en el sistema físico mediante volúmenes. El objetivo es que cualquier miembro del equipo pueda levantar la BD con dos comandos, sin tener MySQL instalado localmente.

**Responsable:** Stefan (`Rama_Stefan`)

### Estructura del módulo

| Archivo              | Descripción                                             |
|----------------------|---------------------------------------------------------|
| `Dockerfile`         | Imagen personalizada basada en `mysql:8.0`              |
| `docker-compose.yml` | Orquesta el servicio, puertos, volúmenes y red          |
| `.env`               | Variables de entorno con credenciales (no subir al repo)|
| `mysql_data/`        | Carpeta del host donde MySQL guarda los datos reales    |

### Requisitos previos

- Docker instalado
- Docker Compose instalado

En Windows 11, activar WSL2 antes de instalar Docker Desktop:
```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2
wsl --install -d Ubuntu-24.04
```

### Cómo desplegar

**1. Entrar en la carpeta del módulo**
```bash
cd mi-proyecto-mysql
```

**2. Crear el archivo `.env`** con las credenciales (este archivo no se sube al repositorio):
```env
MYSQL_DATABASE=granja
MYSQL_USER=usuario
MYSQL_PASSWORD=contrasena_segura
MYSQL_ROOT_PASSWORD=contrasena_root_segura
```

**3. Construir la imagen y levantar el contenedor**
```bash
docker compose up -d --build
```

**4. Comprobar que está corriendo**
```bash
docker ps
```

**5. Ver los logs en directo** (opcional)
```bash
docker logs -f mi_mysql
```

**6. Conectar desde MySQL Workbench**
```
Host: 127.0.0.1   Puerto: 3306
Usuario: usuario  Contraseña: contrasena_segura
```

**7. Entrar a MySQL desde dentro del contenedor**
```bash
docker exec -it mi_mysql mysql -u usuario -p
```

Una vez dentro, ejecutar los scripts del Módulo 2 para crear las tablas y cargar los datos de ejemplo.

### Comandos de mantenimiento

```bash
# Bajar el contenedor conservando los datos
docker compose down

# Bajar el contenedor y borrar todos los datos
docker compose down -v

# Reiniciar el contenedor
docker compose restart
```

### Ventajas de este enfoque

- **Portabilidad** — el mismo `docker-compose.yml` funciona en Windows, Linux y macOS
- **Aislamiento** — la BD vive en el contenedor sin modificar el sistema operativo
- **Persistencia** — los datos se guardan en `mysql_data/` aunque se elimine el contenedor
- **Reproducibilidad** — cualquier miembro del equipo levanta la misma BD en segundos

---

## Ramas de GitHub

| Rama             | Propósito                                |
|------------------|------------------------------------------|
| `main`           | Versión estable e integrada del proyecto |
| `rama_valentina` | Trabajo individual de Valentina          |
| `rama_juan`      | Trabajo individual de Juan               |
| `Rama_César`     | Trabajo individual de César              |
| `Rama_Alejandro` | Trabajo individual de Alejandro          |
| `Rama_Stefan`    | Dockerización de la BD (Módulo 4)        |
