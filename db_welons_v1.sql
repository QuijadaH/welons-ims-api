-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: db_welons_v1
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `color`
--

DROP TABLE IF EXISTS `color`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `color` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `color` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `color_value` (`color`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `color`
--

LOCK TABLES `color` WRITE;
/*!40000 ALTER TABLE `color` DISABLE KEYS */;
INSERT INTO `color` VALUES (2,'GRAY'),(1,'WHITE');
/*!40000 ALTER TABLE `color` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material`
--

DROP TABLE IF EXISTS `material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `material` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `qty` int(11) NOT NULL DEFAULT 0,
  `srp` decimal(12,2) NOT NULL DEFAULT 0.00,
  `desc` text DEFAULT NULL,
  `material_name_id` int(10) unsigned NOT NULL,
  `material_specs_id` int(10) unsigned DEFAULT NULL,
  `material_category_id` int(10) unsigned DEFAULT NULL,
  `material_unit_id` int(10) unsigned DEFAULT NULL,
  `material_remarks_id` int(10) unsigned DEFAULT NULL,
  `color_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `material_material_name_FK` (`material_name_id`),
  KEY `material_material_specs_FK` (`material_specs_id`),
  KEY `material_material_category_FK` (`material_category_id`),
  KEY `material_material_unit_FK` (`material_unit_id`),
  KEY `material_material_remarks_FK` (`material_remarks_id`),
  KEY `material_color_FK` (`color_id`),
  CONSTRAINT `material_color_FK` FOREIGN KEY (`color_id`) REFERENCES `color` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `material_material_category_FK` FOREIGN KEY (`material_category_id`) REFERENCES `material_category` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `material_material_name_FK` FOREIGN KEY (`material_name_id`) REFERENCES `material_name` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `material_material_remarks_FK` FOREIGN KEY (`material_remarks_id`) REFERENCES `material_remarks` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `material_material_specs_FK` FOREIGN KEY (`material_specs_id`) REFERENCES `material_specs` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `material_material_unit_FK` FOREIGN KEY (`material_unit_id`) REFERENCES `material_unit` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material`
--

LOCK TABLES `material` WRITE;
/*!40000 ALTER TABLE `material` DISABLE KEYS */;
INSERT INTO `material` VALUES (1,8,0.00,NULL,1,1,1,1,1,1),(2,69,0.00,NULL,6,4,1,1,NULL,2);
/*!40000 ALTER TABLE `material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material_category`
--

DROP TABLE IF EXISTS `material_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `material_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `material_category` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `material_category_value` (`material_category`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material_category`
--

LOCK TABLES `material_category` WRITE;
/*!40000 ALTER TABLE `material_category` DISABLE KEYS */;
INSERT INTO `material_category` VALUES (1,'MAINFRAME');
/*!40000 ALTER TABLE `material_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material_name`
--

DROP TABLE IF EXISTS `material_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `material_name` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `material_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `material_name_value` (`material_name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material_name`
--

LOCK TABLES `material_name` WRITE;
/*!40000 ALTER TABLE `material_name` DISABLE KEYS */;
INSERT INTO `material_name` VALUES (3,'BOTTOM LONG BEAM'),(2,'BOTTOM SHORT BEAM'),(7,'BOTTOM SQUARE TUBE'),(1,'COLUMN'),(6,'CONNECT'),(5,'TOP LONG BEAM'),(4,'TOP SHORT BEAM');
/*!40000 ALTER TABLE `material_name` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material_remarks`
--

DROP TABLE IF EXISTS `material_remarks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `material_remarks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `material_remarks` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `material_remarks_value` (`material_remarks`) USING HASH
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material_remarks`
--

LOCK TABLES `material_remarks` WRITE;
/*!40000 ALTER TABLE `material_remarks` DISABLE KEYS */;
INSERT INTO `material_remarks` VALUES (1,'GALVANIZED'),(2,'WITH SQUARE PIPE HEAD'),(3,'WITH U-SHAPED BAYONET');
/*!40000 ALTER TABLE `material_remarks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material_specs`
--

DROP TABLE IF EXISTS `material_specs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `material_specs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `material_specs` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `material_specs_value` (`material_specs`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material_specs`
--

LOCK TABLES `material_specs` WRITE;
/*!40000 ALTER TABLE `material_specs` DISABLE KEYS */;
INSERT INTO `material_specs` VALUES (1,'160*160*2480*2.3'),(4,'160*160*4.0'),(2,'160*2680*2.3'),(3,'160*5630*2.3');
/*!40000 ALTER TABLE `material_specs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material_unit`
--

DROP TABLE IF EXISTS `material_unit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `material_unit` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `material_unit` varchar(100) CHARACTER SET armscii8 COLLATE armscii8_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `material_unit_value` (`material_unit`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material_unit`
--

LOCK TABLES `material_unit` WRITE;
/*!40000 ALTER TABLE `material_unit` DISABLE KEYS */;
INSERT INTO `material_unit` VALUES (1,'PCS'),(2,'UNIT');
/*!40000 ALTER TABLE `material_unit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order`
--

DROP TABLE IF EXISTS `order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order` (
  `control_no` varchar(100) NOT NULL,
  `project_code` varchar(100) NOT NULL,
  `project_details` text DEFAULT NULL,
  `site_location` text NOT NULL,
  `overhead_cost` decimal(12,2) NOT NULL DEFAULT 0.00,
  `delivery_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `date_paid` date DEFAULT NULL,
  `dispatch_date` date DEFAULT NULL,
  `order_unit_status_id` int(10) unsigned NOT NULL,
  `order_status_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`control_no`),
  KEY `order_order_unit_status_FK` (`order_unit_status_id`),
  KEY `order_order_status_FK` (`order_status_id`),
  CONSTRAINT `order_order_status_FK` FOREIGN KEY (`order_status_id`) REFERENCES `order_status` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `order_order_unit_status_FK` FOREIGN KEY (`order_unit_status_id`) REFERENCES `order_unit_status` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order`
--

LOCK TABLES `order` WRITE;
/*!40000 ALTER TABLE `order` DISABLE KEYS */;
/*!40000 ALTER TABLE `order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_material_offset`
--

DROP TABLE IF EXISTS `order_material_offset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_material_offset` (
  `control_no` varchar(100) NOT NULL,
  `material_id` int(10) unsigned NOT NULL,
  `material_name` varchar(100) NOT NULL,
  `material_specs` varchar(100) DEFAULT NULL,
  `material_category` varchar(100) DEFAULT NULL,
  `material_unit` varchar(100) DEFAULT NULL,
  `material_remarks` varchar(100) DEFAULT NULL,
  `material_color` varchar(100) DEFAULT NULL,
  `unit_cost` decimal(12,2) NOT NULL DEFAULT 0.00,
  `quantity` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`control_no`,`material_id`),
  KEY `order_material_offset_material_FK` (`material_id`),
  CONSTRAINT `order_material_offset_material_FK` FOREIGN KEY (`material_id`) REFERENCES `material` (`id`),
  CONSTRAINT `order_material_offset_order_FK` FOREIGN KEY (`control_no`) REFERENCES `order` (`control_no`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_material_offset`
--

LOCK TABLES `order_material_offset` WRITE;
/*!40000 ALTER TABLE `order_material_offset` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_material_offset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_otherworks`
--

DROP TABLE IF EXISTS `order_otherworks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_otherworks` (
  `control_no` varchar(100) NOT NULL,
  `otherworks_id` int(10) unsigned NOT NULL,
  `otherworks_name` varchar(100) NOT NULL,
  `otherworks_category` varchar(100) DEFAULT NULL,
  `otherworks_unit` varchar(100) DEFAULT NULL,
  `unit_cost` decimal(12,2) NOT NULL DEFAULT 0.00,
  `material_qty_per_prefab` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`control_no`,`otherworks_id`),
  KEY `order_otherworks_otherworks_FK` (`otherworks_id`),
  CONSTRAINT `order_otherworks_order_FK` FOREIGN KEY (`control_no`) REFERENCES `order` (`control_no`) ON UPDATE CASCADE,
  CONSTRAINT `order_otherworks_otherworks_FK` FOREIGN KEY (`otherworks_id`) REFERENCES `otherworks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_otherworks`
--

LOCK TABLES `order_otherworks` WRITE;
/*!40000 ALTER TABLE `order_otherworks` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_otherworks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_prefab`
--

DROP TABLE IF EXISTS `order_prefab`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_prefab` (
  `control_no` varchar(100) NOT NULL,
  `prefab_id` int(10) unsigned NOT NULL,
  `prefab_name` varchar(100) NOT NULL,
  `prefab_specs` varchar(100) DEFAULT NULL,
  `prefab_color` varchar(100) DEFAULT NULL,
  `unit_cost` decimal(12,2) NOT NULL DEFAULT 0.00,
  `quantity` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`control_no`,`prefab_id`),
  KEY `order_prefab_prefab_FK` (`prefab_id`),
  CONSTRAINT `order_prefab_order_FK` FOREIGN KEY (`control_no`) REFERENCES `order` (`control_no`) ON UPDATE CASCADE,
  CONSTRAINT `order_prefab_prefab_FK` FOREIGN KEY (`prefab_id`) REFERENCES `prefab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_prefab`
--

LOCK TABLES `order_prefab` WRITE;
/*!40000 ALTER TABLE `order_prefab` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_prefab` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_prefab_material`
--

DROP TABLE IF EXISTS `order_prefab_material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_prefab_material` (
  `control_no` varchar(100) NOT NULL,
  `prefab_id` int(10) unsigned NOT NULL,
  `material_id` int(10) unsigned NOT NULL,
  `material_name` varchar(100) NOT NULL,
  `material_specs` varchar(100) DEFAULT NULL,
  `material_category` varchar(100) DEFAULT NULL,
  `material_unit` varchar(100) DEFAULT NULL,
  `material_remarks` varchar(100) DEFAULT NULL,
  `material_color` varchar(100) DEFAULT NULL,
  `unit_cost` decimal(12,2) NOT NULL DEFAULT 0.00,
  `material_qty_per_prefab` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`control_no`,`prefab_id`,`material_id`),
  KEY `order_prefab_material_prefab_material_FK` (`prefab_id`,`material_id`),
  CONSTRAINT `order_prefab_material_order_FK` FOREIGN KEY (`control_no`) REFERENCES `order` (`control_no`) ON UPDATE CASCADE,
  CONSTRAINT `order_prefab_material_prefab_material_FK` FOREIGN KEY (`prefab_id`, `material_id`) REFERENCES `prefab_material` (`prefab_id`, `material_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_prefab_material`
--

LOCK TABLES `order_prefab_material` WRITE;
/*!40000 ALTER TABLE `order_prefab_material` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_prefab_material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_status`
--

DROP TABLE IF EXISTS `order_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_status` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `order_status` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_status_value` (`order_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_status`
--

LOCK TABLES `order_status` WRITE;
/*!40000 ALTER TABLE `order_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_unit_status`
--

DROP TABLE IF EXISTS `order_unit_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_unit_status` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `order_unit_status` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_unit_status_value` (`order_unit_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_unit_status`
--

LOCK TABLES `order_unit_status` WRITE;
/*!40000 ALTER TABLE `order_unit_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_unit_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otherworks`
--

DROP TABLE IF EXISTS `otherworks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `otherworks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `unit_cost` decimal(12,2) NOT NULL DEFAULT 0.00,
  `desc` text DEFAULT NULL,
  `otherworks_name_id` int(10) unsigned NOT NULL,
  `otherworks_category_id` int(10) unsigned DEFAULT NULL,
  `otherworks_unit_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `otherworks_otherworks_name_FK` (`otherworks_name_id`),
  KEY `otherworks_otherworks_category_FK` (`otherworks_category_id`),
  KEY `otherworks_otherworks_unit_FK` (`otherworks_unit_id`),
  CONSTRAINT `otherworks_otherworks_category_FK` FOREIGN KEY (`otherworks_category_id`) REFERENCES `otherworks_category` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `otherworks_otherworks_name_FK` FOREIGN KEY (`otherworks_name_id`) REFERENCES `otherworks_name` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `otherworks_otherworks_unit_FK` FOREIGN KEY (`otherworks_unit_id`) REFERENCES `otherworks_unit` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otherworks`
--

LOCK TABLES `otherworks` WRITE;
/*!40000 ALTER TABLE `otherworks` DISABLE KEYS */;
/*!40000 ALTER TABLE `otherworks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otherworks_category`
--

DROP TABLE IF EXISTS `otherworks_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `otherworks_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `otherworks_category` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `otherworks_category_value` (`otherworks_category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otherworks_category`
--

LOCK TABLES `otherworks_category` WRITE;
/*!40000 ALTER TABLE `otherworks_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `otherworks_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otherworks_name`
--

DROP TABLE IF EXISTS `otherworks_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `otherworks_name` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `otherworks_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `otherworks_name_value` (`otherworks_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otherworks_name`
--

LOCK TABLES `otherworks_name` WRITE;
/*!40000 ALTER TABLE `otherworks_name` DISABLE KEYS */;
/*!40000 ALTER TABLE `otherworks_name` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otherworks_unit`
--

DROP TABLE IF EXISTS `otherworks_unit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `otherworks_unit` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `otherworks_unit` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `otherworks_unit_value` (`otherworks_unit`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otherworks_unit`
--

LOCK TABLES `otherworks_unit` WRITE;
/*!40000 ALTER TABLE `otherworks_unit` DISABLE KEYS */;
/*!40000 ALTER TABLE `otherworks_unit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prefab`
--

DROP TABLE IF EXISTS `prefab`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prefab` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `prefab_name_id` int(10) unsigned NOT NULL,
  `prefab_specs_id` int(10) unsigned DEFAULT NULL,
  `color_id` int(10) unsigned DEFAULT NULL,
  `desc` text DEFAULT NULL,
  `srp` decimal(12,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `prefab_prefab_name_FK` (`prefab_name_id`),
  KEY `prefab_prefab_specs_FK` (`prefab_specs_id`),
  KEY `prefab_color_FK` (`color_id`),
  CONSTRAINT `prefab_color_FK` FOREIGN KEY (`color_id`) REFERENCES `color` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `prefab_prefab_name_FK` FOREIGN KEY (`prefab_name_id`) REFERENCES `prefab_name` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `prefab_prefab_specs_FK` FOREIGN KEY (`prefab_specs_id`) REFERENCES `prefab_specs` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prefab`
--

LOCK TABLES `prefab` WRITE;
/*!40000 ALTER TABLE `prefab` DISABLE KEYS */;
INSERT INTO `prefab` VALUES (2,1,1,1,NULL,0.00);
/*!40000 ALTER TABLE `prefab` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prefab_material`
--

DROP TABLE IF EXISTS `prefab_material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prefab_material` (
  `prefab_id` int(10) unsigned NOT NULL,
  `material_id` int(10) unsigned NOT NULL,
  `quantity_per_prefab` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`prefab_id`,`material_id`),
  KEY `prefab_material_material_FK` (`material_id`),
  CONSTRAINT `prefab_material_material_FK` FOREIGN KEY (`material_id`) REFERENCES `material` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `prefab_material_prefab_FK` FOREIGN KEY (`prefab_id`) REFERENCES `prefab` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prefab_material`
--

LOCK TABLES `prefab_material` WRITE;
/*!40000 ALTER TABLE `prefab_material` DISABLE KEYS */;
INSERT INTO `prefab_material` VALUES (2,1,2);
/*!40000 ALTER TABLE `prefab_material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prefab_name`
--

DROP TABLE IF EXISTS `prefab_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prefab_name` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `prefab_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prefab_name_value` (`prefab_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prefab_name`
--

LOCK TABLES `prefab_name` WRITE;
/*!40000 ALTER TABLE `prefab_name` DISABLE KEYS */;
INSERT INTO `prefab_name` VALUES (1,'STANDARD');
/*!40000 ALTER TABLE `prefab_name` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `prefab_quantity`
--

DROP TABLE IF EXISTS `prefab_quantity`;
/*!50001 DROP VIEW IF EXISTS `prefab_quantity`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `prefab_quantity` AS SELECT
 1 AS `id`,
  1 AS `available_quantity` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `prefab_specs`
--

DROP TABLE IF EXISTS `prefab_specs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prefab_specs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `prefab_specs` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prefab_specs_value` (`prefab_specs`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prefab_specs`
--

LOCK TABLES `prefab_specs` WRITE;
/*!40000 ALTER TABLE `prefab_specs` DISABLE KEYS */;
INSERT INTO `prefab_specs` VALUES (1,'5.95*3');
/*!40000 ALTER TABLE `prefab_specs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `prefab_quantity`
--

/*!50001 DROP VIEW IF EXISTS `prefab_quantity`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `prefab_quantity` AS select `p`.`id` AS `id`,min(floor(`m`.`qty` / `pm`.`quantity_per_prefab`)) AS `available_quantity` from ((`prefab` `p` join `prefab_material` `pm` on(`p`.`id` = `pm`.`prefab_id`)) join `material` `m` on(`m`.`id` = `pm`.`material_id`)) group by `p`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-04  5:59:57
