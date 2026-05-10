
# proyecto-2-trimestre-lenguaje-de-marcas-node.js# Proyecto 3 · Comunicación con Base de Datos
## Aplicación Web — Rebelión en la Granja

> **Tecnologías:** HTML5 · CSS3 · JavaScript · Node.js · Express.js · MySQL  

---

##  Estructura del Proyecto

```
granja-web/
├── server.js          ← Servidor Express + conexión MySQL
├── package.json       ← Dependencias npm
├── README.md          ← Esta documentación
└── public/
    ├── css/
    |   └── style.css
    ├── css/
    |   └── main.js
    |
    └── index.html     ← Frontend (HTML + CSS + JS)
    └── 404.html     

```

---

##  Requisitos Previos

- **Node.js** v18 o superior → https://nodejs.org
- **MySQL** en ejecución con la base de datos `granja` creada (script SQL del proyecto Java)

---

##  Instalación y Puesta en Marcha

### 1. Instalar dependencias

```bash
npm install
```

| Paquete | Versión | Uso |
|---|---|---|
| `express` | ^4.18 | Servidor HTTP y enrutamiento |
| `mysql2`  | ^3.9  | Conexión a MySQL  |
| `cors`    | ^2.8  | Cabeceras CORS |
| `nodemon` | ^3.0  | Recarga automática  |

### 2. Configurar la conexión a MySQL

Copia el fichero `.env.example` y renómbralo a `.env`:

```bash
cp .env.example .env
```

Edita `.env` con tus datos:

```
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=tu_contraseña
DB_NAME=granja
PORT=3000
```

> Si no usas `.env`, puedes cambiar directamente los valores por defecto en `server.js` dentro del objeto `DB_CONFIG`.

### 3. Arrancar el servidor

```bash
node server.js
```

Para desarrollo con recarga automática:
```bash
npm run dev
```

### 4. Abrir en el navegador

```
http://localhost:3000
```

> Si MySQL no está disponible, la app funciona automáticamente con **datos de demostración** .

---

##  Secciones de la Aplicación

### 1. Inicio
Estadísticas en tiempo real desde MySQL: total de animales, animales sanos, empleados y actividades registradas. Tarjetas descriptivas de cada módulo.

### 2. Mostrar Información
Tres pestañas que cargan datos directamente de MySQL:
- **Animales** — especie, raza, identificador, estado de salud con badges de color, ubicación
- **Empleados** — nombre, rol, teléfono, fecha de contratación
- **Actividades** — fecha, hora, tipo, empleado responsable y animales involucrados (JOIN)

### 3. Realizar Consultas
Formulario con validaciones para filtrar datos de MySQL:
- Tipo de consulta obligatorio (lista blanca de 4 opciones)
- Filtro opcional con validación de caracteres
- Resultados en tabla con total de registros encontrados

---

##  API REST — Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET`  | `/api/animales`   | Todos los animales |
| `GET`  | `/api/empleados`  | Todos los empleados |
| `GET`  | `/api/actividades`| Actividades con JOIN de empleados y animales |
| `GET`  | `/api/stats`      | Totales generales |
| `POST` | `/api/consulta`   | Consulta filtrada |

### Body del POST `/api/consulta`
```json
{
  "tipo": "animales_especie",
  "filtro": "Bovino"
}
```

| `tipo` | Consulta SQL ejecutada |
|--------|------------------------|
| `animales_especie`  | `SELECT * FROM animales WHERE especie = ?` |
| `empleados_rol`     | `SELECT * FROM empleados WHERE rol = ?` |
| `actividades_fecha` | `SELECT * FROM actividades WHERE fecha = ?` |
| `animales_salud`    | `SELECT * FROM animales WHERE estado_salud = ?` |

---

##  Tecnologías de Marcas Utilizadas

### HTML5
- Estructura: `<header>`, `<nav>`, `<section>`, `<table>`
- Formularios con `<select>`, `<input>` y validación en cliente
- Metaetiquetas para charset y viewport responsive

### CSS3
- **Variables CSS** (`--meadow`, `--bark`, `--straw`…) para theming global
- **CSS Grid** y **Flexbox** para layouts adaptativos
- **Animaciones** `@keyframes` para el spinner de carga
- **Media queries** con breakpoint en 768px para móvil
- Google Fonts: *Lora* (títulos), *DM Mono* (datos), *Nunito* (cuerpo)

### JavaScript
- **Fetch API** (`async/await`) para peticiones al servidor
- Validación de formularios en cliente antes de enviar

### Node.js + Express
- Servidor HTTP con `express`
- Middlewares: `express.json()`, `cors()`, `express.static()`
- Manejo de errores con `try/catch` en todas las rutas

---

##  Seguridad

1. **Validación cliente**: tipo obligatorio + filtro sin caracteres (`'`, `"`, `;`, `<`, `>`, `\`)
2. **Lista blanca de consultas**: el servidor rechaza cualquier tipo no definido en `PERMITIDAS`

---

##  Capturas de Pantalla

---

##  Repositorio GitHub


Ramas:
- `master` → versión estable

