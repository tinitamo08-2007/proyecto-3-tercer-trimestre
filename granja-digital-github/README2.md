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


## COMO EJECUTAR EL PROYECTO


**1. Clonar el repositorio

-- git clone https://github.com/tinitamo08-2007/proyecto-3-tercer-trimestre.git


**2. Abrir el proyecto en Eclipse

1-Abrir Eclipse.

2-Ir a:
File -> Open Projects from File System...
Archivo -> Abrir projecto archivos de sistema....

3-Seleccionar la carpeta:
--granja-digital-github/app


**3. Configurar la base de datos MySQL

1-Crear la base de datos:

--CREATE DATABASE granja_digital;

2-Ejecutar los scripts SQL incluidos en:

--database/scripts/


**4. Configurar conexión MySQL

**Editar el archivo:**

config.properties

**Configuración:**

db.url=jdbc:mysql://localhost:3306/granja_digital
db.usuario=root
db.clave=tu_password


**5. Ejecutar el proyecto

**Buscar la clase principal:**

Principal.java

**Ejecutar como:**

Run As → Java Application

**🛠️ Tecnologías utilizadas**

-Java

-MySQL

-Eclipse IDE

-Maven
