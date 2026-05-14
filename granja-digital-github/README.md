🐄 Granja Digital

Proyecto de programación desarrollado en Java y MySQL para la gestión de una granja digital.


____¡Cómo ejecutar el proyecto!_____

1. Clonar el repositorio

-- git clone https://github.com/tinitamo08-2007/proyecto-3-tercer-trimestre.git


2. Abrir el proyecto en Eclipse

1-Abrir Eclipse.

2-Ir a:
File -> Open Projects from File System...
Archivo -> Abrir projecto archivos de sistema....

3-Seleccionar la carpeta:
--granja-digital-github/app


3. Configurar la base de datos MySQL

1-Crear la base de datos:

--CREATE DATABASE granja_digital;

2-Ejecutar los scripts SQL incluidos en:

--database/scripts/


4. Configurar conexión MySQL

**Editar el archivo:**

config.properties

**Configuración:**

db.url=jdbc:mysql://localhost:3306/granja_digital
db.usuario=root
db.clave=tu_password


5. Ejecutar el proyecto

**Buscar la clase principal:**

Principal.java

**Ejecutar como:**

Run As → Java Application

**🛠️ Tecnologías utilizadas**

-Java

-MySQL

-Eclipse IDE

-Maven
