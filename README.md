# MySQL Dockerizado con persistencia en Host
## Estructura del proyecto
- `Dockerfile` Definición de la imagen
- `docker-compose.yml` Configuración del servicio
- `.env` Variables de entorno (contraseña y usuario)
- `mysql_data/` Carpeta donde se guardan los datos reales

## Cómo desplegar (Paso a paso)

### 1. Requisitos
- Docker instalado
- Docker Compose instalado

### 2. Despliegue

```bash
# Entrar en la carpeta del proyecto
cd mi-proyecto-mysql

# Levantar el contenedor (primera vez)
docker compose up -d --build

### 3. Acceso a la Base de Datos
```bash
docker exec -it mi_mysql mysql -u root -p
