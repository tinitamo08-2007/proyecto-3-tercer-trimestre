-- MySQL dump 10.13  Distrib 8.4.9, for Linux (x86_64)
--
-- Host: granja-mysql-granjamysql.j.aivencloud.com    Database: granja
-- ------------------------------------------------------
-- Server version	8.4.8

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '6d594a24-4d16-11f1-844c-0ef3ab91c64a:1-100,
d6b33fe9-4dec-11f1-871e-aee1746c10d8:1-87';

--
-- Table structure for table `actividad`
--

DROP TABLE IF EXISTS `actividad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `actividad` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `tipo` enum('ORDENIE','ALIMENTACION','VACUNACION','LIMPIEZA','OTRA') COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_empleado` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_empleado` (`id_empleado`),
  KEY `idx_actividad_fecha` (`fecha`),
  KEY `idx_actividad_tipo` (`tipo`),
  CONSTRAINT `actividad_ibfk_1` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actividad`
--

LOCK TABLES `actividad` WRITE;
/*!40000 ALTER TABLE `actividad` DISABLE KEYS */;
INSERT INTO `actividad` VALUES (1,'2026-05-10','06:30:00','ORDENIE','Ordeñe matutino del corral 1',2),(2,'2026-05-10','08:00:00','ALIMENTACION','Pienso a corrales 1 y 2',2),(3,'2026-05-10','10:15:00','VACUNACION','Refuerzo antiparasitario',1),(4,'2026-05-10','17:30:00','LIMPIEZA','Limpieza del gallinero',4),(5,'2026-05-11','06:30:00','ORDENIE','Ordeñe matutino del corral 1',2),(6,'2026-05-12','07:00:00','ALIMENTACION','Pienso matutino general',2),(7,'2026-05-12','11:00:00','LIMPIEZA','Limpieza corrales 1 y 2',3);
/*!40000 ALTER TABLE `actividad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `actividad_animal`
--

DROP TABLE IF EXISTS `actividad_animal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `actividad_animal` (
  `id_actividad` int NOT NULL,
  `id_animal` int NOT NULL,
  PRIMARY KEY (`id_actividad`,`id_animal`),
  KEY `id_animal` (`id_animal`),
  CONSTRAINT `actividad_animal_ibfk_1` FOREIGN KEY (`id_actividad`) REFERENCES `actividad` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `actividad_animal_ibfk_2` FOREIGN KEY (`id_animal`) REFERENCES `animal` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actividad_animal`
--

LOCK TABLES `actividad_animal` WRITE;
/*!40000 ALTER TABLE `actividad_animal` DISABLE KEYS */;
INSERT INTO `actividad_animal` VALUES (1,1),(2,1),(5,1),(6,1),(7,1),(1,2),(2,2),(5,2),(6,2),(7,2),(2,3),(6,3),(3,5),(4,7);
/*!40000 ALTER TABLE `actividad_animal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `animal`
--

DROP TABLE IF EXISTS `animal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `animal` (
  `id` int NOT NULL AUTO_INCREMENT,
  `especie` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `raza` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `identificador` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado_salud` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'buena',
  `ubicacion` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` enum('ACTIVO','VENDIDO','FALLECIDO','TRASLADADO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVO',
  PRIMARY KEY (`id`),
  UNIQUE KEY `identificador` (`identificador`),
  KEY `idx_animal_especie` (`especie`),
  KEY `idx_animal_estado` (`estado`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `animal`
--

LOCK TABLES `animal` WRITE;
/*!40000 ALTER TABLE `animal` DISABLE KEYS */;
INSERT INTO `animal` VALUES (1,'vaca','Holstein','2022-05-12','ARETE-001','buena','Corral 1','ACTIVO'),(2,'vaca','Pirenaica','2021-11-23','ARETE-002','buena','Corral 1','ACTIVO'),(3,'vaca','Holstein','2023-04-05','ARETE-003','regular','Corral 2','ACTIVO'),(4,'oveja','Merina','2023-02-14','ARETE-101','buena','Potrero Norte','ACTIVO'),(5,'oveja','Latxa','2022-07-30','ARETE-102','grave','Enfermería','ACTIVO'),(6,'cerdo','Duroc','2024-01-09','CHIP-201','buena','Corral 3','ACTIVO'),(7,'gallina','Castellana negra','2024-03-18','ANILLA-301','buena','Gallinero','ACTIVO'),(8,'caballo','Pura Sangre','2020-08-10','CHIP-501','buena','Establo 1','ACTIVO'),(9,'cabra','Murciana','2023-05-22','ARETE-201','buena','Potrero Norte','ACTIVO');
/*!40000 ALTER TABLE `animal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empleado`
--

DROP TABLE IF EXISTS `empleado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empleado` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_contratacion` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empleado`
--

LOCK TABLES `empleado` WRITE;
/*!40000 ALTER TABLE `empleado` DISABLE KEYS */;
INSERT INTO `empleado` VALUES (1,'María López','veterinario','666111222','2022-04-15'),(2,'Juan Pérez','peon','655234567','2023-09-01'),(3,'Lucía Fernández','encargado','644555888','2021-01-10'),(4,'Carlos Romero','peon','633998877','2024-02-20'),(5,'Sofia Ruiz','veterinario','611222333','2023-06-01');
/*!40000 ALTER TABLE `empleado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `clave_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` enum('ADMIN','OPERADOR') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OPERADOR',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'admin','pendiente_de_hash','ADMIN',1);
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vista_actividades`
--

DROP TABLE IF EXISTS `vista_actividades`;
/*!50001 DROP VIEW IF EXISTS `vista_actividades`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_actividades` AS SELECT 
 1 AS `id`,
 1 AS `fecha`,
 1 AS `hora`,
 1 AS `tipo`,
 1 AS `descripcion`,
 1 AS `id_empleado`,
 1 AS `empleado`,
 1 AS `animales`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'granja'
--

--
-- Final view structure for view `vista_actividades`
--

/*!50001 DROP VIEW IF EXISTS `vista_actividades`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`avnadmin`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_actividades` AS select `a`.`id` AS `id`,`a`.`fecha` AS `fecha`,`a`.`hora` AS `hora`,`a`.`tipo` AS `tipo`,`a`.`descripcion` AS `descripcion`,`a`.`id_empleado` AS `id_empleado`,`e`.`nombre` AS `empleado`,group_concat(`an`.`identificador` order by `an`.`identificador` ASC separator ', ') AS `animales` from (((`actividad` `a` left join `empleado` `e` on((`a`.`id_empleado` = `e`.`id`))) left join `actividad_animal` `aa` on((`aa`.`id_actividad` = `a`.`id`))) left join `animal` `an` on((`aa`.`id_animal` = `an`.`id`))) group by `a`.`id`,`a`.`fecha`,`a`.`hora`,`a`.`tipo`,`a`.`descripcion`,`a`.`id_empleado`,`e`.`nombre` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-17 12:34:51
