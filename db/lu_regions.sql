-- MySQL dump 10.13  Distrib 5.6.21, for osx10.9 (x86_64)
--
-- Host: localhost    Database: uszcn_nest_dev
-- ------------------------------------------------------
-- Server version	5.6.21

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `lu_regions`
--

DROP TABLE IF EXISTS `lu_regions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lu_regions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `show_order` int(11) DEFAULT NULL,
  `pinyin` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_lu_regions_on_show_order` (`show_order`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lu_regions`
--

LOCK TABLES `lu_regions` WRITE;
/*!40000 ALTER TABLE `lu_regions` DISABLE KEYS */;
INSERT INTO `lu_regions` VALUES (1,'安徽',1,'ANHUI'),(2,'澳门',2,''),(3,'北京',3,'BEIJING'),(4,'福建',4,'FUJIAN'),(5,'甘肃',5,'GANSU'),(6,'广东',6,'GUANGDONG'),(7,'广西',7,'GUANGXI'),(8,'贵州',8,'GUIZHOU'),(9,'海南',9,'HAINAN '),(10,'河北',10,'HEBEI'),(11,'河南',11,'HENAN'),(12,'黑龙江',12,'HEILONGJIANG'),(13,'湖北',13,'HUBEI'),(14,'湖南',14,'HUNAN'),(15,'吉林',15,'JILIN'),(16,'江苏',16,'JIANGSU'),(17,'江西',17,'JIANGXI'),(18,'辽宁',18,'LIAONING'),(19,'内蒙古',19,'NEIMENGGU'),(20,'宁夏',20,'NINGXIA'),(21,'青海',21,'QINGHAI'),(22,'山东',22,'SHANDONG'),(23,'山西',23,'SHANXI'),(24,'陕西',24,'SHAANXI'),(25,'上海',25,'SHANGHAI'),(26,'四川',26,'SICHUAN'),(27,'台湾',27,''),(28,'天津',28,'TIANJIN'),(29,'西藏',29,'XIZANG'),(30,'香港',30,''),(31,'新疆',31,'XINJIANG'),(32,'云南',32,'YUNNAN'),(33,'浙江',33,'ZHEJIANG'),(34,'重庆',34,'CHONGQING');
/*!40000 ALTER TABLE `lu_regions` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-11-19 14:55:45
