-- MySQL dump 10.13  Distrib 8.0.40, for macos14 (arm64)
--
-- Host: localhost    Database: gaoqiang_dev
-- ------------------------------------------------------
-- Server version	8.4.5

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `active_storage_attachments`
--

DROP TABLE IF EXISTS `active_storage_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_attachments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `record_type` varchar(255) NOT NULL,
  `record_id` bigint NOT NULL,
  `blob_id` bigint NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_attachments_uniqueness` (`record_type`,`record_id`,`name`,`blob_id`),
  KEY `index_active_storage_attachments_on_blob_id` (`blob_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `active_storage_attachments`
--

LOCK TABLES `active_storage_attachments` WRITE;
/*!40000 ALTER TABLE `active_storage_attachments` DISABLE KEYS */;
INSERT INTO `active_storage_attachments` VALUES (1,'file','Crm::Order',3,1,'2026-03-24 18:27:32.378433');
/*!40000 ALTER TABLE `active_storage_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `active_storage_blobs`
--

DROP TABLE IF EXISTS `active_storage_blobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_blobs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `metadata` text,
  `service_name` varchar(255) NOT NULL,
  `byte_size` bigint NOT NULL,
  `checksum` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_blobs_on_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `active_storage_blobs`
--

LOCK TABLES `active_storage_blobs` WRITE;
/*!40000 ALTER TABLE `active_storage_blobs` DISABLE KEYS */;
INSERT INTO `active_storage_blobs` VALUES (1,'uqd3rp6qmjg7gbrqit6c8rmb0vo9','userpage.jpg','image/jpeg','{\"identified\":true}','local',336992,'AN7nfJWFG1LIfM1J7nyIIA==','2026-03-24 18:27:32.352525');
/*!40000 ALTER TABLE `active_storage_blobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `active_storage_variant_records`
--

DROP TABLE IF EXISTS `active_storage_variant_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_variant_records` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `blob_id` bigint NOT NULL,
  `variation_digest` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_variant_records_uniqueness` (`blob_id`,`variation_digest`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `active_storage_variant_records`
--

LOCK TABLES `active_storage_variant_records` WRITE;
/*!40000 ALTER TABLE `active_storage_variant_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `active_storage_variant_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activities` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status_id` int DEFAULT NULL,
  `content` text,
  `parent_id` int DEFAULT NULL,
  `record_id` int DEFAULT NULL,
  `record_type` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `mention_ids` json DEFAULT NULL,
  `file_urls` json DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_activities_on_record` (`record_id`,`record_type`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activities`
--

LOCK TABLES `activities` WRITE;
/*!40000 ALTER TABLE `activities` DISABLE KEYS */;
INSERT INTO `activities` VALUES (1,46,'苏打水稍等',NULL,3,'Crm::Order',1,NULL,NULL,'2026-03-24 17:44:26.932516'),(2,46,'的好方法电放费',NULL,3,'Crm::Order',1,NULL,NULL,'2026-03-24 17:44:34.967108'),(3,47,'订单发货了',NULL,3,'Crm::Order',1,NULL,NULL,'2026-03-24 17:44:52.517995'),(4,47,'合法合规',NULL,3,'Crm::Order',1,NULL,NULL,'2026-03-24 17:45:36.601633'),(5,47,'大法师大法师大V',NULL,3,'Crm::Order',1,NULL,NULL,'2026-03-24 17:45:43.563857'),(6,47,'阿斯顿发水电费第三方撒',NULL,3,'Crm::Order',1,NULL,NULL,'2026-03-24 17:45:46.651450'),(7,45,'5555',NULL,2,'Crm::Order',1,NULL,NULL,'2026-03-24 17:51:30.499113'),(8,45,'测试',NULL,2,'Crm::Order',1,NULL,NULL,'2026-03-24 18:28:09.966530'),(9,47,'打发第三方',NULL,4,'Crm::Order',1,NULL,NULL,'2026-03-24 20:04:50.447220');
/*!40000 ALTER TABLE `activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ar_internal_metadata`
--

DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ar_internal_metadata`
--

LOCK TABLES `ar_internal_metadata` WRITE;
/*!40000 ALTER TABLE `ar_internal_metadata` DISABLE KEYS */;
INSERT INTO `ar_internal_metadata` VALUES ('environment','development','2026-03-23 23:13:17.868090','2026-03-23 23:13:17.868090'),('schema_sha1','2da9f160bfcb759114c53de8eef01ca962e86413','2026-03-23 23:13:17.880613','2026-03-23 23:13:17.880613');
/*!40000 ALTER TABLE `ar_internal_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attachments`
--

DROP TABLE IF EXISTS `attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attachments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `record_id` int DEFAULT NULL,
  `record_type` varchar(255) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `byte_size` int DEFAULT NULL,
  `uuid` varchar(255) DEFAULT NULL,
  `checksum` varchar(255) NOT NULL DEFAULT '',
  `remark` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `index_attachments_on_record_id_and_record_type` (`record_id`,`record_type`),
  KEY `index_attachments_on_uuid` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attachments`
--

LOCK TABLES `attachments` WRITE;
/*!40000 ALTER TABLE `attachments` DISABLE KEYS */;
INSERT INTO `attachments` VALUES (1,'logo2.png','logo2.png',NULL,NULL,NULL,NULL,1,'2026-03-23 23:22:43.726432','2026-03-23 23:22:43.726432','image/png',5891,'fc2a87c9-9b27-4ae6-b142-e32e422c85d2','',''),(2,'logo2.png','logo2.png',NULL,NULL,NULL,NULL,1,'2026-03-23 23:22:57.742659','2026-03-23 23:22:57.742659','image/png',5891,'c89c00ba-7150-4431-a89e-f44f5f03fc5d','','');
/*!40000 ALTER TABLE `attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_contracts`
--

DROP TABLE IF EXISTS `audit_contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_contracts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` int DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `uuid` varchar(255) DEFAULT NULL,
  `part_a` varchar(255) DEFAULT NULL,
  `part_b` varchar(255) DEFAULT NULL,
  `contract_number` varchar(255) DEFAULT NULL,
  `project_name` varchar(255) DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `is_realtime` tinyint(1) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `result` json DEFAULT NULL,
  `result_at` varchar(255) DEFAULT NULL,
  `result_file` varchar(255) DEFAULT NULL,
  `remark` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_audit_contracts_on_parent_id` (`parent_id`),
  KEY `index_audit_contracts_on_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_contracts`
--

LOCK TABLES `audit_contracts` WRITE;
/*!40000 ALTER TABLE `audit_contracts` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_contracts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_lists`
--

DROP TABLE IF EXISTS `audit_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_lists` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `audit_contract_id` int DEFAULT NULL,
  `sn` int DEFAULT NULL,
  `serial_number` varchar(255) DEFAULT NULL,
  `risk_clause` varchar(255) DEFAULT NULL,
  `risk_level` varchar(255) DEFAULT NULL,
  `legal_advice` varchar(255) DEFAULT NULL,
  `reply` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_audit_lists_on_audit_contract_id` (`audit_contract_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_lists`
--

LOCK TABLES `audit_lists` WRITE;
/*!40000 ALTER TABLE `audit_lists` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_lists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blacklists`
--

DROP TABLE IF EXISTS `blacklists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blacklists` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT '0' COMMENT 'id > 0 用户黑名单，默认0 代表终端黑名单',
  `ip` varchar(255) DEFAULT NULL COMMENT '记录ip',
  `num` int DEFAULT '0' COMMENT '登录失败次数',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blacklists`
--

LOCK TABLES `blacklists` WRITE;
/*!40000 ALTER TABLE `blacklists` DISABLE KEYS */;
/*!40000 ALTER TABLE `blacklists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cities`
--

DROP TABLE IF EXISTS `cities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cities` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `province_id` bigint NOT NULL,
  `code` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `py` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_cities_on_code` (`code`),
  UNIQUE KEY `index_cities_on_province_id_and_code` (`province_id`,`code`),
  KEY `index_cities_on_province_id` (`province_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cities`
--

LOCK TABLES `cities` WRITE;
/*!40000 ALTER TABLE `cities` DISABLE KEYS */;
/*!40000 ALTER TABLE `cities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `logo` varchar(255) DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `abbr` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `credit_code` varchar(255) DEFAULT NULL,
  `legal_name` varchar(255) DEFAULT NULL,
  `status_id` int DEFAULT NULL,
  `reg_date` date DEFAULT NULL,
  `reg_capital` varchar(255) DEFAULT NULL,
  `reg_address` varchar(255) DEFAULT NULL,
  `company_type_id` int DEFAULT NULL,
  `contact` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `business_scope` text,
  `industry_id` int DEFAULT NULL,
  `business_reg_number` varchar(255) DEFAULT NULL,
  `business_term` varchar(255) DEFAULT NULL,
  `approval_date` date DEFAULT NULL,
  `region_id` int DEFAULT NULL,
  `organization_code` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_companies_on_name_and_py_and_credit_code` (`name`,`py`,`credit_code`),
  KEY `index_companies_on_company_type_id` (`company_type_id`),
  KEY `index_companies_on_industry_id` (`industry_id`),
  KEY `index_companies_on_parent_id` (`parent_id`),
  KEY `index_companies_on_region_id` (`region_id`),
  KEY `index_companies_on_status_id` (`status_id`),
  KEY `index_companies_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
/*!40000 ALTER TABLE `companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `counties`
--

DROP TABLE IF EXISTS `counties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `counties` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `city_id` bigint NOT NULL,
  `code` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `py` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_counties_on_city_id_and_code` (`city_id`,`code`),
  UNIQUE KEY `index_counties_on_code` (`code`),
  KEY `index_counties_on_city_id` (`city_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `counties`
--

LOCK TABLES `counties` WRITE;
/*!40000 ALTER TABLE `counties` DISABLE KEYS */;
/*!40000 ALTER TABLE `counties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_addresses`
--

DROP TABLE IF EXISTS `crm_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_addresses` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `client_id` bigint DEFAULT NULL,
  `addr_kind` varchar(255) DEFAULT NULL,
  `contact` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `addr` text,
  `is_default` tinyint(1) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_crm_addresses_on_client_id` (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_addresses`
--

LOCK TABLES `crm_addresses` WRITE;
/*!40000 ALTER TABLE `crm_addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_clients`
--

DROP TABLE IF EXISTS `crm_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_clients` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` int DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `abbr` varchar(255) DEFAULT NULL,
  `tax_no` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `bank_name` varchar(255) DEFAULT NULL,
  `bank_account` varchar(255) DEFAULT NULL,
  `settlement_id` int DEFAULT NULL,
  `payment_terms` varchar(255) DEFAULT NULL,
  `invoice_type_id` int DEFAULT NULL,
  `remark` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_clients`
--

LOCK TABLES `crm_clients` WRITE;
/*!40000 ALTER TABLE `crm_clients` DISABLE KEYS */;
INSERT INTO `crm_clients` VALUES (1,NULL,'001','金陵',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'jl','2026-03-24 14:37:43.105207','2026-03-24 14:37:43.105207'),(2,NULL,'3','那欢化工',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'nhhg','2026-03-24 14:37:55.966550','2026-03-24 14:37:55.966550'),(3,NULL,'CRM-260324-0001','jjjdjddf',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'jjjdjddf','2026-03-24 15:42:47.951793','2026-03-24 15:42:47.951793'),(4,NULL,'CRM-260324-0002','开学',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'kx','2026-03-24 15:54:54.684493','2026-03-24 15:54:54.684493'),(5,NULL,'CRM-260324-0003','上海日化',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'shrh','2026-03-24 16:27:39.406280','2026-03-24 16:27:39.406280');
/*!40000 ALTER TABLE `crm_clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_contacts`
--

DROP TABLE IF EXISTS `crm_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_contacts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `client_id` bigint DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `dept` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `mobile` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `is_primary` tinyint(1) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_crm_contacts_on_client_id` (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_contacts`
--

LOCK TABLES `crm_contacts` WRITE;
/*!40000 ALTER TABLE `crm_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_handover_lines`
--

DROP TABLE IF EXISTS `crm_handover_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_handover_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `handover_id` bigint DEFAULT NULL,
  `spec_item_id` bigint DEFAULT NULL,
  `contract_req` varchar(255) DEFAULT NULL,
  `internal_req` varchar(255) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_crm_handover_lines_on_handover_id` (`handover_id`),
  KEY `index_crm_handover_lines_on_spec_item_id` (`spec_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_handover_lines`
--

LOCK TABLES `crm_handover_lines` WRITE;
/*!40000 ALTER TABLE `crm_handover_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_handover_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_handovers`
--

DROP TABLE IF EXISTS `crm_handovers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_handovers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `doc_no` varchar(255) DEFAULT NULL,
  `order_company` varchar(255) DEFAULT NULL,
  `order_contract_no` varchar(255) DEFAULT NULL,
  `goods_name` varchar(255) DEFAULT NULL,
  `specs` text,
  `order_kind` varchar(255) DEFAULT NULL,
  `special_note` varchar(255) DEFAULT NULL,
  `qty` decimal(12,2) DEFAULT '0.00',
  `qty_unit` varchar(255) DEFAULT NULL,
  `pack_specs` text,
  `deliver_at` date DEFAULT NULL,
  `notes` text,
  `reviewer_id` int DEFAULT NULL,
  `review_at` date DEFAULT NULL,
  `prod_signer_id` int DEFAULT NULL,
  `tech_signer_id` int DEFAULT NULL,
  `qa_signer_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `pur_contract_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_handovers`
--

LOCK TABLES `crm_handovers` WRITE;
/*!40000 ALTER TABLE `crm_handovers` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_handovers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_invoices`
--

DROP TABLE IF EXISTS `crm_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_invoices` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `billable_type` varchar(255) DEFAULT NULL,
  `billable_id` int DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `tax_no` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `bank_name` varchar(255) DEFAULT NULL,
  `bank_account` varchar(255) DEFAULT NULL,
  `invoice_type_id` int DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_invoices`
--

LOCK TABLES `crm_invoices` WRITE;
/*!40000 ALTER TABLE `crm_invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_order_lines`
--

DROP TABLE IF EXISTS `crm_order_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_order_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint DEFAULT NULL,
  `product_id` bigint DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `weight` varchar(255) DEFAULT NULL,
  `qty` decimal(14,3) DEFAULT NULL,
  `unit` varchar(255) DEFAULT NULL,
  `stock_status` varchar(255) DEFAULT NULL,
  `color_master_status` varchar(255) DEFAULT NULL,
  `remark` text,
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `delivery_qty` decimal(14,3) DEFAULT NULL,
  `loss_qty` decimal(14,3) DEFAULT NULL,
  `line_delivery_date` date DEFAULT NULL,
  `production_machine` varchar(255) DEFAULT NULL,
  `injection_prod_code` varchar(255) DEFAULT NULL,
  `injection_prod_date` date DEFAULT NULL,
  `gasket_machine` varchar(255) DEFAULT NULL,
  `gasket_prod_code` varchar(255) DEFAULT NULL,
  `gasket_prod_date` date DEFAULT NULL,
  `closing_date` date DEFAULT NULL,
  `semi_inventory` decimal(14,3) DEFAULT NULL,
  `semi_completed` decimal(14,3) DEFAULT NULL,
  `semi_reserve` decimal(14,3) DEFAULT NULL,
  `original_inventory` decimal(14,3) DEFAULT NULL,
  `outsourcing_qty` decimal(14,3) DEFAULT NULL,
  `unfinished_qty` decimal(14,3) DEFAULT NULL,
  `finished_total` decimal(14,3) DEFAULT NULL,
  `unit_price` decimal(12,2) DEFAULT NULL,
  `line_amount` decimal(14,2) DEFAULT NULL,
  `ship_doc_unreturned` varchar(255) DEFAULT NULL,
  `ship_doc_returned` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_crm_order_lines_on_order_id` (`order_id`),
  KEY `index_crm_order_lines_on_product_id` (`product_id`),
  CONSTRAINT `fk_rails_59d880275c` FOREIGN KEY (`order_id`) REFERENCES `crm_orders` (`id`),
  CONSTRAINT `fk_rails_c596daffea` FOREIGN KEY (`product_id`) REFERENCES `mat_products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_order_lines`
--

LOCK TABLES `crm_order_lines` WRITE;
/*!40000 ALTER TABLE `crm_order_lines` DISABLE KEYS */;
INSERT INTO `crm_order_lines` VALUES (1,1,120,'GQ-25L-301','GQ-25L-301','白','25L',2100.000,'只','','','',1,1,'2026-03-24 16:18:41.731204','2026-03-24 16:18:41.731204',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(2,1,120,'小喇叭盖','阻隔铝箔垫37.2-乐果专业铝箔垫','40657绿','14G',2100.000,'只','','','',2,1,'2026-03-24 16:18:41.750543','2026-03-24 16:18:41.750543',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(3,2,3,'GQ-1L-双口子母瓶','GQ-1L-双口子母瓶','白','950ml/180ml',1000.000,'个','采购中','库存','',1,1,'2026-03-24 16:29:00.957015','2026-03-24 16:29:00.957015',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(4,2,113,'GQ-20L-308','GQ-20L-308','PE/COEX','20L',8000.000,'个','','库存','',2,1,'2026-03-24 16:29:00.967739','2026-03-24 16:29:00.967739',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(5,3,119,'GQ-20L-302','GQ-20L-302','PE/COEX','20L',1000.000,'个','','','',1,1,'2026-03-24 17:24:26.260752','2026-03-24 17:24:26.260752',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(6,4,110,'GQ-800-002','GQ-800-002','PE/COEX','800ml',2000.000,'—','','','',1,1,'2026-03-24 20:04:34.632116','2026-03-24 20:04:34.632116',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(7,4,111,'GQ-900-001','GQ-900-001','PE/COEX','900ml',5000.000,'—','','','',2,1,'2026-03-24 20:04:34.642772','2026-03-30 15:24:48.232207',5.000,21.000,'2026-04-01','A1','00001','2026-03-31','2',NULL,'2026-03-31',NULL,NULL,NULL,NULL,NULL,1.000,NULL,NULL,NULL,NULL,NULL,NULL),(8,5,20,'1L 阻隔瓶','GQ-1000-011','白','120G',10030.000,'只','','','',1,1,'2026-03-30 18:39:36.107614','2026-03-30 18:39:36.107614',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(9,5,NULL,'中口防盗圈盖','阻隔铝箔垫47.1','40657绿','10G',10030.000,'只','','有结存','',2,1,'2026-03-30 18:39:36.123062','2026-03-30 18:39:36.123062',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(10,5,NULL,'75ML量杯','','-','1',10030.000,'只','','','',3,1,'2026-03-30 18:39:36.127111','2026-04-06 16:20:53.942511',NULL,NULL,'2026-04-17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `crm_order_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_orders`
--

DROP TABLE IF EXISTS `crm_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `pre_order_id` bigint DEFAULT NULL,
  `client_id` bigint DEFAULT NULL,
  `receive_date` date DEFAULT NULL,
  `contract_code` varchar(255) DEFAULT NULL,
  `customer_delivery_date` date DEFAULT NULL,
  `follower_id` int DEFAULT NULL,
  `follow_at` datetime(6) DEFAULT NULL,
  `follow_progress` text,
  `amount` decimal(14,2) DEFAULT NULL,
  `delivered_qty` decimal(14,3) DEFAULT NULL,
  `invoice_amount` decimal(14,2) DEFAULT NULL,
  `invoice_at` datetime(6) DEFAULT NULL,
  `payment_amount` decimal(14,2) DEFAULT NULL,
  `payment_at` datetime(6) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `status_id` bigint DEFAULT NULL,
  `hazard_pack_month` varchar(255) DEFAULT NULL,
  `spec_requirements` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_crm_orders_on_code` (`code`),
  KEY `index_crm_orders_on_pre_order_id` (`pre_order_id`),
  KEY `index_crm_orders_on_client_id` (`client_id`),
  KEY `index_crm_orders_on_status_id` (`status_id`),
  CONSTRAINT `fk_rails_01c2f71c8a` FOREIGN KEY (`pre_order_id`) REFERENCES `mat_pre_orders` (`id`),
  CONSTRAINT `fk_rails_4a4c7f7a0c` FOREIGN KEY (`status_id`) REFERENCES `properties` (`id`),
  CONSTRAINT `fk_rails_5ef72f7384` FOREIGN KEY (`client_id`) REFERENCES `crm_clients` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_orders`
--

LOCK TABLES `crm_orders` WRITE;
/*!40000 ALTER TABLE `crm_orders` DISABLE KEYS */;
INSERT INTO `crm_orders` VALUES (1,'CRM-260324-0001',2,4,'2026-03-24','0102上海新易 CIE20251022005 FJI-5（谭）','2026-03-25',NULL,NULL,'白瓶绿盖，瓶套收缩膜，瓶盖喷码，纸箱套防尘袋，300G儿L乐果\nEC',99999.00,0.000,0.00,NULL,0.00,NULL,1,NULL,'CRM 260324 0001','2026-03-24 16:18:41.643421','2026-03-24 16:18:41.643421',NULL,NULL,NULL),(2,'CRM-260324-0002',NULL,5,'2026-03-24','dddddffff','2026-03-24',NULL,NULL,'sadsa',8900.00,0.000,0.00,NULL,0.00,NULL,1,1,'CRM 260324 0002','2026-03-24 16:29:00.945860','2026-03-24 17:51:30.524488',45,NULL,NULL),(3,'CRM-260324-0003',NULL,5,'2026-03-24','dfffffd','2026-03-27',1,NULL,'ffffggg',10000.00,0.000,0.00,NULL,0.00,NULL,1,1,'CRM 260324 0003','2026-03-24 17:24:26.240515','2026-03-24 18:27:32.384542',47,NULL,NULL),(4,'CRM-260324-0004',4,1,'2026-03-24','0104宁波盈农生物 科技有限公司 25ASWB1208-2 （张）','2026-03-24',1,NULL,'白瓶黄盖，带防盗圈，带UN号，180克/升氰氟草酯乳油',0.00,0.000,0.00,NULL,0.00,NULL,1,1,'CRM 260324 0004','2026-03-24 20:04:34.616787','2026-03-24 20:04:50.480230',47,NULL,NULL),(5,'CRM-260330-0001',NULL,1,'2026-04-05','0105威洋WY26005-JL（於）','2026-04-16',1,NULL,'白瓶绿盖，带防盗圈，带量杯，绿盖带刀口，颜色和标签一致，带UN，需要收缩膜，40G/L烟嘧磺隆OD\n\n',0.00,0.000,0.00,NULL,0.00,NULL,1,NULL,'CRM 260330 0001','2026-03-30 18:39:36.072946','2026-03-30 18:39:36.072946',44,NULL,'白瓶绿盖，带防盗圈，带量杯，绿盖带刀口，颜色和标签一致，带UN，需要收缩膜，40G/L烟嘧磺隆OD\n\n');
/*!40000 ALTER TABLE `crm_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_quotation_lines`
--

DROP TABLE IF EXISTS `crm_quotation_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_quotation_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `quotation_id` bigint DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `spec` varchar(255) DEFAULT NULL,
  `qty` decimal(12,2) DEFAULT '0.00',
  `unit` varchar(255) DEFAULT NULL,
  `unit_price` decimal(12,2) DEFAULT '0.00',
  `amount` decimal(12,2) DEFAULT '0.00',
  `remark` varchar(255) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_crm_quotation_lines_on_quotation_id` (`quotation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_quotation_lines`
--

LOCK TABLES `crm_quotation_lines` WRITE;
/*!40000 ALTER TABLE `crm_quotation_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_quotation_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_quotations`
--

DROP TABLE IF EXISTS `crm_quotations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_quotations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `client_id` bigint DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `quote_date` date DEFAULT NULL,
  `valid_until` date DEFAULT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `status_id` int DEFAULT NULL,
  `tax_rate_id` int DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT '0.00',
  `total_amount` decimal(12,2) DEFAULT '0.00',
  `remark` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_crm_quotations_on_client_id` (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_quotations`
--

LOCK TABLES `crm_quotations` WRITE;
/*!40000 ALTER TABLE `crm_quotations` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_quotations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_spec_items`
--

DROP TABLE IF EXISTS `crm_spec_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crm_spec_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `name_en` varchar(255) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `values` json DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_spec_items`
--

LOCK TABLES `crm_spec_items` WRITE;
/*!40000 ALTER TABLE `crm_spec_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_spec_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `parent_code` varchar(255) DEFAULT NULL,
  `status` tinyint(1) DEFAULT '0',
  `manager_id` int DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `company_id` int DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  `sort` int NOT NULL DEFAULT '0',
  `manager_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_departments_on_ancestry` (`ancestry`),
  KEY `index_departments_on_company_id` (`company_id`),
  KEY `index_departments_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doc_number_rules`
--

DROP TABLE IF EXISTS `doc_number_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doc_number_rules` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL COMMENT '唯一标识，如 fm_contracts',
  `name` varchar(255) NOT NULL COMMENT '规则名称',
  `format` varchar(255) NOT NULL COMMENT '格式模板，支持 {YYYY}{MM}{DD}{seq:4} 等占位符',
  `current_sequence` int NOT NULL DEFAULT '0' COMMENT '当前序列号',
  `reset_period` varchar(255) DEFAULT 'none' COMMENT '序号重置周期: none/day/month/year',
  `last_date` date DEFAULT NULL COMMENT '上次生成日期，用于按日/月/年重置',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_doc_number_rules_on_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doc_number_rules`
--

LOCK TABLES `doc_number_rules` WRITE;
/*!40000 ALTER TABLE `doc_number_rules` DISABLE KEYS */;
INSERT INTO `doc_number_rules` VALUES (1,'fm_contracts','FM合同单号','FM-{YYMMDD}-{seq:4}',0,'day',NULL,'2026-03-23 23:15:47.716826','2026-03-23 23:15:47.716826'),(2,'crm_quotations','CRM报价单号','QT-{YYMMDD}-{seq:4}',0,'day',NULL,'2026-03-23 23:15:47.726500','2026-03-23 23:15:47.726500'),(3,'crm_handovers','CRM交接单号','JH-{YYMMDD}-{seq:4}',0,'day',NULL,'2026-03-23 23:15:47.740986','2026-03-23 23:15:47.740986'),(4,'mat_products','单号规则 mat_products','MAT-{YYMMDD}-{seq:4}',1,'day','2026-03-23','2026-03-23 23:32:09.037435','2026-03-23 23:32:09.073261'),(5,'mat_items','单号规则 mat_items','MAT-{YYMMDD}-{seq:4}',120,'day','2026-03-23','2026-03-23 23:32:09.294104','2026-03-23 23:43:05.272004'),(6,'nodes','单号规则 nodes','NODES-{YYMMDD}-{seq:4}',5,'day','2026-03-30','2026-03-24 14:03:00.124542','2026-03-30 15:16:08.921666'),(8,'crm_clients','单号规则 crm_clients','CRM-{YYMMDD}-{seq:4}',3,'day','2026-03-24','2026-03-24 15:42:47.975764','2026-03-24 16:27:39.415856'),(10,'crm_orders','单号规则 crm_orders','CRM-{YYMMDD}-{seq:4}',1,'day','2026-03-30','2026-03-24 16:18:41.611845','2026-03-30 18:39:36.016332');
/*!40000 ALTER TABLE `doc_number_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fm_collections`
--

DROP TABLE IF EXISTS `fm_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fm_collections` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `unit_id` int DEFAULT NULL,
  `qty` decimal(12,2) DEFAULT '0.00',
  `price` decimal(12,2) DEFAULT '0.00',
  `amount_excl_tax` decimal(12,2) DEFAULT '0.00',
  `tax` decimal(12,2) DEFAULT '0.00',
  `amount` decimal(12,2) DEFAULT '0.00',
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_fm_collections_on_contract_id` (`contract_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fm_collections`
--

LOCK TABLES `fm_collections` WRITE;
/*!40000 ALTER TABLE `fm_collections` DISABLE KEYS */;
/*!40000 ALTER TABLE `fm_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fm_contract_workflow_logs`
--

DROP TABLE IF EXISTS `fm_contract_workflow_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fm_contract_workflow_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` bigint NOT NULL COMMENT '关联合同',
  `step_key` varchar(255) NOT NULL COMMENT '节点标识',
  `step_label` varchar(255) DEFAULT NULL COMMENT '节点名称',
  `operated_at` datetime(6) NOT NULL COMMENT '操作时间',
  `operator_id` int DEFAULT NULL COMMENT '操作人 ID',
  `operator_name` varchar(255) DEFAULT NULL COMMENT '操作人姓名',
  `action` text COMMENT '操作/备注内容',
  `result` varchar(255) DEFAULT NULL COMMENT '节点结果',
  `result_extra` json DEFAULT NULL COMMENT '扩展结果',
  `sort` int DEFAULT '0',
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_fm_contract_workflow_logs_on_contract_id` (`contract_id`),
  KEY `index_fm_contract_workflow_logs_on_operated_at` (`operated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fm_contract_workflow_logs`
--

LOCK TABLES `fm_contract_workflow_logs` WRITE;
/*!40000 ALTER TABLE `fm_contract_workflow_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `fm_contract_workflow_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fm_contract_workflow_states`
--

DROP TABLE IF EXISTS `fm_contract_workflow_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fm_contract_workflow_states` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` bigint NOT NULL COMMENT '关联合同',
  `step_key` varchar(255) NOT NULL COMMENT '节点标识',
  `status` varchar(255) NOT NULL DEFAULT 'pending' COMMENT 'pending/current/completed/failed',
  `completed_at` datetime(6) DEFAULT NULL COMMENT '完成时间',
  `result` varchar(255) DEFAULT NULL COMMENT '该节点最终结果',
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_wf_states_contract_step` (`contract_id`,`step_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fm_contract_workflow_states`
--

LOCK TABLES `fm_contract_workflow_states` WRITE;
/*!40000 ALTER TABLE `fm_contract_workflow_states` DISABLE KEYS */;
/*!40000 ALTER TABLE `fm_contract_workflow_states` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fm_contracts`
--

DROP TABLE IF EXISTS `fm_contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fm_contracts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `sign_at` date DEFAULT NULL,
  `client_id` bigint DEFAULT NULL,
  `client_contact_id` int DEFAULT NULL,
  `client_contact_name` varchar(255) DEFAULT NULL,
  `client_phone` varchar(255) DEFAULT NULL,
  `client_fax` varchar(255) DEFAULT NULL,
  `supplier_id` bigint DEFAULT NULL,
  `supplier_contact_name` varchar(255) DEFAULT NULL,
  `supplier_contact_id` int DEFAULT NULL,
  `supplier_phone` varchar(255) DEFAULT NULL,
  `supplier_fax` varchar(255) DEFAULT NULL,
  `product_en` varchar(255) DEFAULT NULL,
  `product_zh` varchar(255) DEFAULT NULL,
  `specs` text,
  `pack_req` text,
  `qty` decimal(12,2) DEFAULT '0.00',
  `unit_price` decimal(12,2) DEFAULT '0.00',
  `total` decimal(12,2) DEFAULT '0.00',
  `tax` decimal(12,2) DEFAULT '0.00',
  `amount_net` decimal(12,2) DEFAULT '0.00',
  `total_cn` varchar(255) DEFAULT NULL,
  `deliver_at` date DEFAULT NULL,
  `deliver_addr` varchar(255) DEFAULT NULL,
  `indicator_req` varchar(255) DEFAULT NULL,
  `req_docs` varchar(255) DEFAULT NULL,
  `settlement_id` int DEFAULT NULL,
  `remarks` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `unit_id` int DEFAULT NULL,
  `workflow_template_id` bigint DEFAULT NULL COMMENT '关联流程模板',
  `tax_id` int DEFAULT NULL COMMENT '税率（关联 properties）',
  `product_id` int DEFAULT NULL COMMENT '关联产品（mat_products）',
  PRIMARY KEY (`id`),
  KEY `index_fm_contracts_on_client_id` (`client_id`),
  KEY `index_fm_contracts_on_product_id` (`product_id`),
  KEY `index_fm_contracts_on_supplier_id` (`supplier_id`),
  KEY `index_fm_contracts_on_workflow_template_id` (`workflow_template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fm_contracts`
--

LOCK TABLES `fm_contracts` WRITE;
/*!40000 ALTER TABLE `fm_contracts` DISABLE KEYS */;
/*!40000 ALTER TABLE `fm_contracts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inv_inventories`
--

DROP TABLE IF EXISTS `inv_inventories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_inventories` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `item_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `warehouse_id` int DEFAULT NULL,
  `on_hand_qty` decimal(12,2) DEFAULT '0.00',
  `available_qty` decimal(12,2) DEFAULT '0.00',
  `allocated_qty` decimal(12,2) DEFAULT '0.00',
  `in_transit_qty` decimal(12,2) DEFAULT '0.00',
  `status_id` int DEFAULT NULL,
  `last_count_date` datetime(6) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `labels` json DEFAULT NULL,
  `custom_fields` json DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_inv_inventories_on_company_id` (`company_id`),
  KEY `index_inv_inventories_on_item_id` (`item_id`),
  KEY `index_inv_inventories_on_location_id` (`location_id`),
  KEY `index_inv_inventories_on_status_id` (`status_id`),
  KEY `index_inv_inventories_on_warehouse_id` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inv_inventories`
--

LOCK TABLES `inv_inventories` WRITE;
/*!40000 ALTER TABLE `inv_inventories` DISABLE KEYS */;
/*!40000 ALTER TABLE `inv_inventories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inv_inventory_locks`
--

DROP TABLE IF EXISTS `inv_inventory_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_inventory_locks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `item_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `inventory_id` int DEFAULT NULL,
  `locked_qty` decimal(12,2) DEFAULT '0.00',
  `order_type` varchar(255) DEFAULT NULL,
  `order_id` int DEFAULT NULL,
  `lock_type` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `expires_at` datetime(6) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_inv_inventory_locks_on_inventory_id` (`inventory_id`),
  KEY `index_inv_inventory_locks_on_item_id` (`item_id`),
  KEY `index_inv_inventory_locks_on_location_id` (`location_id`),
  KEY `index_inv_inventory_locks_on_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inv_inventory_locks`
--

LOCK TABLES `inv_inventory_locks` WRITE;
/*!40000 ALTER TABLE `inv_inventory_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `inv_inventory_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inv_inventory_transactions`
--

DROP TABLE IF EXISTS `inv_inventory_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_inventory_transactions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `inventory_id` int DEFAULT NULL,
  `transaction_type` varchar(255) DEFAULT NULL,
  `related_order_type` varchar(255) DEFAULT NULL,
  `related_order_id` int DEFAULT NULL,
  `quantity_before` decimal(12,2) DEFAULT '0.00',
  `quantity_change` decimal(12,2) DEFAULT '0.00',
  `quantity_after` decimal(12,2) DEFAULT '0.00',
  `operator_id` int DEFAULT NULL,
  `transaction_time` datetime(6) DEFAULT NULL,
  `remark` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_inv_inventory_transactions_on_inventory_id` (`inventory_id`),
  KEY `index_inv_inventory_transactions_on_item_id` (`item_id`),
  KEY `index_inv_inventory_transactions_on_location_id` (`location_id`),
  KEY `index_inv_inventory_transactions_on_related_order_id` (`related_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inv_inventory_transactions`
--

LOCK TABLES `inv_inventory_transactions` WRITE;
/*!40000 ALTER TABLE `inv_inventory_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `inv_inventory_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inv_lots`
--

DROP TABLE IF EXISTS `inv_lots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_lots` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `ref` varchar(255) DEFAULT NULL,
  `qty` decimal(12,2) DEFAULT '0.00',
  `unit_cost` decimal(12,2) DEFAULT '0.00',
  `expiration_date` datetime(6) DEFAULT NULL,
  `alert_date` datetime(6) DEFAULT NULL,
  `removal_date` datetime(6) DEFAULT NULL,
  `order_type` varchar(255) DEFAULT NULL,
  `order_id` int DEFAULT NULL,
  `order_line_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `description` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_inv_lots_on_company_id` (`company_id`),
  KEY `index_inv_lots_on_item_id` (`item_id`),
  KEY `index_inv_lots_on_order_id` (`order_id`),
  KEY `index_inv_lots_on_order_line_id` (`order_line_id`),
  KEY `index_inv_lots_on_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inv_lots`
--

LOCK TABLES `inv_lots` WRITE;
/*!40000 ALTER TABLE `inv_lots` DISABLE KEYS */;
/*!40000 ALTER TABLE `inv_lots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `iqc_fdf_lines`
--

DROP TABLE IF EXISTS `iqc_fdf_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iqc_fdf_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `fdf_id` bigint DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `batch_number` varchar(255) DEFAULT NULL,
  `yield_kl_t` varchar(255) DEFAULT NULL,
  `sample_weight_mg` decimal(12,2) DEFAULT '0.00',
  `spectrum_id` varchar(255) DEFAULT NULL,
  `peak_area_ratio` varchar(255) DEFAULT NULL,
  `mass_fraction_percent` decimal(12,2) DEFAULT '0.00',
  `specific_gravity` decimal(12,2) DEFAULT '0.00',
  `mass_concentration_g_l` decimal(12,2) DEFAULT '0.00',
  `suspension_powder_weight_g` decimal(12,2) DEFAULT '0.00',
  `suspension_spectrum_id` varchar(255) DEFAULT NULL,
  `suspension_peak_area_ratio` varchar(255) DEFAULT NULL,
  `suspension_mass_fraction_percent` decimal(12,2) DEFAULT '0.00',
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_iqc_fdf_lines_on_fdf_id` (`fdf_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `iqc_fdf_lines`
--

LOCK TABLES `iqc_fdf_lines` WRITE;
/*!40000 ALTER TABLE `iqc_fdf_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `iqc_fdf_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `iqc_fdfs`
--

DROP TABLE IF EXISTS `iqc_fdfs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iqc_fdfs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `inspection_basis` varchar(255) DEFAULT NULL,
  `instrument_number` varchar(255) DEFAULT NULL,
  `customer_trademark_name` varchar(255) DEFAULT NULL,
  `request_inspection_date` date DEFAULT NULL,
  `std_sample_1_m` varchar(255) DEFAULT NULL,
  `std_sample_1_x` decimal(12,2) DEFAULT '0.00',
  `std_sample_1_spectrum_id` varchar(255) DEFAULT NULL,
  `std_sample_1_a_r_1` varchar(255) DEFAULT NULL,
  `std_sample_1_a_r_2` varchar(255) DEFAULT NULL,
  `std_sample_2_m` varchar(255) DEFAULT NULL,
  `std_sample_2_x` decimal(12,2) DEFAULT '0.00',
  `std_sample_2_spectrum_id` varchar(255) DEFAULT NULL,
  `std_sample_2_a_r_1` varchar(255) DEFAULT NULL,
  `std_sample_2_a_r_2` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `iqc_fdfs`
--

LOCK TABLES `iqc_fdfs` WRITE;
/*!40000 ALTER TABLE `iqc_fdfs` DISABLE KEYS */;
/*!40000 ALTER TABLE `iqc_fdfs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `iqc_ldf_lines`
--

DROP TABLE IF EXISTS `iqc_ldf_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iqc_ldf_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ldf_id` bigint DEFAULT NULL,
  `inspection_date` date DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `batch_number` varchar(255) DEFAULT NULL,
  `ph_value` decimal(12,2) DEFAULT '0.00',
  `specific_gravity_g_ml` decimal(12,2) DEFAULT '0.00',
  `moisture_percent` decimal(12,2) DEFAULT '0.00',
  `flash_point_c` decimal(12,2) DEFAULT '0.00',
  `viscosity` varchar(255) DEFAULT NULL,
  `dispersion_stability_20_200` varchar(255) DEFAULT NULL,
  `foam_retention_ml` varchar(255) DEFAULT NULL,
  `pourability` varchar(255) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_iqc_ldf_lines_on_ldf_id` (`ldf_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `iqc_ldf_lines`
--

LOCK TABLES `iqc_ldf_lines` WRITE;
/*!40000 ALTER TABLE `iqc_ldf_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `iqc_ldf_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `iqc_ldfs`
--

DROP TABLE IF EXISTS `iqc_ldfs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iqc_ldfs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `customer_trademark` varchar(255) DEFAULT NULL,
  `sample_color` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `iqc_ldfs`
--

LOCK TABLES `iqc_ldfs` WRITE;
/*!40000 ALTER TABLE `iqc_ldfs` DISABLE KEYS */;
/*!40000 ALTER TABLE `iqc_ldfs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `iqc_pkgs`
--

DROP TABLE IF EXISTS `iqc_pkgs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iqc_pkgs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `batch_number` varchar(255) DEFAULT NULL,
  `submitting_unit` varchar(255) DEFAULT NULL,
  `inspection_basis` varchar(255) DEFAULT NULL,
  `batch_qty` varchar(255) DEFAULT NULL,
  `request_inspection_date` date DEFAULT NULL,
  `report_date` date DEFAULT NULL,
  `record_content` text,
  `conclusion` varchar(255) DEFAULT NULL,
  `remark` text,
  `reviewer_id` int DEFAULT NULL,
  `inspector_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `iqc_pkgs`
--

LOCK TABLES `iqc_pkgs` WRITE;
/*!40000 ALTER TABLE `iqc_pkgs` DISABLE KEYS */;
/*!40000 ALTER TABLE `iqc_pkgs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `iqc_raw_lines`
--

DROP TABLE IF EXISTS `iqc_raw_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iqc_raw_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `raw_id` bigint DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `content_percent` varchar(255) DEFAULT NULL,
  `m_value` decimal(12,2) DEFAULT '0.00',
  `a_r_value` decimal(12,2) DEFAULT '0.00',
  `x_percent` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_iqc_raw_lines_on_raw_id` (`raw_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `iqc_raw_lines`
--

LOCK TABLES `iqc_raw_lines` WRITE;
/*!40000 ALTER TABLE `iqc_raw_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `iqc_raw_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `iqc_raws`
--

DROP TABLE IF EXISTS `iqc_raws`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iqc_raws` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `supplier_id` varchar(255) DEFAULT NULL,
  `supplier_name` varchar(255) DEFAULT NULL,
  `batch_number` varchar(255) DEFAULT NULL,
  `inspection_qty` varchar(255) DEFAULT NULL,
  `request_inspection_date` date DEFAULT NULL,
  `inspection_date` date DEFAULT NULL,
  `inspection_basis` varchar(255) DEFAULT NULL,
  `std_sample_m` decimal(12,2) DEFAULT '0.00',
  `std_sample_x` decimal(12,2) DEFAULT '0.00',
  `std_sample_a_r_1` decimal(12,2) DEFAULT '0.00',
  `std_sample_a_r_2` decimal(12,2) DEFAULT '0.00',
  `ph_value` varchar(255) DEFAULT NULL,
  `moisture_percent` varchar(255) DEFAULT NULL,
  `other_indicators` varchar(255) DEFAULT NULL,
  `conclusion` varchar(255) DEFAULT NULL,
  `issue_ncr` tinyint(1) DEFAULT NULL,
  `notes` text,
  `inspector_id` int DEFAULT NULL,
  `reviewer_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `pur_contract_id` int DEFAULT NULL COMMENT '关联采购合同(pur_contracts)',
  `pur_collection_id` int DEFAULT NULL COMMENT '关联采购明细(pur_collections)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `iqc_raws`
--

LOCK TABLES `iqc_raws` WRITE;
/*!40000 ALTER TABLE `iqc_raws` DISABLE KEYS */;
/*!40000 ALTER TABLE `iqc_raws` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL COMMENT '操作用户',
  `event` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '事件',
  `category` int DEFAULT NULL COMMENT '类别',
  `ip` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '来源',
  `result` tinyint(1) DEFAULT '1' COMMENT '结果,1成功、0失败',
  `describe` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '描述',
  `modules` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '模块',
  `core` tinyint(1) DEFAULT '0' COMMENT '是否核心模块,1核心、0非核心',
  `check_digit` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '校验位',
  `checked` tinyint(1) DEFAULT '0' COMMENT '是否被篡改，1被篡改',
  `created_at` datetime(6) DEFAULT NULL COMMENT '创建于',
  `record_id` int DEFAULT NULL,
  `record_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_logs_on_record_id_and_record_type` (`record_id`,`record_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs`
--

LOCK TABLES `logs` WRITE;
/*!40000 ALTER TABLE `logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mat_attribute_lines`
--

DROP TABLE IF EXISTS `mat_attribute_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mat_attribute_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `attribute_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `values` json DEFAULT NULL,
  `value_ids` json DEFAULT NULL,
  `sort` float DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mat_attribute_lines_on_attribute_id` (`attribute_id`),
  KEY `index_mat_attribute_lines_on_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mat_attribute_lines`
--

LOCK TABLES `mat_attribute_lines` WRITE;
/*!40000 ALTER TABLE `mat_attribute_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `mat_attribute_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mat_attributes`
--

DROP TABLE IF EXISTS `mat_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mat_attributes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `is_variant` tinyint(1) DEFAULT NULL,
  `display_type` varchar(255) DEFAULT NULL,
  `sort` float DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mat_attributes_on_company_id` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mat_attributes`
--

LOCK TABLES `mat_attributes` WRITE;
/*!40000 ALTER TABLE `mat_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `mat_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mat_combo_options`
--

DROP TABLE IF EXISTS `mat_combo_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mat_combo_options` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `combo_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `price` decimal(12,2) DEFAULT '0.00',
  `extra_price` decimal(12,2) DEFAULT '0.00',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mat_combo_options`
--

LOCK TABLES `mat_combo_options` WRITE;
/*!40000 ALTER TABLE `mat_combo_options` DISABLE KEYS */;
/*!40000 ALTER TABLE `mat_combo_options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mat_combos`
--

DROP TABLE IF EXISTS `mat_combos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mat_combos` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `min` int DEFAULT NULL,
  `max` int DEFAULT NULL,
  `price` decimal(12,2) DEFAULT '0.00',
  `discount` int DEFAULT NULL,
  `description` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `py` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mat_combos_on_company_id` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mat_combos`
--

LOCK TABLES `mat_combos` WRITE;
/*!40000 ALTER TABLE `mat_combos` DISABLE KEYS */;
/*!40000 ALTER TABLE `mat_combos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mat_items`
--

DROP TABLE IF EXISTS `mat_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mat_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `labels` json DEFAULT NULL,
  `custom_fields` json DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `pinyin` varchar(255) DEFAULT NULL,
  `barcode` varchar(255) DEFAULT NULL,
  `type_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `price` decimal(12,2) DEFAULT '0.00',
  `cost_price` decimal(12,2) DEFAULT '0.00',
  `market_price` decimal(12,2) DEFAULT '0.00',
  `description` text,
  `uom_id` int DEFAULT NULL,
  `uom_po_id` int DEFAULT NULL,
  `sale_tax_id` int DEFAULT NULL,
  `purchase_tax_id` int DEFAULT NULL,
  `is_sale` tinyint(1) DEFAULT NULL,
  `is_purchase` tinyint(1) DEFAULT NULL,
  `is_manufacture` tinyint(1) DEFAULT NULL,
  `is_stock` tinyint(1) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `value_id` int DEFAULT NULL,
  `sku` varchar(255) DEFAULT NULL,
  `weight` decimal(12,2) DEFAULT '0.00',
  `volume` decimal(12,2) DEFAULT '0.00',
  `qty_onhand` int DEFAULT NULL,
  `qty_available` int DEFAULT NULL,
  `qty_incoming` int DEFAULT NULL,
  `qty_outgoing` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `track_inventory` tinyint(1) DEFAULT '0',
  `track_inventory_type` varchar(255) DEFAULT NULL,
  `name_en` varchar(255) DEFAULT NULL COMMENT '英文名称',
  `length` decimal(12,2) DEFAULT '0.00',
  `width` decimal(12,2) DEFAULT '0.00',
  `height` decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `index_mat_items_on_category_id` (`category_id`),
  KEY `index_mat_items_on_company_id` (`company_id`),
  KEY `index_mat_items_on_product_id` (`product_id`),
  KEY `index_mat_items_on_type_id` (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mat_items`
--

LOCK TABLES `mat_items` WRITE;
/*!40000 ALTER TABLE `mat_items` DISABLE KEYS */;
INSERT INTO `mat_items` VALUES (1,NULL,NULL,1,NULL,NULL,'dd',NULL,'MAT-260323-0001','dd','dd','BC17742799293085095',1,6,0.00,0.00,0.00,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,1,1,NULL,'MAT-260323-0001-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:32:09.286970','2026-03-23 23:32:09.286970',0,NULL,NULL,0.00,0.00,0.00),(2,NULL,NULL,NULL,NULL,NULL,'GQ-100-001','http://www.ntgqbz.com/uploadfile/202412/2b9e4e69a519ed2.jpg','MAT-260323-0002','GQ 100 001','GQ 100 001','BC17742805788572551',NULL,7,0.00,0.00,0.00,'http://www.ntgqbz.com/product/Mother_child_bottle/100ml/28.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,'GQ-100-001-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:58.807425','2026-03-23 23:42:58.807425',0,NULL,NULL,0.00,0.00,0.00),(3,NULL,NULL,NULL,NULL,NULL,'GQ-1L-双口子母瓶','http://www.ntgqbz.com/uploadfile/202508/b963788a035cbf2.jpg','MAT-260323-0003','GQ 1L  skzmp','GQ 1L  shuang kou zi mu ping','BC17742805789025934',NULL,7,0.00,0.00,0.00,'http://www.ntgqbz.com/product/Mother_child_bottle/1L/109.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,3,NULL,'GQ-1L-双口子母瓶-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:58.888078','2026-03-23 23:42:58.888078',0,NULL,NULL,0.00,0.00,0.00),(4,NULL,NULL,NULL,NULL,NULL,'GQ-200-001','http://www.ntgqbz.com/uploadfile/202411/eec6d8cbfdadf87.jpg','MAT-260323-0004','GQ 200 001','GQ 200 001','BC17742805789766680',NULL,7,0.00,0.00,0.00,'http://www.ntgqbz.com/product/Mother_child_bottle/200ml/46.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,4,NULL,'GQ-200-001-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:58.934378','2026-03-23 23:42:58.934378',0,NULL,NULL,0.00,0.00,0.00),(5,NULL,NULL,NULL,NULL,NULL,'GQ-500-200双口子母瓶','http://www.ntgqbz.com/uploadfile/202509/c9e61aab5bdb5c7.jpg','MAT-260323-0005','GQ 500 200 skzmp','GQ 500 200 shuang kou zi mu ping','BC17742805790511296',NULL,7,0.00,0.00,0.00,'http://www.ntgqbz.com/product/Mother_child_bottle/500ml/138.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5,NULL,'GQ-500-200双口子母瓶-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.029151','2026-03-23 23:42:59.029151',0,NULL,NULL,0.00,0.00,0.00),(6,NULL,NULL,NULL,NULL,NULL,'GQ-1000-102','http://www.ntgqbz.com/uploadfile/202508/33e11b8c68c4ecd.jpg','MAT-260323-0006','GQ 1000 102','GQ 1000 102','BC17742805791148480',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/1000ml/135.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,6,NULL,'GQ-1000-102-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.104267','2026-03-23 23:42:59.104267',0,NULL,NULL,0.00,0.00,0.00),(7,NULL,NULL,NULL,NULL,NULL,'GQ-1000-103','http://www.ntgqbz.com/uploadfile/202512/3d7b4dedbceacdd.jpg','MAT-260323-0007','GQ 1000 103','GQ 1000 103','BC17742805791546063',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/1000ml/142.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,7,NULL,'GQ-1000-103-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.149378','2026-03-23 23:42:59.149378',0,NULL,NULL,0.00,0.00,0.00),(8,NULL,NULL,NULL,NULL,NULL,'GQ-1000-106','http://www.ntgqbz.com/uploadfile/202603/3c517e988bf7ea4.png','MAT-260323-0008','GQ 1000 106','GQ 1000 106','BC17742805791864723',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/1000ml/150.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,8,NULL,'GQ-1000-106-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.177025','2026-03-23 23:42:59.177025',0,NULL,NULL,0.00,0.00,0.00),(9,NULL,NULL,NULL,NULL,NULL,'GQ-1000-101','http://www.ntgqbz.com/uploadfile/202411/f285823548cf665.jpg','MAT-260323-0009','GQ 1000 101','GQ 1000 101','BC17742805792235676',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/1000ml/29.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,9,NULL,'GQ-1000-101-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.217070','2026-03-23 23:42:59.217070',0,NULL,NULL,0.00,0.00,0.00),(10,NULL,NULL,NULL,NULL,NULL,'GQ-1000-104','http://www.ntgqbz.com/uploadfile/202411/8a48bb6a0fdefff.jpg','MAT-260323-0010','GQ 1000 104','GQ 1000 104','BC17742805792531392',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/1000ml/68.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,10,NULL,'GQ-1000-104-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.238910','2026-03-23 23:42:59.238910',0,NULL,NULL,0.00,0.00,0.00),(11,NULL,NULL,NULL,NULL,NULL,'GQ-100-101','http://www.ntgqbz.com/uploadfile/202507/189f511ce64d4f9.jpg','MAT-260323-0011','GQ 100 101','GQ 100 101','BC17742805793091223',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/100ml/132.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,11,NULL,'GQ-100-101-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.291786','2026-03-23 23:42:59.291786',0,NULL,NULL,0.00,0.00,0.00),(12,NULL,NULL,NULL,NULL,NULL,'GQ-250-103','http://www.ntgqbz.com/uploadfile/202504/c860b1d0e1c6ed9.jpg','MAT-260323-0012','GQ 250 103','GQ 250 103','BC17742805793502705',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/250ml/125.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,12,NULL,'GQ-250-103-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.339620','2026-03-23 23:42:59.339620',0,NULL,NULL,0.00,0.00,0.00),(13,NULL,NULL,NULL,NULL,NULL,'GQ-250-101','http://www.ntgqbz.com/uploadfile/202411/a3963690de45064.jpg','MAT-260323-0013','GQ 250 101','GQ 250 101','BC17742805795257859',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/250ml/44.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,13,NULL,'GQ-250-101-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.376427','2026-03-23 23:42:59.376427',0,NULL,NULL,0.00,0.00,0.00),(14,NULL,NULL,NULL,NULL,NULL,'GQ-250-102','http://www.ntgqbz.com/uploadfile/202501/eb0b7255acad6db.jpg','MAT-260323-0014','GQ 250 102','GQ 250 102','BC17742805796628038',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/250ml/82.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,14,NULL,'GQ-250-102-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.603009','2026-03-23 23:42:59.603009',0,NULL,NULL,0.00,0.00,0.00),(15,NULL,NULL,NULL,NULL,NULL,'GQ-400-101','http://www.ntgqbz.com/uploadfile/202504/3c927111ccd8076.jpg','MAT-260323-0015','GQ 400 101','GQ 400 101','BC17742805797047322',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/400ml/126.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,15,NULL,'GQ-400-101-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.691210','2026-03-23 23:42:59.691210',0,NULL,NULL,0.00,0.00,0.00),(16,NULL,NULL,NULL,NULL,NULL,'GQ-500-103','http://www.ntgqbz.com/uploadfile/202507/6978bb3988c490f.jpg','MAT-260323-0016','GQ 500 103','GQ 500 103','BC17742805797448730',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/500ml/134.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,16,NULL,'GQ-500-103-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.725148','2026-03-23 23:42:59.725148',0,NULL,NULL,0.00,0.00,0.00),(17,NULL,NULL,NULL,NULL,NULL,'GQ-500-101','http://www.ntgqbz.com/uploadfile/202411/8f08a3b1409a95.jpg','MAT-260323-0017','GQ 500 101','GQ 500 101','BC17742805797649038',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/500ml/75.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,17,NULL,'GQ-500-101-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.757848','2026-03-23 23:42:59.757848',0,NULL,NULL,0.00,0.00,0.00),(18,NULL,NULL,NULL,NULL,NULL,'GQ-800-101','http://www.ntgqbz.com/uploadfile/202503/25973dcfc009.jpg','MAT-260323-0018','GQ 800 101','GQ 800 101','BC17742805799371481',NULL,8,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/800ml/123.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,18,NULL,'GQ-800-101-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.872755','2026-03-23 23:42:59.872755',0,NULL,NULL,0.00,0.00,0.00),(19,NULL,NULL,NULL,NULL,NULL,'GQ-1000-008','http://www.ntgqbz.com/uploadfile/202412/643c604cfccc.jpg','MAT-260323-0019','GQ 1000 008','GQ 1000 008','BC17742805801389502',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/10.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,19,NULL,'GQ-1000-008-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.091844','2026-03-23 23:43:00.091844',0,NULL,NULL,0.00,0.00,0.00),(20,NULL,NULL,NULL,NULL,NULL,'GQ-1000-011','http://www.ntgqbz.com/uploadfile/202412/ef2c90479ed15.jpg','MAT-260323-0020','GQ 1000 011','GQ 1000 011','BC17742805803561969',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/12.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,20,NULL,'GQ-1000-011-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.319976','2026-03-23 23:43:00.319976',0,NULL,NULL,0.00,0.00,0.00),(21,NULL,NULL,NULL,NULL,NULL,'GQ-1000-012','http://www.ntgqbz.com/uploadfile/202412/39f66706bf0f838.jpg','MAT-260323-0021','GQ 1000 012','GQ 1000 012','BC17742805806067195',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/13.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,21,NULL,'GQ-1000-012-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.475747','2026-03-23 23:43:00.475747',0,NULL,NULL,0.00,0.00,0.00),(22,NULL,NULL,NULL,NULL,NULL,'GQ-1000-020（专用瓶）','http://www.ntgqbz.com/uploadfile/202507/2769ed6607aa152.jpg','MAT-260323-0022','GQ 1000 020  zyp','GQ 1000 020  zhuan yong ping','BC17742805806239268',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/133.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,22,NULL,'GQ-1000-020（专用瓶）-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.614287','2026-03-23 23:43:00.614287',0,NULL,NULL,0.00,0.00,0.00),(23,NULL,NULL,NULL,NULL,NULL,'GQ-1000-013','http://www.ntgqbz.com/uploadfile/202503/b8ce94517d1d959.jpg','MAT-260323-0023','GQ 1000 013','GQ 1000 013','BC17742805806412198',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/14.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,23,NULL,'GQ-1000-013-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.633842','2026-03-23 23:43:00.633842',0,NULL,NULL,0.00,0.00,0.00),(24,NULL,NULL,NULL,NULL,NULL,'GQ-1000-014','http://www.ntgqbz.com/uploadfile/202412/89dacd08cd45902.jpg','MAT-260323-0024','GQ 1000 014','GQ 1000 014','BC17742805807063515',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/16.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,24,NULL,'GQ-1000-014-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.695089','2026-03-23 23:43:00.695089',0,NULL,NULL,0.00,0.00,0.00),(25,NULL,NULL,NULL,NULL,NULL,'GQ-1000-015','http://www.ntgqbz.com/uploadfile/202412/9eedccf12a9b8f2.jpg','MAT-260323-0025','GQ 1000 015','GQ 1000 015','BC17742805807359952',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/17.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,25,NULL,'GQ-1000-015-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.725741','2026-03-23 23:43:00.725741',0,NULL,NULL,0.00,0.00,0.00),(26,NULL,NULL,NULL,NULL,NULL,'GQ-1000-016','http://www.ntgqbz.com/uploadfile/202412/5dd3890eb54ad9d.jpg','MAT-260323-0026','GQ 1000 016','GQ 1000 016','BC17742805807559882',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/18.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,26,NULL,'GQ-1000-016-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.745802','2026-03-23 23:43:00.745802',0,NULL,NULL,0.00,0.00,0.00),(27,NULL,NULL,NULL,NULL,NULL,'GQ-1000-017','http://www.ntgqbz.com/uploadfile/202412/66cafa0b8c989cd.jpg','MAT-260323-0027','GQ 1000 017','GQ 1000 017','BC17742805807929290',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/19.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,27,NULL,'GQ-1000-017-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.778084','2026-03-23 23:43:00.778084',0,NULL,NULL,0.00,0.00,0.00),(28,NULL,NULL,NULL,NULL,NULL,'GQ-1000-019','http://www.ntgqbz.com/uploadfile/202412/33f27f63a6bfb53.jpg','MAT-260323-0028','GQ 1000 019','GQ 1000 019','BC17742805808218886',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/21.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,28,NULL,'GQ-1000-019-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.810008','2026-03-23 23:43:00.810008',0,NULL,NULL,0.00,0.00,0.00),(29,NULL,NULL,NULL,NULL,NULL,'GQ-1000-021（专用瓶）','http://www.ntgqbz.com/uploadfile/202412/6451c0aef7e2771.jpg','MAT-260323-0029','GQ 1000 021  zyp','GQ 1000 021  zhuan yong ping','BC17742805808595793',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/23.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,29,NULL,'GQ-1000-021（专用瓶）-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.837736','2026-03-23 23:43:00.837736',0,NULL,NULL,0.00,0.00,0.00),(30,NULL,NULL,NULL,NULL,NULL,'GQ-1000-022','http://www.ntgqbz.com/uploadfile/202412/72f2a0fed629287.jpg','MAT-260323-0030','GQ 1000 022','GQ 1000 022','BC17742805808788031',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/24.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,30,NULL,'GQ-1000-022-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.872163','2026-03-23 23:43:00.872163',0,NULL,NULL,0.00,0.00,0.00),(31,NULL,NULL,NULL,NULL,NULL,'GQ-1000-023','http://www.ntgqbz.com/uploadfile/202412/338625f04e5f10c.jpg','MAT-260323-0031','GQ 1000 023','GQ 1000 023','BC17742805809386116',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/26.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,31,NULL,'GQ-1000-023-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.926074','2026-03-23 23:43:00.926074',0,NULL,NULL,0.00,0.00,0.00),(32,NULL,NULL,NULL,NULL,NULL,'GQ-1000-001','http://www.ntgqbz.com/uploadfile/202412/e94afcf36623651.jpg','MAT-260323-0032','GQ 1000 001','GQ 1000 001','BC17742805809749272',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/4.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,32,NULL,'GQ-1000-001-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.968023','2026-03-23 23:43:00.968023',0,NULL,NULL,0.00,0.00,0.00),(33,NULL,NULL,NULL,NULL,NULL,'GQ-1000-002','http://www.ntgqbz.com/uploadfile/202412/c237f488b2969dc.jpg','MAT-260323-0033','GQ 1000 002','GQ 1000 002','BC17742805810335336',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/5.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,33,NULL,'GQ-1000-002-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.010318','2026-03-23 23:43:01.010318',0,NULL,NULL,0.00,0.00,0.00),(34,NULL,NULL,NULL,NULL,NULL,'GQ-1000-003','http://www.ntgqbz.com/uploadfile/202412/e298a8aed7bdc90.jpg','MAT-260323-0034','GQ 1000 003','GQ 1000 003','BC17742805810561275',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/6.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,34,NULL,'GQ-1000-003-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.048483','2026-03-23 23:43:01.048483',0,NULL,NULL,0.00,0.00,0.00),(35,NULL,NULL,NULL,NULL,NULL,'GQ-1000-004','http://www.ntgqbz.com/uploadfile/202412/eec3ae0ad5ec2ec.jpg','MAT-260323-0035','GQ 1000 004','GQ 1000 004','BC17742805810903398',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/7.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,35,NULL,'GQ-1000-004-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.077577','2026-03-23 23:43:01.077577',0,NULL,NULL,0.00,0.00,0.00),(36,NULL,NULL,NULL,NULL,NULL,'GQ-1000-009','http://www.ntgqbz.com/uploadfile/202412/947724b565c2839.jpg','MAT-260323-0036','GQ 1000 009','GQ 1000 009','BC17742805811092505',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/79.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,36,NULL,'GQ-1000-009-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.104644','2026-03-23 23:43:01.104644',0,NULL,NULL,0.00,0.00,0.00),(37,NULL,NULL,NULL,NULL,NULL,'GQ-1000-005','http://www.ntgqbz.com/uploadfile/202501/9e571c15177ad.jpg','MAT-260323-0037','GQ 1000 005','GQ 1000 005','BC17742805811381844',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/8.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,37,NULL,'GQ-1000-005-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.127253','2026-03-23 23:43:01.127253',0,NULL,NULL,0.00,0.00,0.00),(38,NULL,NULL,NULL,NULL,NULL,'GQ-1000-007','http://www.ntgqbz.com/uploadfile/202412/696e3698a0b0816.jpg','MAT-260323-0038','GQ 1000 007','GQ 1000 007','BC17742805811533525',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/9.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,38,NULL,'GQ-1000-007-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.146458','2026-03-23 23:43:01.146458',0,NULL,NULL,0.00,0.00,0.00),(39,NULL,NULL,NULL,NULL,NULL,'GQ-100-011','http://www.ntgqbz.com/uploadfile/202503/63fabf6f03c7d03.jpg','MAT-260323-0039','GQ 100 011','GQ 100 011','BC17742805811712167',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/100ml_150ml/112.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,39,NULL,'GQ-100-011-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.168057','2026-03-23 23:43:01.168057',0,NULL,NULL,0.00,0.00,0.00),(40,NULL,NULL,NULL,NULL,NULL,'GQ-100-002','http://www.ntgqbz.com/uploadfile/202411/551ea889ee5819a.jpg','MAT-260323-0040','GQ 100 002','GQ 100 002','BC17742805812053014',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/100ml_150ml/30.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,40,NULL,'GQ-100-002-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.185122','2026-03-23 23:43:01.185122',0,NULL,NULL,0.00,0.00,0.00),(41,NULL,NULL,NULL,NULL,NULL,'GQ-100-006','http://www.ntgqbz.com/uploadfile/202411/2b7fd2c52ca2e70.jpg','MAT-260323-0041','GQ 100 006','GQ 100 006','BC17742805812398605',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/100ml_150ml/33.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,41,NULL,'GQ-100-006-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.229939','2026-03-23 23:43:01.229939',0,NULL,NULL,0.00,0.00,0.00),(42,NULL,NULL,NULL,NULL,NULL,'GQ-100-008','http://www.ntgqbz.com/uploadfile/202412/7524cb0492592ed.jpg','MAT-260323-0042','GQ 100 008','GQ 100 008','BC17742805812661830',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/100ml_150ml/35.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,42,NULL,'GQ-100-008-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.261402','2026-03-23 23:43:01.261402',0,NULL,NULL,0.00,0.00,0.00),(43,NULL,NULL,NULL,NULL,NULL,'GQ-150-001','http://www.ntgqbz.com/uploadfile/202412/8757e2e49e2818a.jpg','MAT-260323-0043','GQ 150 001','GQ 150 001','BC17742805813422259',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/100ml_150ml/78.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,43,NULL,'GQ-150-001-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.328191','2026-03-23 23:43:01.328191',0,NULL,NULL,0.00,0.00,0.00),(44,NULL,NULL,NULL,NULL,NULL,'GQ-10L-204','http://www.ntgqbz.com/uploadfile/202505/c9cc5f839742d34.jpg','MAT-260323-0044','GQ 10L 204','GQ 10L 204','BC17742805813735532',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/10L/128.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,44,NULL,'GQ-10L-204-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.360475','2026-03-23 23:43:01.360475',0,NULL,NULL,0.00,0.00,0.00),(45,NULL,NULL,NULL,NULL,NULL,'GQ-10L-205','http://www.ntgqbz.com/uploadfile/202505/1c6a2b5f4264b2d.jpg','MAT-260323-0045','GQ 10L 205','GQ 10L 205','BC17742805813893413',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/10L/129.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,45,NULL,'GQ-10L-205-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.379761','2026-03-23 23:43:01.379761',0,NULL,NULL,0.00,0.00,0.00),(46,NULL,NULL,NULL,NULL,NULL,'GQ-10L-201','http://www.ntgqbz.com/uploadfile/202411/5b4772b2d7cdbeb.jpg','MAT-260323-0046','GQ 10L 201','GQ 10L 201','BC17742805814081971',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/10L/61.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,46,NULL,'GQ-10L-201-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.394259','2026-03-23 23:43:01.394259',0,NULL,NULL,0.00,0.00,0.00),(47,NULL,NULL,NULL,NULL,NULL,'GQ-10L-203','http://www.ntgqbz.com/uploadfile/202411/bb7d9b8d69bbc91.jpg','MAT-260323-0047','GQ 10L 203','GQ 10L 203','BC17742805814247640',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/10L/63.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,47,NULL,'GQ-10L-203-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.421122','2026-03-23 23:43:01.421122',0,NULL,NULL,0.00,0.00,0.00),(48,NULL,NULL,NULL,NULL,NULL,'GQ-10L-202','http://www.ntgqbz.com/uploadfile/202501/ea5bd11199aabb8.jpg','MAT-260323-0048','GQ 10L 202','GQ 10L 202','BC17742805814409554',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/10L/83.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,48,NULL,'GQ-10L-202-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.436610','2026-03-23 23:43:01.436610',0,NULL,NULL,0.00,0.00,0.00),(49,NULL,NULL,NULL,NULL,NULL,'GQ-200-006','http://www.ntgqbz.com/uploadfile/202511/6df4402a3751191.jpg','MAT-260323-0049','GQ 200 006','GQ 200 006','BC17742805814504306',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/200ml/139.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,49,NULL,'GQ-200-006-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.447271','2026-03-23 23:43:01.447271',0,NULL,NULL,0.00,0.00,0.00),(50,NULL,NULL,NULL,NULL,NULL,'GQ-200-002','http://www.ntgqbz.com/uploadfile/202412/c9596732bece9.jpg','MAT-260323-0050','GQ 200 002','GQ 200 002','BC17742805814845710',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/200ml/40.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,'GQ-200-002-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.472735','2026-03-23 23:43:01.472735',0,NULL,NULL,0.00,0.00,0.00),(51,NULL,NULL,NULL,NULL,NULL,'GQ-200-003','http://www.ntgqbz.com/uploadfile/202411/19981aec1eef3f2.jpg','MAT-260323-0051','GQ 200 003','GQ 200 003','BC17742805815046115',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/200ml/41.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,51,NULL,'GQ-200-003-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.492830','2026-03-23 23:43:01.492830',0,NULL,NULL,0.00,0.00,0.00),(52,NULL,NULL,NULL,NULL,NULL,'GQ-200-004','http://www.ntgqbz.com/uploadfile/202411/a9fcc64b3711876.jpg','MAT-260323-0052','GQ 200 004','GQ 200 004','BC17742805815151265',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/200ml/43.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,52,NULL,'GQ-200-004-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.511687','2026-03-23 23:43:01.511687',0,NULL,NULL,0.00,0.00,0.00),(53,NULL,NULL,NULL,NULL,NULL,'GQ-200-005','http://www.ntgqbz.com/uploadfile/202501/c84ad4ec7c024bf.jpg','MAT-260323-0053','GQ 200 005','GQ 200 005','BC17742805815241628',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/200ml/84.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,53,NULL,'GQ-200-005-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.521431','2026-03-23 23:43:01.521431',0,NULL,NULL,0.00,0.00,0.00),(54,NULL,NULL,NULL,NULL,NULL,'GQ-250-005','http://www.ntgqbz.com/uploadfile/202411/0d1865b93da75.jpg','MAT-260323-0054','GQ 250 005','GQ 250 005','BC17742805815433779',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/11.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,54,NULL,'GQ-250-005-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.539716','2026-03-23 23:43:01.539716',0,NULL,NULL,0.00,0.00,0.00),(55,NULL,NULL,NULL,NULL,NULL,'GQ-250-011','http://www.ntgqbz.com/uploadfile/202503/9d5d600721174d8.jpg','MAT-260323-0055','GQ 250 011','GQ 250 011','BC17742805815651149',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/114.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,55,NULL,'GQ-250-011-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.562424','2026-03-23 23:43:01.562424',0,NULL,NULL,0.00,0.00,0.00),(56,NULL,NULL,NULL,NULL,NULL,'GQ-250-012','http://www.ntgqbz.com/uploadfile/202511/b0a321f67e9f7aa.jpg','MAT-260323-0056','GQ 250 012','GQ 250 012','BC17742805815869925',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/140.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,56,NULL,'GQ-250-012-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.575732','2026-03-23 23:43:01.575732',0,NULL,NULL,0.00,0.00,0.00),(57,NULL,NULL,NULL,NULL,NULL,'GQ-250-006','http://www.ntgqbz.com/uploadfile/202411/26083be7ca0de5b.jpg','MAT-260323-0057','GQ 250 006','GQ 250 006','BC17742805816098314',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/32.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,57,NULL,'GQ-250-006-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.602004','2026-03-23 23:43:01.602004',0,NULL,NULL,0.00,0.00,0.00),(58,NULL,NULL,NULL,NULL,NULL,'GQ-250-007','http://www.ntgqbz.com/uploadfile/202412/01b21855fbd5535.jpg','MAT-260323-0058','GQ 250 007','GQ 250 007','BC17742805816367595',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/34.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,58,NULL,'GQ-250-007-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.622864','2026-03-23 23:43:01.622864',0,NULL,NULL,0.00,0.00,0.00),(59,NULL,NULL,NULL,NULL,NULL,'GQ-250-009','http://www.ntgqbz.com/uploadfile/202411/2f385e7700b661a.jpg','MAT-260323-0059','GQ 250 009','GQ 250 009','BC17742805816652062',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/37.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,59,NULL,'GQ-250-009-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.651479','2026-03-23 23:43:01.651479',0,NULL,NULL,0.00,0.00,0.00),(60,NULL,NULL,NULL,NULL,NULL,'GQ-250-010','http://www.ntgqbz.com/uploadfile/202411/3ff51e3fb0a8.jpg','MAT-260323-0060','GQ 250 010','GQ 250 010','BC17742805817046820',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/42.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,60,NULL,'GQ-250-010-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.687849','2026-03-23 23:43:01.687849',0,NULL,NULL,0.00,0.00,0.00),(61,NULL,NULL,NULL,NULL,NULL,'GQ-250-001','http://www.ntgqbz.com/uploadfile/202412/7d9148dd046a8a.jpg','MAT-260323-0061','GQ 250 001','GQ 250 001','BC17742805817441238',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/47.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,61,NULL,'GQ-250-001-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.727809','2026-03-23 23:43:01.727809',0,NULL,NULL,0.00,0.00,0.00),(62,NULL,NULL,NULL,NULL,NULL,'GQ-250-002','http://www.ntgqbz.com/uploadfile/202412/50c3c7a0d4c8.jpg','MAT-260323-0062','GQ 250 002','GQ 250 002','BC17742805817852732',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/50.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,62,NULL,'GQ-250-002-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.774613','2026-03-23 23:43:01.774613',0,NULL,NULL,0.00,0.00,0.00),(63,NULL,NULL,NULL,NULL,NULL,'GQ-250-004','http://www.ntgqbz.com/uploadfile/202411/68a3f75f08f532b.jpg','MAT-260323-0063','GQ 250 004','GQ 250 004','BC17742805817996868',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/51.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,63,NULL,'GQ-250-004-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.793147','2026-03-23 23:43:01.793147',0,NULL,NULL,0.00,0.00,0.00),(64,NULL,NULL,NULL,NULL,NULL,'GQ-250-008','http://www.ntgqbz.com/uploadfile/202412/f2595269ca0e5c4.jpg','MAT-260323-0064','GQ 250 008','GQ 250 008','BC17742805818194737',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/73.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,64,NULL,'GQ-250-008-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.811965','2026-03-23 23:43:01.811965',0,NULL,NULL,0.00,0.00,0.00),(65,NULL,NULL,NULL,NULL,NULL,'GQ-250-003','http://www.ntgqbz.com/uploadfile/202501/17e02ca8a170.jpg','MAT-260323-0065','GQ 250 003','GQ 250 003','BC17742805818345063',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/88.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,65,NULL,'GQ-250-003-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.829419','2026-03-23 23:43:01.829419',0,NULL,NULL,0.00,0.00,0.00),(66,NULL,NULL,NULL,NULL,NULL,'GQ-2L-201','http://www.ntgqbz.com/uploadfile/202412/14420351bd8391e.jpg','MAT-260323-0066','GQ 2L 201','GQ 2L 201','BC17742805818575885',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/2L/36.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,66,NULL,'GQ-2L-201-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.852813','2026-03-23 23:43:01.852813',0,NULL,NULL,0.00,0.00,0.00),(67,NULL,NULL,NULL,NULL,NULL,'GQ-2.5L-201','http://www.ntgqbz.com/uploadfile/202503/2a4e64c465b3d21.jpg','MAT-260323-0067','GQ 2 5L 201','GQ 2 5L 201','BC17742805818735348',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/2_5L/117.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,67,NULL,'GQ-2.5L-201-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.867555','2026-03-23 23:43:01.867555',0,NULL,NULL,0.00,0.00,0.00),(68,NULL,NULL,NULL,NULL,NULL,'GQ-3L-202','http://www.ntgqbz.com/uploadfile/202602/c351831ea52d0b1.png','MAT-260323-0068','GQ 3L 202','GQ 3L 202','BC17742805818941060',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/3L/149.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,68,NULL,'GQ-3L-202-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.890394','2026-03-23 23:43:01.890394',0,NULL,NULL,0.00,0.00,0.00),(69,NULL,NULL,NULL,NULL,NULL,'GQ-3L-201','http://www.ntgqbz.com/uploadfile/202412/58a3c0357b84e6c.jpg','MAT-260323-0069','GQ 3L 201','GQ 3L 201','BC17742805819208111',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/3L/49.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,69,NULL,'GQ-3L-201-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.903625','2026-03-23 23:43:01.903625',0,NULL,NULL,0.00,0.00,0.00),(70,NULL,NULL,NULL,NULL,NULL,'GQ-3.5L-201','http://www.ntgqbz.com/uploadfile/202503/8bd51472e2dbe27.jpg','MAT-260323-0070','GQ 3 5L 201','GQ 3 5L 201','BC17742805819416399',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/3_5L/118.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,70,NULL,'GQ-3.5L-201-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.937286','2026-03-23 23:43:01.937286',0,NULL,NULL,0.00,0.00,0.00),(71,NULL,NULL,NULL,NULL,NULL,'GQ-3.5L-202','http://www.ntgqbz.com/uploadfile/202412/501778f22559011.jpg','MAT-260323-0071','GQ 3 5L 202','GQ 3 5L 202','BC17742805819567387',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/3_5L/38.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,71,NULL,'GQ-3.5L-202-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.953155','2026-03-23 23:43:01.953155',0,NULL,NULL,0.00,0.00,0.00),(72,NULL,NULL,NULL,NULL,NULL,'GQ-400-001','http://www.ntgqbz.com/uploadfile/202412/740beecc0258306.jpg','MAT-260323-0072','GQ 400 001','GQ 400 001','BC17742805819708890',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/400ml/48.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,72,NULL,'GQ-400-001-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.963201','2026-03-23 23:43:01.963201',0,NULL,NULL,0.00,0.00,0.00),(73,NULL,NULL,NULL,NULL,NULL,'GQ-4L-202','http://www.ntgqbz.com/uploadfile/202503/66d6413cace5f.jpg','MAT-260323-0073','GQ 4L 202','GQ 4L 202','BC17742805819886361',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/4L/116.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,73,NULL,'GQ-4L-202-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.980272','2026-03-23 23:43:01.980272',0,NULL,NULL,0.00,0.00,0.00),(74,NULL,NULL,NULL,NULL,NULL,'GQ-4L-205','http://www.ntgqbz.com/uploadfile/202505/27b529c5649af.jpg','MAT-260323-0074','GQ 4L 205','GQ 4L 205','BC17742805820121062',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/4L/130.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,74,NULL,'GQ-4L-205-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.006301','2026-03-23 23:43:02.006301',0,NULL,NULL,0.00,0.00,0.00),(75,NULL,NULL,NULL,NULL,NULL,'GQ-4L-201','http://www.ntgqbz.com/uploadfile/202412/32eff6475b20b4e.jpg','MAT-260323-0075','GQ 4L 201','GQ 4L 201','BC17742805820436406',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/4L/52.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,75,NULL,'GQ-4L-201-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.025731','2026-03-23 23:43:02.025731',0,NULL,NULL,0.00,0.00,0.00),(76,NULL,NULL,NULL,NULL,NULL,'GQ-4L-203','http://www.ntgqbz.com/uploadfile/202503/1ca8cc9c50adf94.jpg','MAT-260323-0076','GQ 4L 203','GQ 4L 203','BC17742805820533768',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/4L/94.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,76,NULL,'GQ-4L-203-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.050068','2026-03-23 23:43:02.050068',0,NULL,NULL,0.00,0.00,0.00),(77,NULL,NULL,NULL,NULL,NULL,'GQ-4L-204','http://www.ntgqbz.com/uploadfile/202502/fa0eb119b27c838.jpg','MAT-260323-0077','GQ 4L 204','GQ 4L 204','BC17742805820726687',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/4L/95.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,77,NULL,'GQ-4L-204-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.062637','2026-03-23 23:43:02.062637',0,NULL,NULL,0.00,0.00,0.00),(78,NULL,NULL,NULL,NULL,NULL,'GQ-500-009','http://www.ntgqbz.com/uploadfile/202503/4cec1505f132b8b.jpg','MAT-260323-0078','GQ 500 009','GQ 500 009','BC17742805820917916',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/111.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,78,NULL,'GQ-500-009-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.086803','2026-03-23 23:43:02.086803',0,NULL,NULL,0.00,0.00,0.00),(79,NULL,NULL,NULL,NULL,NULL,'GQ-500-016','http://www.ntgqbz.com/uploadfile/202511/7e7987f6aae4590.jpg','MAT-260323-0079','GQ 500 016','GQ 500 016','BC17742805821078515',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/141.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,79,NULL,'GQ-500-016-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.104425','2026-03-23 23:43:02.104425',0,NULL,NULL,0.00,0.00,0.00),(80,NULL,NULL,NULL,NULL,NULL,'GQ-500-001','http://www.ntgqbz.com/uploadfile/202412/7ec49e7e1bbd41.jpg','MAT-260323-0080','GQ 500 001','GQ 500 001','BC17742805821282195',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/45.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,80,NULL,'GQ-500-001-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.122944','2026-03-23 23:43:02.122944',0,NULL,NULL,0.00,0.00,0.00),(81,NULL,NULL,NULL,NULL,NULL,'GQ-500-002','http://www.ntgqbz.com/uploadfile/202412/8446ce6526af7e2.jpg','MAT-260323-0081','GQ 500 002','GQ 500 002','BC17742805821456186',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/53.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,81,NULL,'GQ-500-002-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.142028','2026-03-23 23:43:02.142028',0,NULL,NULL,0.00,0.00,0.00),(82,NULL,NULL,NULL,NULL,NULL,'GQ-500-003','http://www.ntgqbz.com/uploadfile/202411/169ea1b45cc5f5d.jpg','MAT-260323-0082','GQ 500 003','GQ 500 003','BC17742805821616817',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/60.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,82,NULL,'GQ-500-003-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.157511','2026-03-23 23:43:02.157511',0,NULL,NULL,0.00,0.00,0.00),(83,NULL,NULL,NULL,NULL,NULL,'GQ-500-004','http://www.ntgqbz.com/uploadfile/202411/7c543b285942281.jpg','MAT-260323-0083','GQ 500 004','GQ 500 004','BC17742805821763252',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/62.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,83,NULL,'GQ-500-004-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.170000','2026-03-23 23:43:02.170000',0,NULL,NULL,0.00,0.00,0.00),(84,NULL,NULL,NULL,NULL,NULL,'GQ-500-005','http://www.ntgqbz.com/uploadfile/202411/68c712e8939ec43.jpg','MAT-260323-0084','GQ 500 005','GQ 500 005','BC17742805822359579',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/64.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,84,NULL,'GQ-500-005-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.192868','2026-03-23 23:43:02.192868',0,NULL,NULL,0.00,0.00,0.00),(85,NULL,NULL,NULL,NULL,NULL,'GQ-500-006','http://www.ntgqbz.com/uploadfile/202412/992658130313f75.jpg','MAT-260323-0085','GQ 500 006','GQ 500 006','BC17742805822563498',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/65.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,85,NULL,'GQ-500-006-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.252882','2026-03-23 23:43:02.252882',0,NULL,NULL,0.00,0.00,0.00),(86,NULL,NULL,NULL,NULL,NULL,'GQ-500-008','http://www.ntgqbz.com/uploadfile/202412/30c934335db3e23.jpg','MAT-260323-0086','GQ 500 008','GQ 500 008','BC17742805822656631',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/69.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,86,NULL,'GQ-500-008-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.263119','2026-03-23 23:43:02.263119',0,NULL,NULL,0.00,0.00,0.00),(87,NULL,NULL,NULL,NULL,NULL,'GQ-500-011','http://www.ntgqbz.com/uploadfile/202412/c791b7898679.jpg','MAT-260323-0087','GQ 500 011','GQ 500 011','BC17742805822752398',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/71.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,87,NULL,'GQ-500-011-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.270783','2026-03-23 23:43:02.270783',0,NULL,NULL,0.00,0.00,0.00),(88,NULL,NULL,NULL,NULL,NULL,'GQ-500-014','http://www.ntgqbz.com/uploadfile/202511/d1ebbbc39293734.jpg','MAT-260323-0088','GQ 500 014','GQ 500 014','BC17742805822964861',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/72.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,88,NULL,'GQ-500-014-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.293093','2026-03-23 23:43:02.293093',0,NULL,NULL,0.00,0.00,0.00),(89,NULL,NULL,NULL,NULL,NULL,'GQ-500-007','http://www.ntgqbz.com/uploadfile/202411/9ec4bc76fb8e619.jpg','MAT-260323-0089','GQ 500 007','GQ 500 007','BC17742805823121410',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/74.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,89,NULL,'GQ-500-007-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.308870','2026-03-23 23:43:02.308870',0,NULL,NULL,0.00,0.00,0.00),(90,NULL,NULL,NULL,NULL,NULL,'GQ-500-012（专用瓶）','http://www.ntgqbz.com/uploadfile/202501/461805242b93b28.jpg','MAT-260323-0090','GQ 500 012  zyp','GQ 500 012  zhuan yong ping','BC17742805823291449',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/89.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,90,NULL,'GQ-500-012（专用瓶）-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.324829','2026-03-23 23:43:02.324829',0,NULL,NULL,0.00,0.00,0.00),(91,NULL,NULL,NULL,NULL,NULL,'GQ-500-013','http://www.ntgqbz.com/uploadfile/202501/b75630d0e4b7141.jpg','MAT-260323-0091','GQ 500 013','GQ 500 013','BC17742805824734914',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/90.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,91,NULL,'GQ-500-013-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.342376','2026-03-23 23:43:02.342376',0,NULL,NULL,0.00,0.00,0.00),(92,NULL,NULL,NULL,NULL,NULL,'GQ-100-004','http://www.ntgqbz.com/uploadfile/202510/3a25007e3b6d19c.jpg','MAT-260323-0092','GQ 100 004','GQ 100 004','BC17742805828143123',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/122.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,92,NULL,'GQ-100-004-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.604623','2026-03-23 23:43:02.604623',0,NULL,NULL,0.00,0.00,0.00),(93,NULL,NULL,NULL,NULL,NULL,'GQ-100-009','http://www.ntgqbz.com/uploadfile/202504/7f9ad5bd8521fa0.jpg','MAT-260323-0093','GQ 100 009','GQ 100 009','BC17742805828298351',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/124.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,93,NULL,'GQ-100-009-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.822979','2026-03-23 23:43:02.822979',0,NULL,NULL,0.00,0.00,0.00),(94,NULL,NULL,NULL,NULL,NULL,'GQ-50-001','http://www.ntgqbz.com/uploadfile/202509/7cc9e13e3f83d84.jpg','MAT-260323-0094','GQ 50 001','GQ 50 001','BC17742805829114215',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/137.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,94,NULL,'GQ-50-001-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.907005','2026-03-23 23:43:02.907005',0,NULL,NULL,0.00,0.00,0.00),(95,NULL,NULL,NULL,NULL,NULL,'GQ-100-005','http://www.ntgqbz.com/uploadfile/202602/d54f83e7a1b5876.png','MAT-260323-0095','GQ 100 005','GQ 100 005','BC17742805832029541',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/146.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,95,NULL,'GQ-100-005-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.102653','2026-03-23 23:43:03.102653',0,NULL,NULL,0.00,0.00,0.00),(96,NULL,NULL,NULL,NULL,NULL,'GQ-100-003','http://www.ntgqbz.com/uploadfile/202411/dc199bd5da63255.jpg','MAT-260323-0096','GQ 100 003','GQ 100 003','BC17742805832807559',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/31.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,96,NULL,'GQ-100-003-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.276585','2026-03-23 23:43:03.276585',0,NULL,NULL,0.00,0.00,0.00),(97,NULL,NULL,NULL,NULL,NULL,'GQ-100-010（专用瓶）','http://www.ntgqbz.com/uploadfile/202501/df846e59f190764.jpg','MAT-260323-0097','GQ 100 010  zyp','GQ 100 010  zhuan yong ping','BC17742805833466335',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/87.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,97,NULL,'GQ-100-010（专用瓶）-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.312820','2026-03-23 23:43:03.312820',0,NULL,NULL,0.00,0.00,0.00),(98,NULL,NULL,NULL,NULL,NULL,'GQ-5L-208','http://www.ntgqbz.com/uploadfile/202502/b698f60e3ab1cca.jpg','MAT-260323-0098','GQ 5L 208','GQ 5L 208','BC17742805833784972',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/110.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,98,NULL,'GQ-5L-208-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.371134','2026-03-23 23:43:03.371134',0,NULL,NULL,0.00,0.00,0.00),(99,NULL,NULL,NULL,NULL,NULL,'GQ-5L-207','http://www.ntgqbz.com/uploadfile/202503/fc4314fc288e3fd.jpg','MAT-260323-0099','GQ 5L 207','GQ 5L 207','BC17742805834206959',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/119.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,99,NULL,'GQ-5L-207-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.395239','2026-03-23 23:43:03.395239',0,NULL,NULL,0.00,0.00,0.00),(100,NULL,NULL,NULL,NULL,NULL,'GQ-5L-210','http://www.ntgqbz.com/uploadfile/202512/26b2e847bb953aa.jpg','MAT-260323-0100','GQ 5L 210','GQ 5L 210','BC17742805834542328',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/143.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100,NULL,'GQ-5L-210-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.438193','2026-03-23 23:43:03.438193',0,NULL,NULL,0.00,0.00,0.00),(101,NULL,NULL,NULL,NULL,NULL,'GQ-5L-211','http://www.ntgqbz.com/uploadfile/202602/08d241428642de8.png','MAT-260323-0101','GQ 5L 211','GQ 5L 211','BC17742805836086703',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/147.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,101,NULL,'GQ-5L-211-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.568526','2026-03-23 23:43:03.568526',0,NULL,NULL,0.00,0.00,0.00),(102,NULL,NULL,NULL,NULL,NULL,'GQ-5L-201','http://www.ntgqbz.com/uploadfile/202412/d59886c312feb6a.jpg','MAT-260323-0102','GQ 5L 201','GQ 5L 201','BC17742805836874533',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/54.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,102,NULL,'GQ-5L-201-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.672029','2026-03-23 23:43:03.672029',0,NULL,NULL,0.00,0.00,0.00),(103,NULL,NULL,NULL,NULL,NULL,'GQ-5L-202','http://www.ntgqbz.com/uploadfile/202412/57340ccb253bbb5.jpg','MAT-260323-0103','GQ 5L 202','GQ 5L 202','BC17742805837075302',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/55.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,103,NULL,'GQ-5L-202-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.702489','2026-03-23 23:43:03.702489',0,NULL,NULL,0.00,0.00,0.00),(104,NULL,NULL,NULL,NULL,NULL,'GQ-5L-203','http://www.ntgqbz.com/uploadfile/202412/3071099b59943ba.jpg','MAT-260323-0104','GQ 5L 203','GQ 5L 203','BC17742805837259407',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/56.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,104,NULL,'GQ-5L-203-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.720394','2026-03-23 23:43:03.720394',0,NULL,NULL,0.00,0.00,0.00),(105,NULL,NULL,NULL,NULL,NULL,'GQ-5L-204','http://www.ntgqbz.com/uploadfile/202411/078292e863704a6.jpg','MAT-260323-0105','GQ 5L 204','GQ 5L 204','BC17742805837623047',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/57.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,105,NULL,'GQ-5L-204-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.752330','2026-03-23 23:43:03.752330',0,NULL,NULL,0.00,0.00,0.00),(106,NULL,NULL,NULL,NULL,NULL,'GQ-5L-205','http://www.ntgqbz.com/uploadfile/202411/e5d8007e3c0bcc9.jpg','MAT-260323-0106','GQ 5L 205','GQ 5L 205','BC17742805837809627',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/58.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,106,NULL,'GQ-5L-205-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.775902','2026-03-23 23:43:03.775902',0,NULL,NULL,0.00,0.00,0.00),(107,NULL,NULL,NULL,NULL,NULL,'GQ-5L-206','http://www.ntgqbz.com/uploadfile/202411/c8e334166bed801.jpg','MAT-260323-0107','GQ 5L 206','GQ 5L 206','BC17742805837963715',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/59.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,107,NULL,'GQ-5L-206-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.791962','2026-03-23 23:43:03.791962',0,NULL,NULL,0.00,0.00,0.00),(108,NULL,NULL,NULL,NULL,NULL,'GQ-5L-209','http://www.ntgqbz.com/uploadfile/202411/17caf5d35d6c4c4.jpg','MAT-260323-0108','GQ 5L 209','GQ 5L 209','BC17742805839149298',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/70.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,108,NULL,'GQ-5L-209-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.819327','2026-03-23 23:43:03.819327',0,NULL,NULL,0.00,0.00,0.00),(109,NULL,NULL,NULL,NULL,NULL,'GQ-800-001','http://www.ntgqbz.com/uploadfile/202503/fbedb126d9fd9d7.jpg','MAT-260323-0109','GQ 800 001','GQ 800 001','BC17742805840264739',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/800ml/121.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,109,NULL,'GQ-800-001-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.022876','2026-03-23 23:43:04.022876',0,NULL,NULL,0.00,0.00,0.00),(110,NULL,NULL,NULL,NULL,NULL,'GQ-800-002','http://www.ntgqbz.com/uploadfile/202510/70be6a1d25fa167.jpg','MAT-260323-0110','GQ 800 002','GQ 800 002','BC17742805841378703',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/800ml/136.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,110,NULL,'GQ-800-002-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.133174','2026-03-23 23:43:04.133174',0,NULL,NULL,0.00,0.00,0.00),(111,NULL,NULL,NULL,NULL,NULL,'GQ-900-001','http://www.ntgqbz.com/uploadfile/202503/8cdc9865698bcf2.jpg','MAT-260323-0111','GQ 900 001','GQ 900 001','BC17742805843158763',NULL,9,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/900ml/115.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,111,NULL,'GQ-900-001-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.229989','2026-03-23 23:43:04.229989',0,NULL,NULL,0.00,0.00,0.00),(112,NULL,NULL,NULL,NULL,NULL,'GQ-20L-306','http://www.ntgqbz.com/uploadfile/202503/4dd566cbf207ab.jpg','MAT-260323-0112','GQ 20L 306','GQ 20L 306','BC17742805846819755',NULL,10,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/120.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,112,NULL,'GQ-20L-306-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.583314','2026-03-23 23:43:04.583314',0,NULL,NULL,0.00,0.00,0.00),(113,NULL,NULL,NULL,NULL,NULL,'GQ-20L-308','http://www.ntgqbz.com/uploadfile/202507/123bc2b4300769.jpg','MAT-260323-0113','GQ 20L 308','GQ 20L 308','BC17742805847636781',NULL,10,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/131.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,113,NULL,'GQ-20L-308-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.689294','2026-03-23 23:43:04.689294',0,NULL,NULL,0.00,0.00,0.00),(114,NULL,NULL,NULL,NULL,NULL,'GQ-20L-303','http://www.ntgqbz.com/uploadfile/202411/be910c256651c9.jpg','MAT-260323-0114','GQ 20L 303','GQ 20L 303','BC17742805848883686',NULL,10,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/15.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,114,NULL,'GQ-20L-303-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.771237','2026-03-23 23:43:04.771237',0,NULL,NULL,0.00,0.00,0.00),(115,NULL,NULL,NULL,NULL,NULL,'GQ-20L-304','http://www.ntgqbz.com/uploadfile/202411/576dacc4aeb9bc1.jpg','MAT-260323-0115','GQ 20L 304','GQ 20L 304','BC17742805849577105',NULL,10,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/20.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,115,NULL,'GQ-20L-304-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.926607','2026-03-23 23:43:04.926607',0,NULL,NULL,0.00,0.00,0.00),(116,NULL,NULL,NULL,NULL,NULL,'GQ-20L-305','http://www.ntgqbz.com/uploadfile/202411/700677282997733.jpg','MAT-260323-0116','GQ 20L 305','GQ 20L 305','BC17742805850197749',NULL,10,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/22.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,116,NULL,'GQ-20L-305-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:05.008920','2026-03-23 23:43:05.008920',0,NULL,NULL,0.00,0.00,0.00),(117,NULL,NULL,NULL,NULL,NULL,'GQ-20L-307','http://www.ntgqbz.com/uploadfile/202411/d4a5d92d17059b7.jpg','MAT-260323-0117','GQ 20L 307','GQ 20L 307','BC17742805850589288',NULL,10,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/25.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,117,NULL,'GQ-20L-307-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:05.050890','2026-03-23 23:43:05.050890',0,NULL,NULL,0.00,0.00,0.00),(118,NULL,NULL,NULL,NULL,NULL,'GQ-20L-301','http://www.ntgqbz.com/uploadfile/202411/18a0bd500258457.jpg','MAT-260323-0118','GQ 20L 301','GQ 20L 301','BC17742805851765737',NULL,10,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/66.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,118,NULL,'GQ-20L-301-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:05.076267','2026-03-23 23:43:05.076267',0,NULL,NULL,0.00,0.00,0.00),(119,NULL,NULL,NULL,NULL,NULL,'GQ-20L-302','http://www.ntgqbz.com/uploadfile/202411/1d1f12ee977c26c.jpg','MAT-260323-0119','GQ 20L 302','GQ 20L 302','BC17742805852429474',NULL,10,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/67.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,119,NULL,'GQ-20L-302-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:05.231353','2026-03-23 23:43:05.231353',0,NULL,NULL,0.00,0.00,0.00),(120,NULL,NULL,NULL,NULL,NULL,'GQ-25L-301','http://www.ntgqbz.com/uploadfile/202501/99a7b3ad57d21.jpg','MAT-260323-0120','GQ 25L 301','GQ 25L 301','BC17742805852802734',NULL,10,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/25L/81.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,120,NULL,'GQ-25L-301-001',0.00,0.00,NULL,NULL,NULL,NULL,'2026-03-23 23:43:05.269973','2026-03-23 23:43:05.269973',0,NULL,NULL,0.00,0.00,0.00);
/*!40000 ALTER TABLE `mat_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mat_pre_orders`
--

DROP TABLE IF EXISTS `mat_pre_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mat_pre_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `customer_name` varchar(255) DEFAULT NULL,
  `customer_code` varchar(255) DEFAULT NULL,
  `spec_requirements` text,
  `line_items` json DEFAULT NULL,
  `request_ip` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `processed_at` datetime(6) DEFAULT NULL,
  `crm_order_id` int DEFAULT NULL,
  `processor_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mat_pre_orders`
--

LOCK TABLES `mat_pre_orders` WRITE;
/*!40000 ALTER TABLE `mat_pre_orders` DISABLE KEYS */;
INSERT INTO `mat_pre_orders` VALUES (1,'金陵','','','[{\"unit\": \"—\", \"color\": \"PE/COEX\", \"model\": \"GQ-20L-308\", \"weight\": \"20L\", \"quantity\": 1.0, \"product_id\": 113, \"product_name\": \"GQ-20L-308\"}, {\"unit\": \"—\", \"color\": \"PE/COEX\", \"model\": \"GQ-20L-303\", \"weight\": \"20L\", \"quantity\": 1.0, \"product_id\": 114, \"product_name\": \"GQ-20L-303\"}]','127.0.0.1','2026-03-24 10:27:45.172707','2026-03-24 10:27:45.172707','pending',NULL,NULL,NULL),(2,'金陵','0102上海新易 CIE20251022005 FJI-5（谭）','白瓶绿盖，瓶套收缩膜，瓶盖喷码，纸箱套防尘袋，300G儿L乐果\nEC','[{\"unit\": \"只\", \"color\": \"白\", \"model\": \"GQ-25L-301\", \"weight\": \"25L\", \"quantity\": 2100.0, \"product_id\": 120, \"product_name\": \"GQ-25L-301\"}, {\"unit\": \"只\", \"color\": \"40657绿\", \"model\": \"阻隔铝箔垫37.2-乐果专业铝箔垫\", \"weight\": \"14G\", \"quantity\": 2100.0, \"product_id\": 120, \"product_name\": \"小喇叭盖\"}]','127.0.0.1','2026-03-24 10:38:34.149530','2026-03-24 16:18:41.766553','converted','2026-03-24 16:18:41.764296',1,1),(3,'测试11111','','','[{\"unit\": \"—\", \"color\": \"白色\", \"model\": \"GQ-800-002\", \"weight\": \"800ml\", \"quantity\": 2000.0, \"product_id\": 110, \"product_name\": \"GQ-800-002\"}, {\"unit\": \"只\", \"color\": \"白色\", \"model\": \"\", \"weight\": \"\", \"quantity\": 8000.0, \"product_id\": 110, \"product_name\": \"小瓶盖\"}]','127.0.0.1','2026-03-24 13:29:46.438819','2026-03-24 13:29:46.438819','pending',NULL,NULL,NULL),(4,'金陵','0104宁波盈农生物 科技有限公司 25ASWB1208-2 （张）','白瓶黄盖，带防盗圈，带UN号，180克/升氰氟草酯乳油','[{\"unit\": \"—\", \"color\": \"PE/COEX\", \"model\": \"GQ-800-002\", \"weight\": \"800ml\", \"quantity\": 2000.0, \"product_id\": 110, \"product_name\": \"GQ-800-002\"}, {\"unit\": \"—\", \"color\": \"PE/COEX\", \"model\": \"GQ-900-001\", \"weight\": \"900ml\", \"quantity\": 5000.0, \"product_id\": 111, \"product_name\": \"GQ-900-001\"}]','127.0.0.1','2026-03-24 20:03:04.042593','2026-03-24 20:04:34.652283','converted','2026-03-24 20:04:34.651779',4,1);
/*!40000 ALTER TABLE `mat_pre_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mat_products`
--

DROP TABLE IF EXISTS `mat_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mat_products` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `labels` json DEFAULT NULL,
  `custom_fields` json DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `pinyin` varchar(255) DEFAULT NULL,
  `type_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `price` decimal(12,2) DEFAULT '0.00',
  `cost_price` decimal(12,2) DEFAULT '0.00',
  `market_price` decimal(12,2) DEFAULT '0.00',
  `description` text,
  `uom_id` int DEFAULT NULL,
  `uom_po_id` int DEFAULT NULL,
  `sale_tax_id` int DEFAULT NULL,
  `purchase_tax_id` int DEFAULT NULL,
  `is_sale` tinyint(1) DEFAULT NULL,
  `is_purchase` tinyint(1) DEFAULT NULL,
  `is_manufacture` tinyint(1) DEFAULT NULL,
  `is_stock` tinyint(1) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `combo_id` int DEFAULT NULL,
  `track_inventory` tinyint(1) DEFAULT '0',
  `track_inventory_type` varchar(255) DEFAULT NULL,
  `on_hand_quantity` decimal(12,2) DEFAULT '0.00',
  `name_en` varchar(255) DEFAULT NULL COMMENT '英文名称',
  `image_url` varchar(255) DEFAULT NULL COMMENT '产品图片URL',
  `material` varchar(255) DEFAULT NULL COMMENT '产品材质',
  `full_capacity` varchar(255) DEFAULT NULL COMMENT '满口容量',
  `nominal_capacity` varchar(255) DEFAULT NULL COMMENT '公称容量',
  `caliber` varchar(255) DEFAULT NULL COMMENT '口径',
  `cap_height` varchar(255) DEFAULT NULL COMMENT '带盖高度',
  `max_diameter` varchar(255) DEFAULT NULL COMMENT '最大直径',
  `label_size` varchar(255) DEFAULT NULL COMMENT '贴标尺寸',
  `gram_weight` varchar(255) DEFAULT NULL COMMENT '克重',
  PRIMARY KEY (`id`),
  KEY `index_mat_products_on_category_id` (`category_id`),
  KEY `index_mat_products_on_company_id` (`company_id`),
  KEY `index_mat_products_on_type_id` (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mat_products`
--

LOCK TABLES `mat_products` WRITE;
/*!40000 ALTER TABLE `mat_products` DISABLE KEYS */;
INSERT INTO `mat_products` VALUES (1,NULL,NULL,1,1,NULL,'dd',NULL,'MAT-260323-0001','dd','dd',1,11,0.00,0.00,0.00,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,1,'2026-03-23 23:32:08.977519','2026-03-23 23:32:26.739183',NULL,0,NULL,0.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(2,NULL,NULL,NULL,NULL,NULL,'GQ-100-001','http://www.ntgqbz.com/uploadfile/202412/2b9e4e69a519ed2.jpg','GQ-100-001','GQ 100 001','GQ 100 001',NULL,12,0.00,0.00,0.00,'http://www.ntgqbz.com/product/Mother_child_bottle/100ml/28.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:58.747664','2026-03-23 23:42:58.747664',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/2b9e4e69a519ed2.jpg','PE/COEX','156ml/170ml','100ml','37mm','118mm','86mm*49mm*118mm','55mm*125mm',NULL),(3,NULL,NULL,NULL,NULL,NULL,'GQ-1L-双口子母瓶','http://www.ntgqbz.com/uploadfile/202508/b963788a035cbf2.jpg','GQ-1L-双口子母瓶','GQ 1L  skzmp','GQ 1L  shuang kou zi mu ping',NULL,13,0.00,0.00,0.00,'http://www.ntgqbz.com/product/Mother_child_bottle/1L/109.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:58.872556','2026-03-23 23:42:58.872556',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202508/b963788a035cbf2.jpg','PE/COEX','1036ml/210ml','950ml/180ml','38mm','219mm','','',NULL),(4,NULL,NULL,NULL,NULL,NULL,'GQ-200-001','http://www.ntgqbz.com/uploadfile/202412/1c699d22dd2a822.jpg','GQ-200-001','GQ 200 001','GQ 200 001',NULL,14,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/200ml/39.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:58.909995','2026-03-23 23:43:01.457336',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/1c699d22dd2a822.jpg','PE/COEX','240ml','200ml','42mm','120mm','58mm','57mm*180mm',NULL),(5,NULL,NULL,NULL,NULL,NULL,'GQ-500-200双口子母瓶','http://www.ntgqbz.com/uploadfile/202509/c9e61aab5bdb5c7.jpg','GQ-500-200双口子母瓶','GQ 500 200 skzmp','GQ 500 200 shuang kou zi mu ping',NULL,15,0.00,0.00,0.00,'http://www.ntgqbz.com/product/Mother_child_bottle/500ml/138.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.006716','2026-03-23 23:42:59.006716',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202509/c9e61aab5bdb5c7.jpg','PE/COEX','590ml/245ml','500ml/200ml','44.3mm','175mm','','',NULL),(6,NULL,NULL,NULL,1,NULL,'1L PET瓶','http://www.ntgqbz.com/uploadfile/202508/33e11b8c68c4ecd.jpg','GQ-1000-102','1L PET p','1L PET ping',NULL,16,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/1000ml/135.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.076416','2026-03-30 20:26:02.682682',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202508/33e11b8c68c4ecd.jpg','PET','1070ml','1000ml','45mm','234mm','87.8mm','135mm*276mm','260'),(7,NULL,NULL,NULL,NULL,NULL,'GQ-1000-103','http://www.ntgqbz.com/uploadfile/202512/3d7b4dedbceacdd.jpg','GQ-1000-103','GQ 1000 103','GQ 1000 103',NULL,16,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/1000ml/142.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.142539','2026-03-23 23:42:59.142539',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202512/3d7b4dedbceacdd.jpg','PET','1125ml','1000ml','45mm','228mm','89.5mm','137mm*276mm',NULL),(8,NULL,NULL,NULL,NULL,NULL,'GQ-1000-106','http://www.ntgqbz.com/uploadfile/202603/3c517e988bf7ea4.png','GQ-1000-106','GQ 1000 106','GQ 1000 106',NULL,16,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/1000ml/150.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.172991','2026-03-23 23:42:59.172991',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202603/3c517e988bf7ea4.png','PET','1134ml','1000ml','45mm','247mm','89mm','128mm*270mm',NULL),(9,NULL,NULL,NULL,NULL,NULL,'GQ-1000-101','http://www.ntgqbz.com/uploadfile/202411/f285823548cf665.jpg','GQ-1000-101','GQ 1000 101','GQ 1000 101',NULL,16,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/1000ml/29.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.207548','2026-03-23 23:42:59.207548',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/f285823548cf665.jpg','PET','1105ml','1000ml','45mm','221mm','92.5mm','115mm*288mm',NULL),(10,NULL,NULL,NULL,NULL,NULL,'GQ-1000-104','http://www.ntgqbz.com/uploadfile/202411/8a48bb6a0fdefff.jpg','GQ-1000-104','GQ 1000 104','GQ 1000 104',NULL,16,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/1000ml/68.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.233977','2026-03-23 23:42:59.233977',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/8a48bb6a0fdefff.jpg','PET','1150ml','1000ml','45mm','251mm','88mm','145mm*270mm',NULL),(11,NULL,NULL,NULL,NULL,NULL,'GQ-100-101','http://www.ntgqbz.com/uploadfile/202507/189f511ce64d4f9.jpg','GQ-100-101','GQ 100 101','GQ 100 101',NULL,17,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/100ml/132.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.273137','2026-03-23 23:42:59.273137',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202507/189f511ce64d4f9.jpg','PET','131ml','100ml','31mm','110mm','45.1mm','60mm*141mm',NULL),(12,NULL,NULL,NULL,NULL,NULL,'GQ-250-103','http://www.ntgqbz.com/uploadfile/202504/c860b1d0e1c6ed9.jpg','GQ-250-103','GQ 250 103','GQ 250 103',NULL,18,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/250ml/125.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.324870','2026-03-23 23:42:59.324870',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202504/c860b1d0e1c6ed9.jpg','PET','300ml','250ml','45mm','132mm','62.5mm','65mm*197mm',NULL),(13,NULL,NULL,NULL,1,NULL,'250ML PET瓶','http://www.ntgqbz.com/uploadfile/202411/a3963690de45064.jpg','GQ-250-101','250ML PET p','250ML PET ping',NULL,18,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/250ml/44.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.357477','2026-03-30 20:25:31.531238',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/a3963690de45064.jpg','PET','290ml','250ml','45mm','128mm','64.5mm','60mm*202mm','260'),(14,NULL,NULL,NULL,NULL,NULL,'GQ-250-102','http://www.ntgqbz.com/uploadfile/202501/eb0b7255acad6db.jpg','GQ-250-102','GQ 250 102','GQ 250 102',NULL,18,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/250ml/82.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.578481','2026-03-23 23:42:59.578481',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202501/eb0b7255acad6db.jpg','PET','315ml','250ml','45mm','134mm','65mm','65mm*204mm',NULL),(15,NULL,NULL,NULL,NULL,NULL,'GQ-400-101','http://www.ntgqbz.com/uploadfile/202504/3c927111ccd8076.jpg','GQ-400-101','GQ 400 101','GQ 400 101',NULL,19,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/400ml/126.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.675382','2026-03-23 23:42:59.675382',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202504/3c927111ccd8076.jpg','PET','487ml','400ml','45mm','175.5mm','68mm','105mm*214mm',NULL),(16,NULL,NULL,NULL,NULL,NULL,'GQ-500-103','http://www.ntgqbz.com/uploadfile/202507/6978bb3988c490f.jpg','GQ-500-103','GQ 500 103','GQ 500 103',NULL,20,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/500ml/134.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.709927','2026-03-23 23:42:59.709927',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202507/6978bb3988c490f.jpg','PET','580ml','500ml','45mm','199mm','68mm','109mm*210mm',NULL),(17,NULL,NULL,NULL,NULL,NULL,'GQ-500-101','http://www.ntgqbz.com/uploadfile/202411/8f08a3b1409a95.jpg','GQ-500-101','GQ 500 101','GQ 500 101',NULL,20,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/500ml/75.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.752270','2026-03-23 23:42:59.752270',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/8f08a3b1409a95.jpg','PET','540ml','500ml','45mm','187mm','71.5mm','109mm*225mm',NULL),(18,NULL,NULL,NULL,NULL,NULL,'GQ-800-101','http://www.ntgqbz.com/uploadfile/202503/25973dcfc009.jpg','GQ-800-101','GQ 800 101','GQ 800 101',NULL,21,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PET_polyester_bottle/800ml/123.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.772603','2026-03-23 23:42:59.772603',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/25973dcfc009.jpg','PET','929ml','800ml','45mm','209mm','87mm','110mm*273mm',NULL),(19,NULL,NULL,NULL,NULL,NULL,'GQ-1000-008','http://www.ntgqbz.com/uploadfile/202412/643c604cfccc.jpg','GQ-1000-008','GQ 1000 008','GQ 1000 008',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/10.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.073100','2026-03-23 23:43:00.073100',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/643c604cfccc.jpg','PE/COEX','1150ml','1000ml','50mm','235mm','89mm','145mm*273mm',NULL),(20,NULL,NULL,NULL,NULL,NULL,'GQ-1000-011','http://www.ntgqbz.com/uploadfile/202412/ef2c90479ed15.jpg','GQ-1000-011','GQ 1000 011','GQ 1000 011',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/12.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.203548','2026-03-23 23:43:00.203548',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/ef2c90479ed15.jpg','PE/COEX','1150ml','1000ml','50mm','242mm','89mm','150mm*281mm',NULL),(21,NULL,NULL,NULL,NULL,NULL,'GQ-1000-012','http://www.ntgqbz.com/uploadfile/202412/39f66706bf0f838.jpg','GQ-1000-012','GQ 1000 012','GQ 1000 012',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/13.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.381596','2026-03-23 23:43:00.381596',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/39f66706bf0f838.jpg','PE/COEX','1150ml','1000ml','45mm','207mm','长110mm*宽70mm','134mm*340mm',NULL),(22,NULL,NULL,NULL,NULL,NULL,'GQ-1000-020（专用瓶）','http://www.ntgqbz.com/uploadfile/202507/2769ed6607aa152.jpg','GQ-1000-020（专用瓶）','GQ 1000 020  zyp','GQ 1000 020  zhuan yong ping',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/133.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.610963','2026-03-23 23:43:00.610963',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202507/2769ed6607aa152.jpg','PE/COEX','1100ml','1000ml','32.1mm','220.5mm','94.4mm','126mm*297mm',NULL),(23,NULL,NULL,NULL,NULL,NULL,'GQ-1000-013','http://www.ntgqbz.com/uploadfile/202503/b8ce94517d1d959.jpg','GQ-1000-013','GQ 1000 013','GQ 1000 013',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/14.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.628945','2026-03-23 23:43:00.628945',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/b8ce94517d1d959.jpg','PE/COEX','1150ml','1000ml','38mm','224mm','96mm','132mm*300mm',NULL),(24,NULL,NULL,NULL,NULL,NULL,'GQ-1000-014','http://www.ntgqbz.com/uploadfile/202412/89dacd08cd45902.jpg','GQ-1000-014','GQ 1000 014','GQ 1000 014',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/16.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.656984','2026-03-23 23:43:00.656984',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/89dacd08cd45902.jpg','PE/COEX','1150ml','1000ml','50mm','235mm','89mm','140mm*278mm',NULL),(25,NULL,NULL,NULL,NULL,NULL,'GQ-1000-015','http://www.ntgqbz.com/uploadfile/202412/9eedccf12a9b8f2.jpg','GQ-1000-015','GQ 1000 015','GQ 1000 015',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/17.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.720794','2026-03-23 23:43:00.720794',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/9eedccf12a9b8f2.jpg','PE/COEX','1200ml','1000ml','50mm','238±1mm','91.2mm','140±1mm*281±1mm',NULL),(26,NULL,NULL,NULL,NULL,NULL,'GQ-1000-016','http://www.ntgqbz.com/uploadfile/202412/5dd3890eb54ad9d.jpg','GQ-1000-016','GQ 1000 016','GQ 1000 016',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/18.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.742427','2026-03-23 23:43:00.742427',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/5dd3890eb54ad9d.jpg','PE/COEX','1140ml','1000ml','50mm','248mm','88.4mm','140mm*276mm',NULL),(27,NULL,NULL,NULL,NULL,NULL,'GQ-1000-017','http://www.ntgqbz.com/uploadfile/202412/66cafa0b8c989cd.jpg','GQ-1000-017','GQ 1000 017','GQ 1000 017',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/19.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.770000','2026-03-23 23:43:00.770000',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/66cafa0b8c989cd.jpg','PE/COEX','1120ml','1000ml','45ml','229mm','93mm*74mm','120mm*310mm(2mm间隙)',NULL),(28,NULL,NULL,NULL,NULL,NULL,'GQ-1000-019','http://www.ntgqbz.com/uploadfile/202412/33f27f63a6bfb53.jpg','GQ-1000-019','GQ 1000 019','GQ 1000 019',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/21.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.802559','2026-03-23 23:43:00.802559',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/33f27f63a6bfb53.jpg','PE/COEX','1250ml','1000ml','50mm','243mm','90mm','150mm*276mm',NULL),(29,NULL,NULL,NULL,NULL,NULL,'GQ-1000-021（专用瓶）','http://www.ntgqbz.com/uploadfile/202412/6451c0aef7e2771.jpg','GQ-1000-021（专用瓶）','GQ 1000 021  zyp','GQ 1000 021  zhuan yong ping',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/23.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.826574','2026-03-23 23:43:00.826574',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/6451c0aef7e2771.jpg','PE/COEX','1090ml','1000ml','45mm','240mm','89mm','122mm*274mm',NULL),(30,NULL,NULL,NULL,NULL,NULL,'GQ-1000-022','http://www.ntgqbz.com/uploadfile/202412/72f2a0fed629287.jpg','GQ-1000-022','GQ 1000 022','GQ 1000 022',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/24.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.868945','2026-03-23 23:43:00.868945',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/72f2a0fed629287.jpg','PE/COEX','1120ml','1000ml','45mm','235mm','90mm','134mm*279mm',NULL),(31,NULL,NULL,NULL,NULL,NULL,'GQ-1000-023','http://www.ntgqbz.com/uploadfile/202412/338625f04e5f10c.jpg','GQ-1000-023','GQ 1000 023','GQ 1000 023',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/26.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.900903','2026-03-23 23:43:00.900903',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/338625f04e5f10c.jpg','PE/COEX','1225ml','1000ml','45mm','257mm（配量杯高261mm）','90.5mm','142mm*281mm',NULL),(32,NULL,NULL,NULL,NULL,NULL,'GQ-1000-001','http://www.ntgqbz.com/uploadfile/202412/e94afcf36623651.jpg','GQ-1000-001','GQ 1000 001','GQ 1000 001',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/4.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.956193','2026-03-23 23:43:00.956193',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/e94afcf36623651.jpg','PE/COEX','1120ml','1000ml','42mm','216mm（219mm配刀口盖）','92mm','137mm*285mm',NULL),(33,NULL,NULL,NULL,NULL,NULL,'GQ-1000-002','http://www.ntgqbz.com/uploadfile/202412/c237f488b2969dc.jpg','GQ-1000-002','GQ 1000 002','GQ 1000 002',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/5.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.987554','2026-03-23 23:43:00.987554',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/c237f488b2969dc.jpg','PE/COEX','1120ml','1000ml','45mm','220mm','92mm','137mm*281mm',NULL),(34,NULL,NULL,NULL,NULL,NULL,'GQ-1000-003','http://www.ntgqbz.com/uploadfile/202412/e298a8aed7bdc90.jpg','GQ-1000-003','GQ 1000 003','GQ 1000 003',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/6.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.041312','2026-03-23 23:43:01.041312',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/e298a8aed7bdc90.jpg','PE/COEX','1160ml','1000ml','45.6mm','250mm','88mm','145mm*275mm',NULL),(35,NULL,NULL,NULL,NULL,NULL,'GQ-1000-004','http://www.ntgqbz.com/uploadfile/202412/eec3ae0ad5ec2ec.jpg','GQ-1000-004','GQ 1000 004','GQ 1000 004',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/7.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.072720','2026-03-23 23:43:01.072720',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/eec3ae0ad5ec2ec.jpg','PE/COEX','1170ml','1000ml','64mm','228mm（含量杯高度230）','89mm','146mm*276mm',NULL),(36,NULL,NULL,NULL,NULL,NULL,'GQ-1000-009','http://www.ntgqbz.com/uploadfile/202412/947724b565c2839.jpg','GQ-1000-009','GQ 1000 009','GQ 1000 009',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/79.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.096964','2026-03-23 23:43:01.096964',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/947724b565c2839.jpg','PE/COEX','1150ml','1000ml','45mm','223mm','93mm','134mm*288mm',NULL),(37,NULL,NULL,NULL,NULL,NULL,'GQ-1000-005','http://www.ntgqbz.com/uploadfile/202501/9e571c15177ad.jpg','GQ-1000-005','GQ 1000 005','GQ 1000 005',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/8.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.122085','2026-03-23 23:43:01.122085',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202501/9e571c15177ad.jpg','PE/COEX','1200ml','1000ml','50mm','240mm','89mm','150mm*278mm',NULL),(38,NULL,NULL,NULL,NULL,NULL,'GQ-1000-007','http://www.ntgqbz.com/uploadfile/202412/696e3698a0b0816.jpg','GQ-1000-007','GQ 1000 007','GQ 1000 007',NULL,22,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/1000ml/9.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.143535','2026-03-23 23:43:01.143535',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/696e3698a0b0816.jpg','PE/COEX','1100ml','1000ml','38mm','233mm','91mm','138mm*283mm',NULL),(39,NULL,NULL,NULL,1,NULL,'GQ-100-011','http://www.ntgqbz.com/uploadfile/202503/63fabf6f03c7d03.jpg','GQ-100-011','GQ 100 011','GQ 100 011',NULL,23,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/100ml_150ml/112.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.159827','2026-03-24 08:10:34.571300',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/63fabf6f03c7d03.jpg','PE/COEX','145ml','100ml','48mm','80.5mm','57mm','40mm*177.5mm',NULL),(40,NULL,NULL,NULL,NULL,NULL,'GQ-100-002','http://www.ntgqbz.com/uploadfile/202411/551ea889ee5819a.jpg','GQ-100-002','GQ 100 002','GQ 100 002',NULL,23,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/100ml_150ml/30.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.176174','2026-03-23 23:43:01.176174',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/551ea889ee5819a.jpg','PE/COEX','175ml','100ml','48mm','90mm','58mm','42mm*182mm',NULL),(41,NULL,NULL,NULL,NULL,NULL,'GQ-100-006','http://www.ntgqbz.com/uploadfile/202411/2b7fd2c52ca2e70.jpg','GQ-100-006','GQ 100 006','GQ 100 006',NULL,23,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/100ml_150ml/33.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.222680','2026-03-23 23:43:01.222680',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/2b7fd2c52ca2e70.jpg','PE/COEX','130ml','100ml','38mm','110mm','44.5mm','55mm*137mm',NULL),(42,NULL,NULL,NULL,NULL,NULL,'GQ-100-008','http://www.ntgqbz.com/uploadfile/202412/7524cb0492592ed.jpg','GQ-100-008','GQ 100 008','GQ 100 008',NULL,23,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/100ml_150ml/35.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.245720','2026-03-23 23:43:01.245720',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/7524cb0492592ed.jpg','PE/COEX','130ml','100ml','31.5mm','120mm','44.5mm','62mm*139mm',NULL),(43,NULL,NULL,NULL,NULL,NULL,'GQ-150-001','http://www.ntgqbz.com/uploadfile/202412/8757e2e49e2818a.jpg','GQ-150-001','GQ 150 001','GQ 150 001',NULL,24,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/100ml_150ml/78.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.275287','2026-03-23 23:43:01.275287',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/8757e2e49e2818a.jpg','PE/COEX','185ml','150ml','32mm','126mm','50.5mm','58mm*156mm',NULL),(44,NULL,NULL,NULL,NULL,NULL,'GQ-10L-204','http://www.ntgqbz.com/uploadfile/202505/c9cc5f839742d34.jpg','GQ-10L-204','GQ 10L 204','GQ 10L 204',NULL,25,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/10L/128.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.351890','2026-03-23 23:43:01.351890',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202505/c9cc5f839742d34.jpg','PE/COEX','12L±0.3L','10L','58.5mm','335mm','','',NULL),(45,NULL,NULL,NULL,NULL,NULL,'GQ-10L-205','http://www.ntgqbz.com/uploadfile/202505/1c6a2b5f4264b2d.jpg','GQ-10L-205','GQ 10L 205','GQ 10L 205',NULL,25,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/10L/129.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.376979','2026-03-23 23:43:01.376979',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202505/1c6a2b5f4264b2d.jpg','PE/COEX','11L±0.3L','10L','50mm','316mm±3mm','','',NULL),(46,NULL,NULL,NULL,NULL,NULL,'GQ-10L-201','http://www.ntgqbz.com/uploadfile/202411/5b4772b2d7cdbeb.jpg','GQ-10L-201','GQ 10L 201','GQ 10L 201',NULL,25,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/10L/61.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.391932','2026-03-23 23:43:01.391932',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/5b4772b2d7cdbeb.jpg','PE/COEX','10.5L','10L','42mm','360mm','','',NULL),(47,NULL,NULL,NULL,NULL,NULL,'GQ-10L-203','http://www.ntgqbz.com/uploadfile/202411/bb7d9b8d69bbc91.jpg','GQ-10L-203','GQ 10L 203','GQ 10L 203',NULL,25,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/10L/63.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.415753','2026-03-23 23:43:01.415753',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/bb7d9b8d69bbc91.jpg','PE/COEX','11.1L','10L','64mm','377mm','','',NULL),(48,NULL,NULL,NULL,NULL,NULL,'GQ-10L-202','http://www.ntgqbz.com/uploadfile/202501/ea5bd11199aabb8.jpg','GQ-10L-202','GQ 10L 202','GQ 10L 202',NULL,25,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/10L/83.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.428660','2026-03-23 23:43:01.428660',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202501/ea5bd11199aabb8.jpg','PE/COEX','10.5L','10L','63mm','311mm','','',NULL),(49,NULL,NULL,NULL,NULL,NULL,'GQ-200-006','http://www.ntgqbz.com/uploadfile/202511/6df4402a3751191.jpg','GQ-200-006','GQ 200 006','GQ 200 006',NULL,14,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/200ml/139.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.443983','2026-03-23 23:43:01.443983',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202511/6df4402a3751191.jpg','PE/COEX','263ml','200ml','48mm','119mm','61mm','62mm*191mm',NULL),(50,NULL,NULL,NULL,NULL,NULL,'GQ-200-002','http://www.ntgqbz.com/uploadfile/202412/c9596732bece9.jpg','GQ-200-002','GQ 200 002','GQ 200 002',NULL,14,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/200ml/40.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.469649','2026-03-23 23:43:01.469649',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/c9596732bece9.jpg','PE/COEX','240ml','200ml','45mm','122mm','58mm','57mm*180mm',NULL),(51,NULL,NULL,NULL,NULL,NULL,'GQ-200-003','http://www.ntgqbz.com/uploadfile/202411/19981aec1eef3f2.jpg','GQ-200-003','GQ 200 003','GQ 200 003',NULL,14,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/200ml/41.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.488539','2026-03-23 23:43:01.488539',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/19981aec1eef3f2.jpg','PE/COEX','240ml','200ml','45mm','141mm','54mm','88mm*168mm',NULL),(52,NULL,NULL,NULL,NULL,NULL,'GQ-200-004','http://www.ntgqbz.com/uploadfile/202411/a9fcc64b3711876.jpg','GQ-200-004','GQ 200 004','GQ 200 004',NULL,14,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/200ml/43.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.508663','2026-03-23 23:43:01.508663',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/a9fcc64b3711876.jpg','PE/COEX','223ml','200ml','38mm','138mm','51.8mm','88mm*160mm',NULL),(53,NULL,NULL,NULL,NULL,NULL,'GQ-200-005','http://www.ntgqbz.com/uploadfile/202501/c84ad4ec7c024bf.jpg','GQ-200-005','GQ 200 005','GQ 200 005',NULL,14,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/200ml/84.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.518446','2026-03-23 23:43:01.518446',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202501/c84ad4ec7c024bf.jpg','PE/COEX','240ml','200ml','32mm','137mm','55.8mm','65mm*171mm',NULL),(54,NULL,NULL,NULL,NULL,NULL,'GQ-250-005','http://www.ntgqbz.com/uploadfile/202411/0d1865b93da75.jpg','GQ-250-005','GQ 250 005','GQ 250 005',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/11.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.536031','2026-03-23 23:43:01.536031',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/0d1865b93da75.jpg','PE/COEX','290ml','250ml','48mm','130mm','63mm','65mm*195mm',NULL),(55,NULL,NULL,NULL,NULL,NULL,'GQ-250-011','http://www.ntgqbz.com/uploadfile/202503/9d5d600721174d8.jpg','GQ-250-011','GQ 250 011','GQ 250 011',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/114.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.547782','2026-03-23 23:43:01.547782',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/9d5d600721174d8.jpg','PE/COEX','278ml','250ml','41mm','128mm','62.5mm','59mm*192mm',NULL),(56,NULL,NULL,NULL,NULL,NULL,'GQ-250-012','http://www.ntgqbz.com/uploadfile/202511/b0a321f67e9f7aa.jpg','GQ-250-012','GQ 250 012','GQ 250 012',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/140.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.570104','2026-03-23 23:43:01.570104',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202511/b0a321f67e9f7aa.jpg','PE/COEX','280ml','250ml','45mm','132mm','61.8mm','67mm*191mm',NULL),(57,NULL,NULL,NULL,NULL,NULL,'GQ-250-006','http://www.ntgqbz.com/uploadfile/202411/26083be7ca0de5b.jpg','GQ-250-006','GQ 250 006','GQ 250 006',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/32.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.592509','2026-03-23 23:43:01.592509',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/26083be7ca0de5b.jpg','PE/COEX','285ml','250ml','45mm','107mm','长70mm*宽70mm*高107mm','40mm*272mm',NULL),(58,NULL,NULL,NULL,NULL,NULL,'GQ-250-007','http://www.ntgqbz.com/uploadfile/202412/01b21855fbd5535.jpg','GQ-250-007','GQ 250 007','GQ 250 007',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/34.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.618737','2026-03-23 23:43:01.618737',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/01b21855fbd5535.jpg','PE/COEX','299ml','250ml','31mm','154mm','60mm','75mm*188mm',NULL),(59,NULL,NULL,NULL,NULL,NULL,'GQ-250-009','http://www.ntgqbz.com/uploadfile/202411/2f385e7700b661a.jpg','GQ-250-009','GQ 250 009','GQ 250 009',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/37.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.645847','2026-03-23 23:43:01.645847',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/2f385e7700b661a.jpg','PE/COEX','290ml','250ml','48mm','136mm','63mm','65mm*195mm',NULL),(60,NULL,NULL,NULL,NULL,NULL,'GQ-250-010','http://www.ntgqbz.com/uploadfile/202411/3ff51e3fb0a8.jpg','GQ-250-010','GQ 250 010','GQ 250 010',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/42.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.674381','2026-03-23 23:43:01.674381',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/3ff51e3fb0a8.jpg','PE/COEX','264ml','250ml','28.5mm','180.5mm','51mm','63mm*160mm',NULL),(61,NULL,NULL,NULL,NULL,NULL,'GQ-250-001','http://www.ntgqbz.com/uploadfile/202412/7d9148dd046a8a.jpg','GQ-250-001','GQ 250 001','GQ 250 001',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/47.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.711694','2026-03-23 23:43:01.711694',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/7d9148dd046a8a.jpg','PE/COEX','290ml','250ml','41mm','123mm','62.5mm','61mm*193mm',NULL),(62,NULL,NULL,NULL,NULL,NULL,'GQ-250-002','http://www.ntgqbz.com/uploadfile/202412/50c3c7a0d4c8.jpg','GQ-250-002','GQ 250 002','GQ 250 002',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/50.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.755550','2026-03-23 23:43:01.755550',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/50c3c7a0d4c8.jpg','PE/COEX','285ml','250ml','45mm','128mm','63mm','61mm*193mm',NULL),(63,NULL,NULL,NULL,NULL,NULL,'GQ-250-004','http://www.ntgqbz.com/uploadfile/202411/68a3f75f08f532b.jpg','GQ-250-004','GQ 250 004','GQ 250 004',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/51.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.789707','2026-03-23 23:43:01.789707',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/68a3f75f08f532b.jpg','PE/COEX','285ml','250ml','36.5mm','144mm','57mm','77mm*173mm',NULL),(64,NULL,NULL,NULL,NULL,NULL,'GQ-250-008','http://www.ntgqbz.com/uploadfile/202412/f2595269ca0e5c4.jpg','GQ-250-008','GQ 250 008','GQ 250 008',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/73.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.807980','2026-03-23 23:43:01.807980',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/f2595269ca0e5c4.jpg','PE/COEX','290ml','250ml','45mm','126.5mm','65mm','65mm*204mm',NULL),(65,NULL,NULL,NULL,NULL,NULL,'GQ-250-003','http://www.ntgqbz.com/uploadfile/202501/17e02ca8a170.jpg','GQ-250-003','GQ 250 003','GQ 250 003',NULL,26,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/250ml/88.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.824877','2026-03-23 23:43:01.824877',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202501/17e02ca8a170.jpg','PE/COEX','270ml','250ml','27mm','156mm','56.5mm','74mm*175mm',NULL),(66,NULL,NULL,NULL,NULL,NULL,'GQ-2L-201','http://www.ntgqbz.com/uploadfile/202412/14420351bd8391e.jpg','GQ-2L-201','GQ 2L 201','GQ 2L 201',NULL,27,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/2L/36.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.845759','2026-03-23 23:43:01.845759',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/14420351bd8391e.jpg','PE/COEX','2.3L','2L','42mm','203mm','','',NULL),(67,NULL,NULL,NULL,NULL,NULL,'GQ-2.5L-201','http://www.ntgqbz.com/uploadfile/202503/2a4e64c465b3d21.jpg','GQ-2.5L-201','GQ 2 5L 201','GQ 2 5L 201',NULL,27,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/2_5L/117.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.861633','2026-03-23 23:43:01.861633',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/2a4e64c465b3d21.jpg','PE/COEX','2.8L','2L','42mm','232mm','','',NULL),(68,NULL,NULL,NULL,NULL,NULL,'GQ-3L-202','http://www.ntgqbz.com/uploadfile/202602/c351831ea52d0b1.png','GQ-3L-202','GQ 3L 202','GQ 3L 202',NULL,28,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/3L/149.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.878323','2026-03-23 23:43:01.878323',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202602/c351831ea52d0b1.png','PE/COEX','3.56L','3L','45mm','242mm','','',NULL),(69,NULL,NULL,NULL,NULL,NULL,'GQ-3L-201','http://www.ntgqbz.com/uploadfile/202412/58a3c0357b84e6c.jpg','GQ-3L-201','GQ 3L 201','GQ 3L 201',NULL,28,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/3L/49.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.897638','2026-03-23 23:43:01.897638',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/58a3c0357b84e6c.jpg','PE/COEX','3.35L','3L','37mm','252mm','','',NULL),(70,NULL,NULL,NULL,NULL,NULL,'GQ-3.5L-201','http://www.ntgqbz.com/uploadfile/202503/8bd51472e2dbe27.jpg','GQ-3.5L-201','GQ 3 5L 201','GQ 3 5L 201',NULL,29,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/3_5L/118.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.927714','2026-03-23 23:43:01.927714',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/8bd51472e2dbe27.jpg','PE/COEX','3.85L','3.5L','38mm','268mm','','',NULL),(71,NULL,NULL,NULL,NULL,NULL,'GQ-3.5L-202','http://www.ntgqbz.com/uploadfile/202412/501778f22559011.jpg','GQ-3.5L-202','GQ 3 5L 202','GQ 3 5L 202',NULL,29,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/3_5L/38.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.945946','2026-03-23 23:43:01.945946',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/501778f22559011.jpg','PE/COEX','3.75L','3.5L','45mm','234mm','','',NULL),(72,NULL,NULL,NULL,NULL,NULL,'GQ-400-001','http://www.ntgqbz.com/uploadfile/202412/740beecc0258306.jpg','GQ-400-001','GQ 400 001','GQ 400 001',NULL,30,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/400ml/48.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.960890','2026-03-23 23:43:01.960890',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/740beecc0258306.jpg','PE/COEX','430ml','400ml','42mm','180mm','66mm','109mm*203mm',NULL),(73,NULL,NULL,NULL,1,NULL,'4L PE桶','http://www.ntgqbz.com/uploadfile/202503/66d6413cace5f.jpg','GQ-4L-202','4L PE t','4L PE tong',NULL,31,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/4L/116.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.977035','2026-03-30 20:24:42.881920',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/66d6413cace5f.jpg','PE/COEX','4.3L','4L','45mm','300mm','','','260'),(74,NULL,NULL,NULL,NULL,NULL,'GQ-4L-205','http://www.ntgqbz.com/uploadfile/202505/27b529c5649af.jpg','GQ-4L-205','GQ 4L 205','GQ 4L 205',NULL,31,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/4L/130.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:01.992778','2026-03-23 23:43:01.992778',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202505/27b529c5649af.jpg','PE/COEX','4385±60ml','4L','63.8mm','301±2mm','','',NULL),(75,NULL,NULL,NULL,NULL,NULL,'GQ-4L-201','http://www.ntgqbz.com/uploadfile/202412/32eff6475b20b4e.jpg','GQ-4L-201','GQ 4L 201','GQ 4L 201',NULL,31,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/4L/52.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.021648','2026-03-23 23:43:02.021648',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/32eff6475b20b4e.jpg','PE/COEX','4.3L','4L','42mm','245mm','','',NULL),(76,NULL,NULL,NULL,NULL,NULL,'GQ-4L-203','http://www.ntgqbz.com/uploadfile/202503/1ca8cc9c50adf94.jpg','GQ-4L-203','GQ 4L 203','GQ 4L 203',NULL,31,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/4L/94.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.047236','2026-03-23 23:43:02.047236',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/1ca8cc9c50adf94.jpg','PE/COEX','4460ml','4L','63.5mm','291.3mm','','',NULL),(77,NULL,NULL,NULL,NULL,NULL,'GQ-4L-204','http://www.ntgqbz.com/uploadfile/202502/fa0eb119b27c838.jpg','GQ-4L-204','GQ 4L 204','GQ 4L 204',NULL,31,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/4L/95.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.057344','2026-03-23 23:43:02.057344',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202502/fa0eb119b27c838.jpg','PE/COEX','4560ml','4L','45mm','285mm','','',NULL),(78,NULL,NULL,NULL,NULL,NULL,'GQ-500-009','http://www.ntgqbz.com/uploadfile/202503/4cec1505f132b8b.jpg','GQ-500-009','GQ 500 009','GQ 500 009',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/111.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.078133','2026-03-23 23:43:02.078133',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/4cec1505f132b8b.jpg','PE/COEX','570ml','500ml','32mm','189mm','73mm','112mm*224mm',NULL),(79,NULL,NULL,NULL,NULL,NULL,'GQ-500-016','http://www.ntgqbz.com/uploadfile/202511/7e7987f6aae4590.jpg','GQ-500-016','GQ 500 016','GQ 500 016',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/141.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.102188','2026-03-23 23:43:02.102188',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202511/7e7987f6aae4590.jpg','PE/COEX','610ml','500ml','45mm','150mm','长76mm*宽76mm','81mm*278mm',NULL),(80,NULL,NULL,NULL,NULL,NULL,'GQ-500-001','http://www.ntgqbz.com/uploadfile/202412/7ec49e7e1bbd41.jpg','GQ-500-001','GQ 500 001','GQ 500 001',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/45.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.112801','2026-03-23 23:43:02.112801',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/7ec49e7e1bbd41.jpg','PE/COEX','560ml','500ml','41mm','191mm','69mm','105mm*214mm',NULL),(81,NULL,NULL,NULL,NULL,NULL,'GQ-500-002','http://www.ntgqbz.com/uploadfile/202412/8446ce6526af7e2.jpg','GQ-500-002','GQ 500 002','GQ 500 002',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/53.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.138032','2026-03-23 23:43:02.138032',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/8446ce6526af7e2.jpg','PE/COEX','560ml','500ml','44.5mm','194mm','69mm','105mm*214mm',NULL),(82,NULL,NULL,NULL,NULL,NULL,'GQ-500-003','http://www.ntgqbz.com/uploadfile/202411/169ea1b45cc5f5d.jpg','GQ-500-003','GQ 500 003','GQ 500 003',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/60.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.153705','2026-03-23 23:43:02.153705',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/169ea1b45cc5f5d.jpg','PE/COEX','560ml','500ml','50mm','191mm','69mm','105mm*217mm',NULL),(83,NULL,NULL,NULL,NULL,NULL,'GQ-500-004','http://www.ntgqbz.com/uploadfile/202411/7c543b285942281.jpg','GQ-500-004','GQ 500 004','GQ 500 004',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/62.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.165940','2026-03-23 23:43:02.165940',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/7c543b285942281.jpg','PE/COEX','550ml','500ml','45mm','174mm','75mm','97mm*232mm',NULL),(84,NULL,NULL,NULL,NULL,NULL,'GQ-500-005','http://www.ntgqbz.com/uploadfile/202411/68c712e8939ec43.jpg','GQ-500-005','GQ 500 005','GQ 500 005',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/64.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.187751','2026-03-23 23:43:02.187751',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/68c712e8939ec43.jpg','PE/COEX','580ml','500ml','50mm','138.7mm','88.7mm','53mm*274mm',NULL),(85,NULL,NULL,NULL,NULL,NULL,'GQ-500-006','http://www.ntgqbz.com/uploadfile/202412/992658130313f75.jpg','GQ-500-006','GQ 500 006','GQ 500 006',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/65.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.248801','2026-03-23 23:43:02.248801',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/992658130313f75.jpg','PE/COEX','560ml','500ml','50mm','188mm','70mm','110mm*218mm',NULL),(86,NULL,NULL,NULL,NULL,NULL,'GQ-500-008','http://www.ntgqbz.com/uploadfile/202412/30c934335db3e23.jpg','GQ-500-008','GQ 500 008','GQ 500 008',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/69.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.260347','2026-03-23 23:43:02.260347',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/30c934335db3e23.jpg','PE/COEX','590ml','500ml','50mm','209mm','68mm','146mm*211mm',NULL),(87,NULL,NULL,NULL,NULL,NULL,'GQ-500-011','http://www.ntgqbz.com/uploadfile/202412/c791b7898679.jpg','GQ-500-011','GQ 500 011','GQ 500 011',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/71.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.268615','2026-03-23 23:43:02.268615',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/c791b7898679.jpg','PE/COEX','550ml','500ml','49.5mm','200.5mm','68.7mm','113mm*215mm',NULL),(88,NULL,NULL,NULL,NULL,NULL,'GQ-500-014','http://www.ntgqbz.com/uploadfile/202511/d1ebbbc39293734.jpg','GQ-500-014','GQ 500 014','GQ 500 014',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/72.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.289409','2026-03-23 23:43:02.289409',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202511/d1ebbbc39293734.jpg','PE/COEX','675ml','500ml','45mm','188mm（配量杯高度192mm）','79.5mm','85mm*247mm',NULL),(89,NULL,NULL,NULL,NULL,NULL,'GQ-500-007','http://www.ntgqbz.com/uploadfile/202411/9ec4bc76fb8e619.jpg','GQ-500-007','GQ 500 007','GQ 500 007',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/74.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.305300','2026-03-23 23:43:02.305300',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/9ec4bc76fb8e619.jpg','PE/COEX','531ml','500ml','38.5mm','162mm','81mm','82mm*252mm',NULL),(90,NULL,NULL,NULL,NULL,NULL,'GQ-500-012（专用瓶）','http://www.ntgqbz.com/uploadfile/202501/461805242b93b28.jpg','GQ-500-012（专用瓶）','GQ 500 012  zyp','GQ 500 012  zhuan yong ping',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/89.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.317684','2026-03-23 23:43:02.317684',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202501/461805242b93b28.jpg','PE/COEX','575ml','500ml','45mm','198mm','72mm','96.5mm*224mm',NULL),(91,NULL,NULL,NULL,NULL,NULL,'GQ-500-013','http://www.ntgqbz.com/uploadfile/202501/b75630d0e4b7141.jpg','GQ-500-013','GQ 500 013','GQ 500 013',NULL,32,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/500ml/90.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.336084','2026-03-23 23:43:02.336084',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202501/b75630d0e4b7141.jpg','PE/COEX','565ml','500ml','45mm','198.5mm','70.5mm','108mm*216mm',NULL),(92,NULL,NULL,NULL,NULL,NULL,'GQ-100-004','http://www.ntgqbz.com/uploadfile/202510/3a25007e3b6d19c.jpg','GQ-100-004','GQ 100 004','GQ 100 004',NULL,23,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/122.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.587478','2026-03-23 23:43:02.587478',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202510/3a25007e3b6d19c.jpg','PE/COEX','130ml','100ml','30mm','120mm','44.5mm','66mm*137mm',NULL),(93,NULL,NULL,NULL,NULL,NULL,'GQ-100-009','http://www.ntgqbz.com/uploadfile/202504/7f9ad5bd8521fa0.jpg','GQ-100-009','GQ 100 009','GQ 100 009',NULL,23,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/124.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.820271','2026-03-23 23:43:02.820271',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202504/7f9ad5bd8521fa0.jpg','PE/COEX','156ml','100ml','45mm','101.8mm（配量杯高度：102.8mm）','50.5mm','50mm*159mm',NULL),(94,NULL,NULL,NULL,NULL,NULL,'GQ-50-001','http://www.ntgqbz.com/uploadfile/202509/7cc9e13e3f83d84.jpg','GQ-50-001','GQ 50 001','GQ 50 001',NULL,33,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/137.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:02.904092','2026-03-23 23:43:02.904092',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202509/7cc9e13e3f83d84.jpg','PE/COEX','72ml','50ml','38mm','74.3mm','42mm','35mm*131mm',NULL),(95,NULL,NULL,NULL,NULL,NULL,'GQ-100-005','http://www.ntgqbz.com/uploadfile/202602/d54f83e7a1b5876.png','GQ-100-005','GQ 100 005','GQ 100 005',NULL,23,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/146.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.065842','2026-03-23 23:43:03.065842',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202602/d54f83e7a1b5876.png','PE/COEX','134ml','100ml','37mm','110mm','47.5mm','53mm*145mm',NULL),(96,NULL,NULL,NULL,NULL,NULL,'GQ-100-003','http://www.ntgqbz.com/uploadfile/202411/dc199bd5da63255.jpg','GQ-100-003','GQ 100 003','GQ 100 003',NULL,23,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/31.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.273162','2026-03-23 23:43:03.273162',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/dc199bd5da63255.jpg','PE/COEX','130ml','100ml','38mm','110mm（配量杯高度：111mm）','43mm','60mm*135mm',NULL),(97,NULL,NULL,NULL,1,NULL,'1L瓶子','http://www.ntgqbz.com/uploadfile/202501/df846e59f190764.jpg','GQ-100-010（专用瓶）','1L pz','1L ping zi',NULL,23,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/50ml_150ml/87.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.306368','2026-03-30 20:24:01.888153',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202501/df846e59f190764.jpg','PE/COEX','116ml','100ml','27mm','106mm','46mm','44mm*142mm','260'),(98,NULL,NULL,NULL,NULL,NULL,'GQ-5L-208','http://www.ntgqbz.com/uploadfile/202502/b698f60e3ab1cca.jpg','GQ-5L-208','GQ 5L 208','GQ 5L 208',NULL,34,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/110.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.362264','2026-03-23 23:43:03.362264',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202502/b698f60e3ab1cca.jpg','PE/COEX','5.7L','5L','42mm','296mm','','',NULL),(99,NULL,NULL,NULL,NULL,NULL,'GQ-5L-207','http://www.ntgqbz.com/uploadfile/202503/fc4314fc288e3fd.jpg','GQ-5L-207','GQ 5L 207','GQ 5L 207',NULL,34,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/119.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.387222','2026-03-23 23:43:03.387222',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/fc4314fc288e3fd.jpg','PE/COEX','5.7L','5L','45mm','330mm','176mm','120mm*543mm',NULL),(100,NULL,NULL,NULL,NULL,NULL,'GQ-5L-210','http://www.ntgqbz.com/uploadfile/202512/26b2e847bb953aa.jpg','GQ-5L-210','GQ 5L 210','GQ 5L 210',NULL,34,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/143.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.431282','2026-03-23 23:43:03.431282',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202512/26b2e847bb953aa.jpg','PE/COEX','5.6L','5L','63mm','310mm（配无刀口盖309mm）','','',NULL),(101,NULL,NULL,NULL,NULL,NULL,'GQ-5L-211','http://www.ntgqbz.com/uploadfile/202602/08d241428642de8.png','GQ-5L-211','GQ 5L 211','GQ 5L 211',NULL,34,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/147.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.509710','2026-03-23 23:43:03.509710',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202602/08d241428642de8.png','PE/COEX','5.5L','5L','48.8mm','304mm','','',NULL),(102,NULL,NULL,NULL,NULL,NULL,'GQ-5L-201','http://www.ntgqbz.com/uploadfile/202412/d59886c312feb6a.jpg','GQ-5L-201','GQ 5L 201','GQ 5L 201',NULL,34,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/54.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.662252','2026-03-23 23:43:03.662252',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/d59886c312feb6a.jpg','PE/COEX','5.5L','5L','42mm','290mm','','',NULL),(103,NULL,NULL,NULL,1,NULL,'5L PE桶','http://www.ntgqbz.com/uploadfile/202412/57340ccb253bbb5.jpg','GQ-5L-202','5L PE t','5L PE tong',NULL,34,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/55.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.694922','2026-03-30 20:24:27.308681',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/57340ccb253bbb5.jpg','PE/COEX','5.6L','5L','63mm','318.7mm','','','260'),(104,NULL,NULL,NULL,NULL,NULL,'GQ-5L-203','http://www.ntgqbz.com/uploadfile/202412/3071099b59943ba.jpg','GQ-5L-203','GQ 5L 203','GQ 5L 203',NULL,34,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/56.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.713976','2026-03-23 23:43:03.713976',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202412/3071099b59943ba.jpg','PE/COEX','5.3L','5L','63mm','317mm','','',NULL),(105,NULL,NULL,NULL,NULL,NULL,'GQ-5L-204','http://www.ntgqbz.com/uploadfile/202411/078292e863704a6.jpg','GQ-5L-204','GQ 5L 204','GQ 5L 204',NULL,34,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/57.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.745256','2026-03-23 23:43:03.745256',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/078292e863704a6.jpg','PE/COEX','5.6L','5L','63mm','310mm','','',NULL),(106,NULL,NULL,NULL,NULL,NULL,'GQ-5L-205','http://www.ntgqbz.com/uploadfile/202411/e5d8007e3c0bcc9.jpg','GQ-5L-205','GQ 5L 205','GQ 5L 205',NULL,34,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/58.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.771634','2026-03-23 23:43:03.771634',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/e5d8007e3c0bcc9.jpg','PE/COEX','5.3L','5L','63mm','316mm','','',NULL),(107,NULL,NULL,NULL,NULL,NULL,'GQ-5L-206','http://www.ntgqbz.com/uploadfile/202411/c8e334166bed801.jpg','GQ-5L-206','GQ 5L 206','GQ 5L 206',NULL,34,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/59.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.786650','2026-03-23 23:43:03.786650',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/c8e334166bed801.jpg','PE/COEX','5.3L','5L','63mm','320mm','','',NULL),(108,NULL,NULL,NULL,NULL,NULL,'GQ-5L-209','http://www.ntgqbz.com/uploadfile/202411/17caf5d35d6c4c4.jpg','GQ-5L-209','GQ 5L 209','GQ 5L 209',NULL,34,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/5L/70.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:03.810209','2026-03-23 23:43:03.810209',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/17caf5d35d6c4c4.jpg','PE/COEX','5.3L','5L','42mm','310mm','','',NULL),(109,NULL,NULL,NULL,NULL,NULL,'GQ-800-001','http://www.ntgqbz.com/uploadfile/202503/fbedb126d9fd9d7.jpg','GQ-800-001','GQ 800 001','GQ 800 001',NULL,35,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/800ml/121.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.019670','2026-03-23 23:43:04.019670',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/fbedb126d9fd9d7.jpg','PE/COEX','800ml','750ml','45mm','203mm','81mm','105mm*250mm',NULL),(110,NULL,NULL,NULL,NULL,NULL,'GQ-800-002','http://www.ntgqbz.com/uploadfile/202510/70be6a1d25fa167.jpg','GQ-800-002','GQ 800 002','GQ 800 002',NULL,36,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/800ml/136.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.128239','2026-03-23 23:43:04.128239',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202510/70be6a1d25fa167.jpg','PE/COEX','890ml','800ml','45mm','206mm','85mm','127mm*262mm',NULL),(111,NULL,NULL,NULL,NULL,NULL,'GQ-900-001','http://www.ntgqbz.com/uploadfile/202503/8cdc9865698bcf2.jpg','GQ-900-001','GQ 900 001','GQ 900 001',NULL,37,0.00,0.00,0.00,'http://www.ntgqbz.com/product/PE_COEX_bottle/900ml/115.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.224200','2026-03-23 23:43:04.224200',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/8cdc9865698bcf2.jpg','PE/COEX','1000ml','900ml','45mm','229mm','82mm','128mm*253mm',NULL),(112,NULL,NULL,NULL,NULL,NULL,'GQ-20L-306','http://www.ntgqbz.com/uploadfile/202503/4dd566cbf207ab.jpg','GQ-20L-306','GQ 20L 306','GQ 20L 306',NULL,38,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/120.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.574256','2026-03-23 23:43:04.574256',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202503/4dd566cbf207ab.jpg','PE/COEX','22L','20L','60mm','','','',NULL),(113,NULL,NULL,NULL,NULL,NULL,'GQ-20L-308','http://www.ntgqbz.com/uploadfile/202507/123bc2b4300769.jpg','GQ-20L-308','GQ 20L 308','GQ 20L 308',NULL,38,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/131.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.685900','2026-03-23 23:43:04.685900',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202507/123bc2b4300769.jpg','PE/COEX','21.3L','20L','64.5mm','','','',NULL),(114,NULL,NULL,NULL,NULL,NULL,'GQ-20L-303','http://www.ntgqbz.com/uploadfile/202411/be910c256651c9.jpg','GQ-20L-303','GQ 20L 303','GQ 20L 303',NULL,38,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/15.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.766951','2026-03-23 23:43:04.766951',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/be910c256651c9.jpg','PE/COEX','22L','20L','60mm','','','',NULL),(115,NULL,NULL,NULL,1,NULL,'20L PE桶','http://www.ntgqbz.com/uploadfile/202411/576dacc4aeb9bc1.jpg','GQ-20L-304','20L PE t','20L PE tong',NULL,38,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/20.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.893455','2026-03-30 20:25:12.724450',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/576dacc4aeb9bc1.jpg','PE/COEX','22L','20L','60mm','','','','260'),(116,NULL,NULL,NULL,NULL,NULL,'GQ-20L-305','http://www.ntgqbz.com/uploadfile/202411/700677282997733.jpg','GQ-20L-305','GQ 20L 305','GQ 20L 305',NULL,38,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/22.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.991129','2026-03-23 23:43:04.991129',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/700677282997733.jpg','PE/COEX','20.6L','20L','60mm','','','',NULL),(117,NULL,NULL,NULL,NULL,NULL,'GQ-20L-307','http://www.ntgqbz.com/uploadfile/202411/d4a5d92d17059b7.jpg','GQ-20L-307','GQ 20L 307','GQ 20L 307',NULL,38,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/25.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:05.042103','2026-03-23 23:43:05.042103',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/d4a5d92d17059b7.jpg','PE/COEX','22L','20L','60mm','','','',NULL),(118,NULL,NULL,NULL,NULL,NULL,'GQ-20L-301','http://www.ntgqbz.com/uploadfile/202411/18a0bd500258457.jpg','GQ-20L-301','GQ 20L 301','GQ 20L 301',NULL,38,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/66.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:05.063561','2026-03-23 23:43:05.063561',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/18a0bd500258457.jpg','PE/COEX','22L','20L','57mm','','','',NULL),(119,NULL,NULL,NULL,NULL,NULL,'GQ-20L-302','http://www.ntgqbz.com/uploadfile/202411/1d1f12ee977c26c.jpg','GQ-20L-302','GQ 20L 302','GQ 20L 302',NULL,38,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/20L/67.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:05.196562','2026-03-23 23:43:05.196562',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202411/1d1f12ee977c26c.jpg','PE/COEX','22L','20L','60mm','','','',NULL),(120,NULL,NULL,NULL,NULL,NULL,'GQ-25L-301','http://www.ntgqbz.com/uploadfile/202501/99a7b3ad57d21.jpg','GQ-25L-301','GQ 25L 301','GQ 25L 301',NULL,39,0.00,0.00,0.00,'http://www.ntgqbz.com/product/stacking_bucket/25L/81.html',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-03-23 23:43:05.263060','2026-03-23 23:43:05.263060',NULL,0,NULL,0.00,NULL,'http://www.ntgqbz.com/uploadfile/202501/99a7b3ad57d21.jpg','PE/COEX','27L','25L','57mm','','','',NULL);
/*!40000 ALTER TABLE `mat_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mat_suppliers`
--

DROP TABLE IF EXISTS `mat_suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mat_suppliers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `labels` json DEFAULT NULL,
  `custom_fields` json DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `pinyin` varchar(255) DEFAULT NULL,
  `min_qty` decimal(12,2) DEFAULT '0.00',
  `price` decimal(12,2) DEFAULT '0.00',
  `currency_id` int DEFAULT NULL,
  `c` varchar(255) DEFAULT NULL,
  `delay` int DEFAULT NULL,
  `is_main` tinyint(1) DEFAULT NULL,
  `sort` float DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mat_suppliers_on_company_id` (`company_id`),
  KEY `index_mat_suppliers_on_currency_id` (`currency_id`),
  KEY `index_mat_suppliers_on_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mat_suppliers`
--

LOCK TABLES `mat_suppliers` WRITE;
/*!40000 ALTER TABLE `mat_suppliers` DISABLE KEYS */;
/*!40000 ALTER TABLE `mat_suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mat_values`
--

DROP TABLE IF EXISTS `mat_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mat_values` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `attribute_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `extra_price` decimal(12,2) DEFAULT '0.00',
  `sort` float DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mat_values_on_attribute_id` (`attribute_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mat_values`
--

LOCK TABLES `mat_values` WRITE;
/*!40000 ALTER TABLE `mat_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `mat_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_signs`
--

DROP TABLE IF EXISTS `menu_signs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_signs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `menu_id` int DEFAULT NULL,
  `sign` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_menu_signs_on_menu_id` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_signs`
--

LOCK TABLES `menu_signs` WRITE;
/*!40000 ALTER TABLE `menu_signs` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu_signs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menus`
--

DROP TABLE IF EXISTS `menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menus` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `path` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `is_link` varchar(255) DEFAULT NULL,
  `is_hide` tinyint(1) DEFAULT '0',
  `is_full_page` tinyint(1) DEFAULT '0',
  `is_iframe` tinyint(1) DEFAULT '0',
  `keep_alive` tinyint(1) DEFAULT '0',
  `active_path` varchar(255) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `component` varchar(255) DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `signs` varchar(255) DEFAULT NULL,
  `folder_id` int DEFAULT NULL,
  `menu_type` varchar(255) DEFAULT NULL,
  `is_enable` tinyint(1) DEFAULT '1',
  `show_badge` tinyint(1) DEFAULT '0',
  `fixed_tab` tinyint(1) DEFAULT '0',
  `is_hide_tab` tinyint(1) DEFAULT '0',
  `show_text_badge` varchar(255) DEFAULT '',
  `is_affix` tinyint(1) DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_menus_on_ancestry` (`ancestry`),
  KEY `index_menus_on_company_id` (`company_id`),
  KEY `idx_parent_id_sort_created` (`parent_id`,`id`,`sort`,`created_at`),
  KEY `idx_parent_type_sort_created` (`parent_id`,`menu_type`,`sort`,`created_at`),
  KEY `idx_parent_sort_created` (`parent_id`,`sort`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=388 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menus`
--

LOCK TABLES `menus` WRITE;
/*!40000 ALTER TABLE `menus` DISABLE KEYS */;
INSERT INTO `menus` VALUES (150,'/dashboard','Dashboard',NULL,'ri:pie-chart-line','menus.dashboard.title',NULL,0,0,0,0,NULL,0,NULL,NULL,NULL,'2025-11-21 10:08:39.331968','2025-11-21 10:08:39.331968','/index/index',NULL,'',NULL,'menu',1,0,0,0,'',NULL,NULL),(151,'console','Console',NULL,NULL,'menus.dashboard.console',NULL,0,0,0,0,NULL,0,NULL,150,NULL,'2025-11-21 10:08:39.344663','2025-11-21 10:08:39.344663','/dashboard/console',NULL,'',NULL,'menu',1,0,0,0,'',NULL,'150'),(152,'/system','System','','ri:settings-line','menus.system.title',NULL,0,0,0,0,'',9999,NULL,NULL,NULL,'2025-11-21 10:08:39.364605','2026-02-26 20:22:08.526319','/index/index',NULL,'',NULL,'menu',1,0,0,0,'',NULL,NULL),(153,'user','User','','ri:user-3-line','menus.system.user',NULL,0,0,0,0,'',1,NULL,152,NULL,'2025-11-21 10:08:39.381448','2026-01-15 16:52:33.214449','/system/user',NULL,'',NULL,'menu',1,0,0,0,'',NULL,'152'),(154,'user-center','UserCenter',NULL,NULL,'menus.system.userCenter',NULL,1,0,0,0,NULL,0,NULL,152,NULL,'2025-11-21 10:08:39.393933','2025-11-21 10:08:39.393933','/system/user-center',NULL,'',NULL,'menu',1,0,0,0,'',NULL,'152'),(155,'user-view','UserView',NULL,NULL,'menus.system.userView',NULL,1,0,0,0,NULL,0,NULL,152,NULL,'2025-11-21 10:08:39.399947','2025-11-21 10:08:39.399947','/system/user/user-view',NULL,'',NULL,'menu',1,0,0,0,'',NULL,'152'),(156,'role','Role','','ri:door-lock-line','menus.system.role',NULL,0,0,0,0,'',1,NULL,152,NULL,'2025-11-21 10:08:39.409818','2026-01-15 16:53:13.185804','/system/role',NULL,'',NULL,'menu',1,0,0,0,'',NULL,'152'),(157,'menu','Menu','','ri:align-item-horizontal-center-fill','menus.system.menu',NULL,0,0,0,0,NULL,1,NULL,152,NULL,'2025-11-21 10:08:39.418750','2025-12-10 14:52:51.346713','/system/menu',NULL,'',NULL,'menu',1,0,0,0,'',NULL,'152'),(176,'','add','','','新增',NULL,0,0,0,0,NULL,1,NULL,157,NULL,'2025-12-05 16:56:45.016053','2025-12-10 15:12:24.403255','',NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/157'),(179,'rms','Rms','','ri:a-b','menus.rms.title',NULL,0,0,0,0,'',6,NULL,NULL,NULL,'2025-12-10 15:13:22.910740','2026-03-24 13:57:56.287496','/index/index',NULL,NULL,42,'menu',0,0,0,0,'',NULL,NULL),(180,'recipe-handovers','Rms::RecipeHandover','','','menus.rms.recipeHandovers',NULL,0,0,0,0,'',1,NULL,179,NULL,'2025-12-10 18:18:24.671105','2026-03-17 17:11:39.893319','/rms/recipe-handovers',NULL,NULL,43,'menu',0,0,0,0,'',NULL,'179'),(185,'department','Department','','ri:node-tree','menus.system.department',NULL,0,0,0,0,'',6,NULL,152,NULL,'2025-12-11 16:45:52.078528','2025-12-23 23:40:59.484077','/system/department/index',NULL,NULL,48,'menu',1,0,0,0,'',NULL,'152'),(252,NULL,'',NULL,NULL,'',NULL,0,0,0,0,NULL,NULL,NULL,152,NULL,'2025-12-23 21:54:54.160562','2025-12-23 21:54:54.160562',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152'),(255,'department/view/:id','DepartmentView','','ri:slideshow-view','menus.system.department_view',NULL,1,0,0,0,'',6,NULL,152,NULL,'2025-12-23 22:04:38.061706','2025-12-23 22:05:12.284704','/system/department/department-view',NULL,NULL,51,'menu',1,0,0,0,'',NULL,'152'),(267,NULL,'add',NULL,NULL,'新增',NULL,0,0,0,0,NULL,NULL,NULL,185,NULL,'2025-12-24 00:05:58.557716','2025-12-24 00:05:58.557716',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/185'),(268,NULL,'delete',NULL,NULL,'删除',NULL,0,0,0,0,NULL,NULL,NULL,185,NULL,'2025-12-24 00:05:58.579203','2025-12-24 00:05:58.579203',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/185'),(269,NULL,'edit',NULL,NULL,'编辑',NULL,0,0,0,0,NULL,NULL,NULL,185,NULL,'2025-12-24 00:05:58.584985','2025-12-24 00:05:58.584985',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/185'),(270,NULL,'view',NULL,NULL,'查看',NULL,0,0,0,0,NULL,NULL,NULL,185,NULL,'2025-12-24 00:05:58.589710','2025-12-24 00:05:58.589710',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/185'),(271,NULL,'clone',NULL,NULL,'克隆',NULL,0,0,0,0,NULL,NULL,NULL,185,NULL,'2025-12-24 00:05:58.593544','2025-12-24 00:05:58.593544',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/185'),(272,NULL,'batchAdd',NULL,NULL,'批量新增',NULL,0,0,0,0,NULL,NULL,NULL,185,NULL,'2025-12-24 00:05:58.596684','2025-12-24 00:05:58.596684',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/185'),(273,NULL,'batchEdit',NULL,NULL,'批量修改',NULL,0,0,0,0,NULL,NULL,NULL,185,NULL,'2025-12-24 00:05:58.604961','2025-12-24 00:05:58.604961',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/185'),(274,NULL,'batchDelete',NULL,NULL,'批量删除',NULL,0,0,0,0,NULL,NULL,NULL,185,NULL,'2025-12-24 00:05:58.613171','2025-12-24 00:05:58.613171',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/185'),(275,NULL,'import',NULL,NULL,'导入',NULL,0,0,0,0,NULL,NULL,NULL,185,NULL,'2025-12-24 00:05:58.627261','2025-12-24 00:05:58.627261',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/185'),(276,NULL,'export',NULL,NULL,'导出',NULL,0,0,0,0,NULL,NULL,NULL,185,NULL,'2025-12-24 00:05:58.635462','2025-12-24 00:05:58.635462',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/185'),(277,NULL,'add',NULL,NULL,'新增',NULL,0,0,0,0,NULL,NULL,NULL,153,NULL,'2025-12-24 11:00:48.090238','2025-12-24 11:00:48.090238',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/153'),(278,NULL,'delete',NULL,NULL,'删除',NULL,0,0,0,0,NULL,NULL,NULL,153,NULL,'2025-12-24 11:00:48.242907','2025-12-24 11:00:48.242907',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/153'),(279,NULL,'edit',NULL,NULL,'编辑',NULL,0,0,0,0,NULL,NULL,NULL,153,NULL,'2025-12-24 11:00:48.267702','2025-12-24 11:00:48.267702',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/153'),(280,NULL,'view',NULL,NULL,'查看',NULL,0,0,0,0,NULL,NULL,NULL,153,NULL,'2025-12-24 11:00:48.284101','2025-12-24 11:00:48.284101',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/153'),(281,NULL,'clone',NULL,NULL,'克隆',NULL,0,0,0,0,NULL,NULL,NULL,153,NULL,'2025-12-24 11:00:48.303952','2025-12-24 11:00:48.303952',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/153'),(282,NULL,'batchAdd',NULL,NULL,'批量新增',NULL,0,0,0,0,NULL,NULL,NULL,153,NULL,'2025-12-24 11:00:48.427146','2025-12-24 11:00:48.427146',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/153'),(283,NULL,'batchEdit',NULL,NULL,'批量修改',NULL,0,0,0,0,NULL,NULL,NULL,153,NULL,'2025-12-24 11:00:48.447291','2025-12-24 11:00:48.447291',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/153'),(284,NULL,'batchDelete',NULL,NULL,'批量删除',NULL,0,0,0,0,NULL,NULL,NULL,153,NULL,'2025-12-24 11:00:48.468075','2025-12-24 11:00:48.468075',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/153'),(285,NULL,'import',NULL,NULL,'导入',NULL,0,0,0,0,NULL,NULL,NULL,153,NULL,'2025-12-24 11:00:48.509510','2025-12-24 11:00:48.509510',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/153'),(286,NULL,'export',NULL,NULL,'导出',NULL,0,0,0,0,NULL,NULL,NULL,153,NULL,'2025-12-24 11:00:48.525944','2025-12-24 11:00:48.525944',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/153'),(287,NULL,'add',NULL,NULL,'新增',NULL,0,0,0,0,NULL,NULL,NULL,156,NULL,'2025-12-27 22:16:00.211242','2025-12-27 22:16:00.211242',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/156'),(288,NULL,'delete',NULL,NULL,'删除',NULL,0,0,0,0,NULL,NULL,NULL,156,NULL,'2025-12-27 22:16:00.269749','2025-12-27 22:16:00.269749',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/156'),(289,NULL,'edit',NULL,NULL,'编辑',NULL,0,0,0,0,NULL,NULL,NULL,156,NULL,'2025-12-27 22:16:00.279328','2025-12-27 22:16:00.279328',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/156'),(290,NULL,'view',NULL,NULL,'查看',NULL,0,0,0,0,NULL,NULL,NULL,156,NULL,'2025-12-27 22:16:00.285288','2025-12-27 22:16:00.285288',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/156'),(291,NULL,'clone',NULL,NULL,'克隆',NULL,0,0,0,0,NULL,NULL,NULL,156,NULL,'2025-12-27 22:16:00.290188','2025-12-27 22:16:00.290188',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/156'),(292,NULL,'batchAdd',NULL,NULL,'批量新增',NULL,0,0,0,0,NULL,NULL,NULL,156,NULL,'2025-12-27 22:16:00.297427','2025-12-27 22:16:00.297427',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/156'),(293,NULL,'batchEdit',NULL,NULL,'批量修改',NULL,0,0,0,0,NULL,NULL,NULL,156,NULL,'2025-12-27 22:16:00.305658','2025-12-27 22:16:00.305658',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/156'),(294,NULL,'batchDelete',NULL,NULL,'批量删除',NULL,0,0,0,0,NULL,NULL,NULL,156,NULL,'2025-12-27 22:16:00.310242','2025-12-27 22:16:00.310242',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/156'),(295,NULL,'import',NULL,NULL,'导入',NULL,0,0,0,0,NULL,NULL,NULL,156,NULL,'2025-12-27 22:16:00.313497','2025-12-27 22:16:00.313497',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/156'),(296,NULL,'export',NULL,NULL,'导出',NULL,0,0,0,0,NULL,NULL,NULL,156,NULL,'2025-12-27 22:16:00.318676','2025-12-27 22:16:00.318676',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,'152/156'),(297,'setting','Setting','','ri:settings-line','menus.system.setting',NULL,0,0,0,0,'',6,NULL,152,NULL,'2026-01-05 09:43:56.841443','2026-01-05 09:43:56.841443','/system/setting/index',NULL,NULL,52,'menu',1,0,0,0,'',NULL,'152'),(298,'log','Department_clone','','ri:blogger-line','menus.system.log',NULL,0,0,0,0,'',6,NULL,152,NULL,'2026-01-11 19:15:16.625174','2026-01-11 19:15:16.625174','/system/log/index',NULL,NULL,53,'menu',1,0,0,0,'',NULL,'152'),(299,'company','Company','','ri:community-line','menus.system.company',NULL,0,0,0,0,'',3,NULL,152,NULL,'2026-01-12 11:38:44.878082','2026-01-15 16:51:55.165177','/system/company/index',NULL,NULL,54,'menu',1,0,0,0,'',NULL,NULL),(300,NULL,'add',NULL,NULL,'新增',NULL,0,0,0,0,NULL,NULL,NULL,299,NULL,'2026-01-12 11:46:07.999314','2026-01-12 11:46:07.999314',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,NULL),(301,NULL,'delete',NULL,NULL,'删除',NULL,0,0,0,0,NULL,NULL,NULL,299,NULL,'2026-01-12 11:46:08.252907','2026-01-12 11:46:08.252907',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,NULL),(302,NULL,'edit',NULL,NULL,'编辑',NULL,0,0,0,0,NULL,NULL,NULL,299,NULL,'2026-01-12 11:46:09.355024','2026-01-12 11:46:09.355024',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,NULL),(303,NULL,'view',NULL,NULL,'查看',NULL,0,0,0,0,NULL,NULL,NULL,299,NULL,'2026-01-12 11:46:09.634476','2026-01-12 11:46:09.634476',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,NULL),(304,NULL,'clone',NULL,NULL,'克隆',NULL,0,0,0,0,NULL,NULL,NULL,299,NULL,'2026-01-12 11:46:09.833015','2026-01-12 11:46:09.833015',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,NULL),(305,NULL,'batchAdd',NULL,NULL,'批量新增',NULL,0,0,0,0,NULL,NULL,NULL,299,NULL,'2026-01-12 11:46:10.267151','2026-01-12 11:46:10.267151',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,NULL),(306,NULL,'batchEdit',NULL,NULL,'批量修改',NULL,0,0,0,0,NULL,NULL,NULL,299,NULL,'2026-01-12 11:46:10.554851','2026-01-12 11:46:10.554851',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,NULL),(307,NULL,'batchDelete',NULL,NULL,'批量删除',NULL,0,0,0,0,NULL,NULL,NULL,299,NULL,'2026-01-12 11:46:10.570073','2026-01-12 11:46:10.570073',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,NULL),(308,NULL,'import',NULL,NULL,'导入',NULL,0,0,0,0,NULL,NULL,NULL,299,NULL,'2026-01-12 11:46:10.595975','2026-01-12 11:46:10.595975',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,NULL),(309,NULL,'export',NULL,NULL,'导出',NULL,0,0,0,0,NULL,NULL,NULL,299,NULL,'2026-01-12 11:46:10.721726','2026-01-12 11:46:10.721726',NULL,NULL,NULL,NULL,'btn',1,0,0,0,'',NULL,NULL),(310,'/crm','Sale','','ri:projector-line','menus.sale.title',NULL,0,0,0,0,'',2,NULL,NULL,NULL,'2026-01-14 19:01:52.138230','2026-03-24 19:10:23.889443','/index/index',NULL,NULL,55,'menu',1,0,0,0,'',NULL,NULL),(315,'/mat','Product','','ri:ai-generate-3d-line','menus.mat.products',NULL,0,0,0,0,'',1,NULL,NULL,NULL,'2026-01-23 14:36:43.897369','2026-03-24 13:59:42.443920','/index/index',NULL,NULL,60,'menu',1,1,0,0,'New',NULL,NULL),(318,'product-combo','Mat::ProductCombo','','ri:archive-stack-line','menus.mat.product-combo',NULL,0,0,0,0,'',1,NULL,315,NULL,'2026-01-23 14:54:08.318052','2026-03-24 13:56:05.659055','/mat/product-combo',NULL,NULL,63,'menu',0,0,0,0,'',NULL,NULL),(319,'mat/products/:id','Mat::Product','','ri:ai-generate','menus.mat.product_detail',NULL,1,0,0,0,'',1,NULL,315,NULL,'2026-01-23 15:51:58.004270','2026-01-23 20:40:53.147047','/mat/products/detail',NULL,NULL,64,'menu',1,0,0,0,'',NULL,NULL),(320,'product','Mat::Product','','ri:archive-stack-line','menus.mat.product',NULL,0,0,0,0,'',1,NULL,315,NULL,'2026-01-24 14:02:53.607860','2026-01-24 14:02:53.607860','/mat/products',NULL,NULL,65,'menu',1,0,0,0,'',NULL,NULL),(321,'item','Mat::Item','','ri:atom-line','menus.mat.item',NULL,0,0,0,0,'',1,NULL,315,NULL,'2026-01-25 00:10:51.419336','2026-03-24 13:55:49.144307','/mat/items',NULL,NULL,66,'menu',0,0,0,0,'',NULL,NULL),(322,'supplier','Mat::Supplier','','ri:coins-fill','menus.mat.supplier',NULL,0,0,0,0,'',1,NULL,315,NULL,'2026-01-26 07:42:45.188151','2026-03-17 17:27:13.739142','/mat/suppliers',NULL,NULL,67,'menu',0,0,0,0,'',NULL,NULL),(323,'lot','Inv::Lot','','ri:align-justify','menus.inv.lot',NULL,0,0,0,0,'',1,NULL,315,NULL,'2026-01-26 22:34:20.305759','2026-03-24 13:56:00.550994','/inv/lots',NULL,NULL,68,'menu',0,0,0,0,'',NULL,NULL),(324,'/inv','inv_module','','ri:archive-stack-fill','库存管理',NULL,0,0,0,0,'',200,'库存管理模块',NULL,NULL,'2026-01-27 10:43:04.427359','2026-03-24 13:58:05.661171','/index/index',NULL,NULL,NULL,'menu',0,0,0,0,'',NULL,NULL),(325,'lots','inv_lots','','','批次序列号',NULL,0,0,0,0,'',201,'库存管理 - 批次序列号',324,NULL,'2026-01-27 10:43:04.451673','2026-02-28 11:30:52.330434','/inv/lots',NULL,NULL,NULL,'menu',0,0,0,0,'',NULL,NULL),(326,'inventories','inv_inventories','','','库存',NULL,0,0,0,0,'',202,'库存管理 - 库存',324,NULL,'2026-01-27 10:43:04.468187','2026-02-28 11:30:52.336878','/inv/inventories',NULL,NULL,NULL,'menu',0,0,0,0,'',NULL,NULL),(327,'inventory_transactions','inv_inventory_transactions','','','库存流水',NULL,0,0,0,0,'',203,'库存管理 - 库存流水',324,NULL,'2026-01-27 10:43:04.486400','2026-03-17 12:23:16.902436','/inv/inventory-transactions',NULL,NULL,NULL,'menu',0,0,0,0,'',NULL,NULL),(328,'inventory_locks','inv_inventory_locks','','','库存预占',NULL,0,0,0,0,'',204,'库存管理 - 库存预占',324,NULL,'2026-01-27 10:43:04.495526','2026-03-17 12:22:40.006224','/inv/inventory-locks',NULL,NULL,NULL,'menu',0,0,0,0,'',NULL,NULL),(329,'/wms','wms_module','','ri:building-line','仓库管理',NULL,0,0,0,0,'',300,'仓库管理模块',NULL,NULL,'2026-01-27 10:43:04.508854','2026-03-17 12:25:34.894128','/index/index',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(330,'warehouses','wms_warehouses','','','仓库',NULL,0,0,0,0,'',301,'仓库管理 - 仓库',329,NULL,'2026-01-27 10:43:04.514025','2026-02-28 11:30:52.388657','/wms/warehouses',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(331,'areas','wms_areas','','','库区',NULL,0,0,0,0,'',302,'仓库管理 - 库区',329,NULL,'2026-01-27 10:43:04.522124','2026-02-28 11:30:52.397793','/wms/areas',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(332,'locations','wms_locations','','','货位',NULL,0,0,0,0,'',303,'仓库管理 - 货位',329,NULL,'2026-01-27 10:43:04.536810','2026-02-28 11:30:52.413027','/wms/locations',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(333,'pick_orders','wms_pick_orders','','','领料单',NULL,0,0,0,0,'',304,'仓库管理 - 领料单',329,NULL,'2026-01-27 10:43:04.550554','2026-03-17 12:23:31.171809','/wms/pick-orders',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(334,'receive_orders','wms_receive_orders','','','入库单',NULL,0,0,0,0,'',305,'仓库管理 - 入库单',329,NULL,'2026-01-27 10:43:04.556366','2026-03-17 12:23:55.713970','/wms/receive-orders',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(335,'return_orders','wms_return_orders','','','退货单',NULL,0,0,0,0,'',306,'仓库管理 - 退货单',329,NULL,'2026-01-27 10:43:04.578801','2026-03-17 12:23:38.028845','/wms/return-orders',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(336,'transfer_orders','wms_transfer_orders','','','调拨单',NULL,0,0,0,0,'',307,'仓库管理 - 调拨单',329,NULL,'2026-01-27 10:43:04.587165','2026-03-17 12:23:46.783362','/wms/transfer-orders',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(337,'/mfg','mfg_module','','ri:robot-2-line','生产管理',NULL,0,0,0,0,'',400,'生产管理模块',NULL,NULL,'2026-01-27 10:43:04.591114','2026-03-17 12:25:39.289766','/index/index',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(338,'orders','mfg_orders','','','生产订单',NULL,0,0,0,0,'',401,'生产管理 - 生产订单',337,NULL,'2026-01-27 10:43:04.596231','2026-02-28 11:30:52.472798','/mfg/orders',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(339,'boms','mfg_boms','','','物料清单',NULL,0,0,0,0,'',402,'生产管理 - 物料清单',337,NULL,'2026-01-27 10:43:04.629731','2026-02-28 11:30:52.477111','/mfg/boms',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(340,'bom_byproducts','mfg_bom_byproducts','','','BOM副产品',NULL,0,0,0,0,'',403,'生产管理 - BOM副产品',337,NULL,'2026-01-27 10:43:04.637237','2026-03-17 12:24:09.330728','/mfg/bom-byproducts',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(341,'bom_losses','mfg_bom_losses','','','BOM损耗',NULL,0,0,0,0,'',404,'生产管理 - BOM损耗',337,NULL,'2026-01-27 10:43:04.649780','2026-03-17 12:24:16.620734','/mfg/bom-losses',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(342,'work_orders','mfg_work_orders','','','工单',NULL,0,0,0,0,'',405,'生产管理 - 工单',337,NULL,'2026-01-27 10:43:04.654210','2026-03-17 12:24:24.294082','/mfg/work-orders',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(343,'work_order_losses','mfg_work_order_losses','','','工单损耗',NULL,0,0,0,0,'',406,'生产管理 - 工单损耗',337,NULL,'2026-01-27 10:43:04.669551','2026-03-17 12:24:33.726856','/mfg/work-order-losses',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(344,'work_order_byproducts','mfg_work_order_byproducts','','','工单副产品',NULL,0,0,0,0,'',407,'生产管理 - 工单副产品',337,NULL,'2026-01-27 10:43:04.700543','2026-03-17 12:24:45.485849','/mfg/work-order-byproducts',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(345,'disassembly_orders','mfg_disassembly_orders','','','拆解单',NULL,0,0,0,0,'',408,'生产管理 - 拆解单',337,NULL,'2026-01-27 10:43:04.706836','2026-03-17 12:24:55.439905','/mfg/disassembly-orders',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(346,'scrap_orders','mfg_scrap_orders','','','报废单',NULL,0,0,0,0,'',409,'生产管理 - 报废单',337,NULL,'2026-01-27 10:43:04.723235','2026-03-17 12:25:04.401358','/mfg/scrap-orders',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(347,'/crm','crm','','ri:collage-line','menus.crm.title',NULL,0,0,0,0,'',3,NULL,NULL,NULL,'2026-02-26 20:21:49.956640','2026-03-24 14:35:31.825514','/index/index',NULL,NULL,69,'menu',1,0,0,0,'',NULL,NULL),(348,'client','Crm::Client','','ri:community-line','menus.crm.client',NULL,0,0,0,0,'',1,NULL,347,NULL,'2026-02-26 20:23:21.927208','2026-02-27 17:33:47.531773','/crm/clients',NULL,NULL,70,'menu',1,0,0,0,'',NULL,NULL),(349,'addresse','Crm::Address','','ri:crosshair-2-line','menus.crm.address',NULL,0,0,0,0,'',8,NULL,347,NULL,'2026-02-26 23:29:46.790984','2026-02-27 17:33:40.364624','/crm/addresses',NULL,NULL,71,'menu',1,0,0,0,'',NULL,NULL),(350,'invoice','Crm::Invoice','','ri:bill-line','menus.crm.invoice',NULL,0,0,0,0,'',4,NULL,347,NULL,'2026-02-27 17:32:00.398646','2026-03-17 17:25:45.731625','/crm/invoices',NULL,NULL,72,'menu',1,0,0,0,'',NULL,NULL),(352,'quotation','Crm::Quotation','','ri:billiards-line','menus.crm.quotation',NULL,0,0,0,0,'',8,NULL,347,NULL,'2026-02-27 17:34:29.894475','2026-03-17 17:25:56.928177','/crm/quotations',NULL,NULL,74,'menu',1,0,0,0,'',NULL,NULL),(353,'contact','Crm::Contact','','ri:account-circle-line','menus.crm.contact',NULL,0,0,0,0,'',3,NULL,347,NULL,'2026-02-27 17:35:45.123040','2026-03-17 17:25:31.221921','/crm/contacts',NULL,NULL,75,'menu',1,0,0,0,'',NULL,NULL),(354,'spec-item','Crm::SpecItem','','ri:list-indefinite','menus.crm.spec-item',NULL,0,0,0,0,'',8,NULL,347,NULL,'2026-02-27 17:40:21.604109','2026-03-24 13:59:28.927850','/crm/spec-items',NULL,NULL,76,'menu',0,0,0,0,'',NULL,NULL),(355,'handover','Crm::Handovers','','ri:arrow-left-right-line','menus.crm.handover',NULL,0,0,0,0,'',8,NULL,347,NULL,'2026-02-27 17:41:34.507890','2026-03-24 13:59:24.712022','/crm/handovers',NULL,NULL,77,'menu',0,0,0,0,'',NULL,NULL),(356,'/base','base_module','','ri:list-settings-fill','基础信息',NULL,0,0,0,0,'',9999,'基础信息模块',NULL,NULL,'2026-02-28 11:30:52.260084','2026-03-10 19:57:25.995446','/base/index',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(357,'regions','base_regions','','','行政区划',NULL,0,0,0,0,'',101,'基础信息 - 行政区划',356,NULL,'2026-02-28 11:30:52.284562','2026-03-17 17:23:30.614795','/base/regions',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(358,'properties','base_properties',NULL,NULL,'属性',NULL,0,0,0,0,NULL,102,'基础信息 - 属性',356,NULL,'2026-02-28 11:30:52.299847','2026-02-28 11:30:52.299847','/base/properties',NULL,NULL,NULL,'menu',1,0,0,0,'',NULL,NULL),(359,'/fm','fm','','ri:bill-line','menus.fm.title',NULL,0,0,0,0,'',2,NULL,NULL,NULL,'2026-03-13 11:42:00.371989','2026-03-17 14:57:28.238305','/index/index',NULL,NULL,78,'menu',1,0,0,0,'',NULL,NULL),(360,'contracts','Fm::Contract','','','menus.fm.contract',NULL,0,0,0,0,'',1,NULL,359,NULL,'2026-03-13 11:43:50.189539','2026-03-17 14:57:39.655465','/fm/contracts',NULL,NULL,79,'menu',1,0,0,0,'',NULL,NULL),(361,'doc-number-rules','Prperty','','ri:code-box-line','menus.base.docNumberRules',NULL,0,0,0,0,'',102,NULL,356,NULL,'2026-03-13 15:52:33.999022','2026-03-14 00:13:58.210222','/base/doc-number-rules',NULL,NULL,80,'menu',1,0,0,0,'',NULL,NULL),(362,'workflow-templates','Prperty','','ri:flow-chart','menus.base.workflowTemplates',NULL,0,0,0,0,'',102,NULL,356,NULL,'2026-03-14 00:15:41.830473','2026-03-14 00:15:41.830473','/base/workflow-templates',NULL,NULL,81,'menu',1,0,0,0,'',NULL,NULL),(363,'/pur','pur','','ri:bar-chart-box-ai-line','menus.pur.title',NULL,0,0,0,0,'',2,NULL,NULL,NULL,'2026-03-17 14:18:38.009351','2026-03-24 13:57:30.838462','/index/index',NULL,NULL,82,'menu',0,0,0,0,'',NULL,NULL),(364,'contracts?sign=carton','Pur::Contract','','ri:article-line','menus.pur.carton',NULL,0,0,0,0,'',1,NULL,363,NULL,'2026-03-17 14:28:22.597514','2026-03-17 15:01:28.136637','/pur/contracts',NULL,NULL,83,'menu',0,0,0,0,'',NULL,NULL),(365,'contracts?sign=raw_material','Pur::Contract','','ri:article-line','menus.pur.raw-material',NULL,0,0,0,0,'',1,NULL,363,NULL,'2026-03-17 14:59:23.492569','2026-03-17 15:24:05.055254','/pur/contracts',NULL,NULL,84,'menu',0,0,0,0,'',NULL,NULL),(366,'contracts?sign=bottle','Pur::Contract_clone','','ri:article-line','menus.pur.bottle',NULL,0,0,0,0,'',1,NULL,363,NULL,'2026-03-17 15:00:17.908187','2026-03-17 15:01:40.969895','/pur/contracts',NULL,NULL,85,'menu',0,0,0,0,'',NULL,NULL),(367,'contracts','Pur::Contract','','ri:article-line','menus.pur.contract',NULL,1,0,0,0,'',1,NULL,363,NULL,'2026-03-17 15:04:52.582031','2026-03-17 15:04:52.582031','/pur/contracts',NULL,NULL,86,'menu',0,0,0,0,'',NULL,NULL),(368,'suppliers','Pur::Supplier','','ri:pass-pending-line','menus.pur.supplier',NULL,0,0,0,0,'',1,NULL,363,NULL,'2026-03-17 15:12:30.845021','2026-03-17 15:14:41.405516','/pur/suppliers',NULL,NULL,87,'menu',0,0,0,0,'',NULL,NULL),(369,'contact','Pur::Contact','','ri:passport-line','menus.pur.contact',NULL,0,0,0,0,'',111,NULL,363,NULL,'2026-03-17 15:13:15.655330','2026-03-17 15:14:47.249715','/pur/contacts',NULL,NULL,88,'menu',0,0,0,0,'',NULL,NULL),(370,'iqc','Rms_clone','','ri:alert-line','menus.iqc.title',NULL,0,0,0,0,'',6,NULL,NULL,NULL,'2026-03-17 17:07:13.267984','2026-03-24 13:58:00.851145','/index/index',NULL,NULL,89,'menu',0,0,0,0,'',NULL,NULL),(371,'raw-inspection','Iqc::RawInspection','','ri:celsius-line','menus.iqc.raw-inspection',NULL,0,0,0,0,'',1,NULL,370,NULL,'2026-03-17 17:08:48.547744','2026-03-17 17:10:02.239098','/iqc/raw-inspections',NULL,NULL,90,'menu',0,0,0,0,'',NULL,NULL),(373,'orders','Crm::Order','','ri:archive-2-line','menus.sale.order',NULL,0,0,0,0,'',3,NULL,310,NULL,'2026-03-24 14:06:30.982612','2026-03-24 17:57:17.381322','/crm/orders',NULL,NULL,2,'menu',1,0,0,0,'',NULL,NULL),(374,'pre-orders','Crm::Order_clone','','ri:ball-pen-line','menus.sale.preOrder',NULL,0,0,0,0,'',1,NULL,310,NULL,'2026-03-24 14:36:40.465920','2026-04-06 16:45:12.994599','/crm/pre-orders/index',NULL,NULL,3,'menu',1,0,0,0,'',NULL,NULL),(375,'orders/new','Crm::OrderNew','','ri:archive-2-line','menus.crm.order_new',NULL,1,0,0,0,'',8,NULL,347,NULL,'2026-03-24 14:47:21.886132','2026-03-24 17:58:22.785074','/crm/orders/create',NULL,NULL,4,'menu',1,0,0,0,'',NULL,NULL),(376,'orders','Crm::Order','','ri:archive-2-line','menus.crm.order',NULL,1,0,0,0,'',8,NULL,347,NULL,'2026-03-24 16:22:25.161053','2026-03-24 17:58:31.868257','/crm/orders',NULL,NULL,5,'menu',1,0,0,0,'',NULL,NULL),(378,'orders/new','Crm::OrderNew','','ri:archive-2-line','menus.sale.order-create',NULL,1,0,0,0,'',1,NULL,310,NULL,'2026-03-24 17:22:40.846328','2026-03-24 19:09:35.532667','/crm/orders/create',NULL,NULL,7,'menu',1,0,0,0,'',NULL,NULL),(379,'orders/:id','Crm::OrderDetail','','ri:archive-2-line','menus.crm.orderDetail',NULL,1,0,0,0,'',8,NULL,347,NULL,'2026-03-24 17:59:52.260831','2026-03-24 17:59:52.260831','/crm/orders/detail',NULL,NULL,8,'menu',1,0,0,0,'',NULL,NULL),(380,'pre-orders','Crm::PreOrder','','ri:archive-2-line','menus.crm.pre-orders',NULL,1,0,0,0,'',8,NULL,347,NULL,'2026-03-24 19:07:48.510990','2026-03-24 19:07:48.510990','/crm/pre-orders',NULL,NULL,9,'menu',1,0,0,0,'',NULL,NULL),(381,'order-lines','Crm::OrderLine','','ri:archive-2-line','menus.sale.internalTracking',NULL,0,0,0,0,'',3,NULL,310,NULL,'2026-03-25 12:19:04.199583','2026-04-06 16:45:42.922070','/crm/order-lines',NULL,NULL,10,'menu',1,0,0,0,'',NULL,NULL),(382,'order-lines','Crm::OrderLine','','ri:archive-2-line','menus.crm.internalTracking',NULL,1,0,0,0,'',8,NULL,347,NULL,'2026-03-25 12:21:08.867222','2026-04-06 16:48:32.589234','/crm/order-lines',NULL,NULL,11,'menu',1,0,0,0,'',NULL,NULL),(385,'order-lines/:id','Crm::OrderLine','','ri:archive-2-line','menus.sale.order-detail',NULL,1,0,0,0,'',4,NULL,310,NULL,'2026-03-30 14:51:23.698898','2026-03-30 15:13:55.272004','/crm/order-lines/detail',NULL,NULL,14,'menu',1,0,0,0,'',NULL,NULL),(387,'order-lines/:id','Crm::OrderDetail_clone','','ri:archive-2-line','menus.crm.orderDetail',NULL,1,0,0,0,'',8,NULL,347,NULL,'2026-03-30 15:16:08.841284','2026-03-30 15:16:08.841284','/crm/order-lines/detail',NULL,NULL,16,'menu',1,0,0,0,'',NULL,NULL);
/*!40000 ALTER TABLE `menus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_actuals`
--

DROP TABLE IF EXISTS `mfg_actuals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_actuals` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `leader` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `date` date DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `specification` varchar(255) DEFAULT NULL,
  `spec` varchar(255) DEFAULT NULL,
  `qty` int DEFAULT NULL,
  `unit` varchar(255) DEFAULT NULL,
  `time_start` datetime(6) DEFAULT NULL,
  `time_end` datetime(6) DEFAULT NULL,
  `hour` decimal(12,2) DEFAULT '0.00',
  `planned_production_qty` varchar(255) DEFAULT NULL,
  `actual_production_qty` decimal(12,2) DEFAULT '0.00',
  `actual_production_unit` varchar(255) DEFAULT NULL,
  `worker_count` int DEFAULT NULL,
  `uncompleted_remark` varchar(255) DEFAULT NULL,
  `remark` text,
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_actuals`
--

LOCK TABLES `mfg_actuals` WRITE;
/*!40000 ALTER TABLE `mfg_actuals` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_actuals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_batching_lines`
--

DROP TABLE IF EXISTS `mfg_batching_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_batching_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `batching_id` bigint DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `batch_number` varchar(255) DEFAULT NULL,
  `qty_kg` decimal(12,2) DEFAULT '0.00',
  `content_percent` decimal(12,2) DEFAULT '0.00',
  `adjusted_qty_kg` decimal(12,2) DEFAULT '0.00',
  `remark` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_batching_lines_on_batching_id` (`batching_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_batching_lines`
--

LOCK TABLES `mfg_batching_lines` WRITE;
/*!40000 ALTER TABLE `mfg_batching_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_batching_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_batchings`
--

DROP TABLE IF EXISTS `mfg_batchings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_batchings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `production_batch_number` varchar(255) DEFAULT NULL,
  `batching_ratio` varchar(255) DEFAULT NULL,
  `batching_qty` decimal(12,2) DEFAULT '0.00',
  `production_date` date DEFAULT NULL,
  `batching_qty_recheck` decimal(12,2) DEFAULT '0.00',
  `production_requirements_notes` text,
  `order_placed_id` int DEFAULT NULL,
  `weighing_id` int DEFAULT NULL,
  `weighing_supervised_id` int DEFAULT NULL,
  `operator_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_batchings`
--

LOCK TABLES `mfg_batchings` WRITE;
/*!40000 ALTER TABLE `mfg_batchings` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_batchings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_bom_byproducts`
--

DROP TABLE IF EXISTS `mfg_bom_byproducts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_bom_byproducts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `bom_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_qty` decimal(12,2) DEFAULT '0.00',
  `product_uom_id` int DEFAULT NULL,
  `output_category` varchar(255) DEFAULT NULL,
  `is_inventory` tinyint(1) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_bom_byproducts_on_bom_id` (`bom_id`),
  KEY `index_mfg_bom_byproducts_on_product_id` (`product_id`),
  KEY `index_mfg_bom_byproducts_on_product_uom_id` (`product_uom_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_bom_byproducts`
--

LOCK TABLES `mfg_bom_byproducts` WRITE;
/*!40000 ALTER TABLE `mfg_bom_byproducts` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_bom_byproducts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_bom_lines`
--

DROP TABLE IF EXISTS `mfg_bom_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_bom_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `bom_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_qty` decimal(12,2) DEFAULT '0.00',
  `product_uom_id` int DEFAULT NULL,
  `operation_id` int DEFAULT NULL,
  `optional` tinyint(1) DEFAULT NULL,
  `alternative` tinyint(1) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_bom_lines_on_bom_id` (`bom_id`),
  KEY `index_mfg_bom_lines_on_operation_id` (`operation_id`),
  KEY `index_mfg_bom_lines_on_product_id` (`product_id`),
  KEY `index_mfg_bom_lines_on_product_uom_id` (`product_uom_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_bom_lines`
--

LOCK TABLES `mfg_bom_lines` WRITE;
/*!40000 ALTER TABLE `mfg_bom_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_bom_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_bom_losses`
--

DROP TABLE IF EXISTS `mfg_bom_losses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_bom_losses` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `bom_line_id` int DEFAULT NULL,
  `loss_mode` varchar(255) DEFAULT NULL,
  `loss_value` decimal(12,2) DEFAULT '0.00',
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_bom_losses_on_bom_line_id` (`bom_line_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_bom_losses`
--

LOCK TABLES `mfg_bom_losses` WRITE;
/*!40000 ALTER TABLE `mfg_bom_losses` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_bom_losses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_boms`
--

DROP TABLE IF EXISTS `mfg_boms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_boms` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_qty` decimal(12,2) DEFAULT '0.00',
  `uom_id` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT NULL,
  `ready_to_produce` decimal(12,2) DEFAULT '0.00',
  `picking_type_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `type_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_boms_on_company_id` (`company_id`),
  KEY `index_mfg_boms_on_picking_type_id` (`picking_type_id`),
  KEY `index_mfg_boms_on_product_id` (`product_id`),
  KEY `index_mfg_boms_on_type_id` (`type_id`),
  KEY `index_mfg_boms_on_uom_id` (`uom_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_boms`
--

LOCK TABLES `mfg_boms` WRITE;
/*!40000 ALTER TABLE `mfg_boms` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_boms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_disassembly_orders`
--

DROP TABLE IF EXISTS `mfg_disassembly_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_disassembly_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `lot_id` int DEFAULT NULL,
  `planned_qty` decimal(12,2) DEFAULT '0.00',
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_disassembly_orders_on_item_id` (`item_id`),
  KEY `index_mfg_disassembly_orders_on_lot_id` (`lot_id`),
  KEY `index_mfg_disassembly_orders_on_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_disassembly_orders`
--

LOCK TABLES `mfg_disassembly_orders` WRITE;
/*!40000 ALTER TABLE `mfg_disassembly_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_disassembly_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_oprate_lines`
--

DROP TABLE IF EXISTS `mfg_oprate_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_oprate_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `operate_id` bigint DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `batch_number` varchar(255) DEFAULT NULL,
  `qty_kg` decimal(12,2) DEFAULT '0.00',
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_oprate_lines_on_operate_id` (`operate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_oprate_lines`
--

LOCK TABLES `mfg_oprate_lines` WRITE;
/*!40000 ALTER TABLE `mfg_oprate_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_oprate_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_oprate_step_lines`
--

DROP TABLE IF EXISTS `mfg_oprate_step_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_oprate_step_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `operate_id` bigint DEFAULT NULL,
  `step_time` varchar(255) DEFAULT NULL,
  `kettle_temp` varchar(255) DEFAULT NULL,
  `step_phase` varchar(255) DEFAULT NULL,
  `step_notes` text,
  `is_edit_note` tinyint(1) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_oprate_step_lines_on_operate_id` (`operate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_oprate_step_lines`
--

LOCK TABLES `mfg_oprate_step_lines` WRITE;
/*!40000 ALTER TABLE `mfg_oprate_step_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_oprate_step_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_oprates`
--

DROP TABLE IF EXISTS `mfg_oprates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_oprates` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `batch_number` varchar(255) DEFAULT NULL,
  `qty_kl` decimal(12,2) DEFAULT '0.00',
  `record_date` date DEFAULT NULL,
  `discharge_qty` decimal(12,2) DEFAULT '0.00',
  `inspection_result` varchar(255) DEFAULT NULL,
  `rework_inspection_result` varchar(255) DEFAULT NULL,
  `second_rework_inspection_result` varchar(255) DEFAULT NULL,
  `safety_env_result` tinyint(1) DEFAULT NULL,
  `shear_kettle_result` tinyint(1) DEFAULT NULL,
  `filter_result` tinyint(1) DEFAULT NULL,
  `pump_result` tinyint(1) DEFAULT NULL,
  `special_equipment_result` tinyint(1) DEFAULT NULL,
  `equipment_status_notes` text,
  `remark` text,
  `batching_operator_id` int DEFAULT NULL,
  `operator_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_oprates`
--

LOCK TABLES `mfg_oprates` WRITE;
/*!40000 ALTER TABLE `mfg_oprates` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_oprates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_order_lines`
--

DROP TABLE IF EXISTS `mfg_order_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_order_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `bom_line_id` int DEFAULT NULL,
  `required_date` datetime(6) DEFAULT NULL,
  `required_qty` decimal(12,2) DEFAULT '0.00',
  `allocated_qty` decimal(12,2) DEFAULT '0.00',
  `available_qty` decimal(12,2) DEFAULT '0.00',
  `shortage_qty` decimal(12,2) DEFAULT '0.00',
  `status` varchar(255) DEFAULT NULL,
  `is_alternative` tinyint(1) DEFAULT NULL,
  `alternative_for_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_order_lines_on_alternative_for_id` (`alternative_for_id`),
  KEY `index_mfg_order_lines_on_bom_line_id` (`bom_line_id`),
  KEY `index_mfg_order_lines_on_item_id` (`item_id`),
  KEY `index_mfg_order_lines_on_order_id` (`order_id`),
  KEY `index_mfg_order_lines_on_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_order_lines`
--

LOCK TABLES `mfg_order_lines` WRITE;
/*!40000 ALTER TABLE `mfg_order_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_order_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_orders`
--

DROP TABLE IF EXISTS `mfg_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `bom_id` int DEFAULT NULL,
  `plan_qty` decimal(12,2) DEFAULT '0.00',
  `finish_qty` decimal(12,2) DEFAULT '0.00',
  `scrap_qty` decimal(12,2) DEFAULT '0.00',
  `status` varchar(255) DEFAULT NULL,
  `demand_date` datetime(6) DEFAULT NULL,
  `source_order_type` varchar(255) DEFAULT NULL,
  `source_order_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `warehouse_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_orders_on_bom_id` (`bom_id`),
  KEY `index_mfg_orders_on_company_id` (`company_id`),
  KEY `index_mfg_orders_on_item_id` (`item_id`),
  KEY `index_mfg_orders_on_product_id` (`product_id`),
  KEY `index_mfg_orders_on_source_order_id` (`source_order_id`),
  KEY `index_mfg_orders_on_warehouse_id` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_orders`
--

LOCK TABLES `mfg_orders` WRITE;
/*!40000 ALTER TABLE `mfg_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_pkg_handovers`
--

DROP TABLE IF EXISTS `mfg_pkg_handovers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_pkg_handovers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `form_date` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `preparer_id` int DEFAULT NULL,
  `client_id` int DEFAULT NULL,
  `contract_code` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `sign_date` varchar(255) DEFAULT NULL,
  `qty` varchar(255) DEFAULT NULL,
  `specification` varchar(255) DEFAULT NULL,
  `bottle_contract_id` int DEFAULT NULL,
  `bottle_info` text,
  `label_contract_id` int DEFAULT NULL,
  `label_info` text,
  `box_contract_id` int DEFAULT NULL,
  `box_info` text,
  `remark` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_pkg_handovers`
--

LOCK TABLES `mfg_pkg_handovers` WRITE;
/*!40000 ALTER TABLE `mfg_pkg_handovers` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_pkg_handovers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_pkg_lines`
--

DROP TABLE IF EXISTS `mfg_pkg_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_pkg_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `pkg_handover_id` int DEFAULT NULL,
  `line_id` int DEFAULT NULL,
  `record_date` date DEFAULT NULL,
  `weather` varchar(255) DEFAULT NULL,
  `temperature` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `customer_trademark_name` varchar(255) DEFAULT NULL,
  `planned_total_qty_kl` varchar(255) DEFAULT NULL,
  `planned_total_pieces` int DEFAULT NULL,
  `packaging_batch_number` varchar(255) DEFAULT NULL,
  `semi_finished_batch_number` varchar(255) DEFAULT NULL,
  `specific_gravity` decimal(12,2) DEFAULT '0.00',
  `packaging_spec` varchar(255) DEFAULT NULL,
  `net_weight_per_bottle` varchar(255) DEFAULT NULL,
  `empty_bottle_weight` varchar(255) DEFAULT NULL,
  `filling_range` varchar(255) DEFAULT NULL,
  `standard_weight_per_bottle` varchar(255) DEFAULT NULL,
  `standard_weight_per_box` varchar(255) DEFAULT NULL,
  `packaging_key_points` text,
  `formal_filling_start_time` varchar(255) DEFAULT NULL,
  `formal_filling_end_time` varchar(255) DEFAULT NULL,
  `packages_this_shift` int DEFAULT NULL,
  `filling_debug_air_pressure` varchar(255) DEFAULT NULL,
  `filling_debug_temperature` varchar(255) DEFAULT NULL,
  `filling_debug_horizontal_temp` varchar(255) DEFAULT NULL,
  `filling_debug_vertical_temp` varchar(255) DEFAULT NULL,
  `filling_debug_notes` varchar(255) DEFAULT NULL,
  `labeling_machine_result` tinyint(1) DEFAULT NULL,
  `filling_machine_result` tinyint(1) DEFAULT NULL,
  `capping_machine_result` tinyint(1) DEFAULT NULL,
  `sealing_machine_result` tinyint(1) DEFAULT NULL,
  `coding_machine_result` tinyint(1) DEFAULT NULL,
  `shrink_film_machine_result` tinyint(1) DEFAULT NULL,
  `packing_machine_result` tinyint(1) DEFAULT NULL,
  `operator_info` varchar(255) DEFAULT NULL,
  `line_foreman_id` int DEFAULT NULL,
  `other` text,
  `remark` text,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_pkg_lines`
--

LOCK TABLES `mfg_pkg_lines` WRITE;
/*!40000 ALTER TABLE `mfg_pkg_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_pkg_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_plan_lines`
--

DROP TABLE IF EXISTS `mfg_plan_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_plan_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `plan_id` bigint DEFAULT NULL,
  `date` date DEFAULT NULL,
  `line_id` varchar(255) DEFAULT NULL,
  `line_name` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `product_kind` varchar(255) DEFAULT NULL,
  `qty_unit` varchar(255) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_plan_lines_on_plan_id` (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_plan_lines`
--

LOCK TABLES `mfg_plan_lines` WRITE;
/*!40000 ALTER TABLE `mfg_plan_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_plan_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_plans`
--

DROP TABLE IF EXISTS `mfg_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_plans` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `plan_title` varchar(255) DEFAULT NULL,
  `week_start_date` date DEFAULT NULL,
  `week_end_date` date DEFAULT NULL,
  `workshop_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_plans`
--

LOCK TABLES `mfg_plans` WRITE;
/*!40000 ALTER TABLE `mfg_plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_scrap_orders`
--

DROP TABLE IF EXISTS `mfg_scrap_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_scrap_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `scrap_category` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `lot_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `planned_qty` decimal(12,2) DEFAULT '0.00',
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `status` varchar(255) DEFAULT 'draft',
  `inventory_synced` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_mfg_scrap_orders_on_item_id` (`item_id`),
  KEY `index_mfg_scrap_orders_on_location_id` (`location_id`),
  KEY `index_mfg_scrap_orders_on_lot_id` (`lot_id`),
  KEY `index_mfg_scrap_orders_on_product_id` (`product_id`),
  KEY `index_mfg_scrap_orders_on_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_scrap_orders`
--

LOCK TABLES `mfg_scrap_orders` WRITE;
/*!40000 ALTER TABLE `mfg_scrap_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_scrap_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_work_order_byproducts`
--

DROP TABLE IF EXISTS `mfg_work_order_byproducts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_work_order_byproducts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `work_order_id` int DEFAULT NULL,
  `bom_byproduct_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `plan_qty` decimal(12,2) DEFAULT '0.00',
  `actual_qty` decimal(12,2) DEFAULT '0.00',
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_work_order_byproducts_on_bom_byproduct_id` (`bom_byproduct_id`),
  KEY `index_mfg_work_order_byproducts_on_product_id` (`product_id`),
  KEY `index_mfg_work_order_byproducts_on_work_order_id` (`work_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_work_order_byproducts`
--

LOCK TABLES `mfg_work_order_byproducts` WRITE;
/*!40000 ALTER TABLE `mfg_work_order_byproducts` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_work_order_byproducts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_work_order_losses`
--

DROP TABLE IF EXISTS `mfg_work_order_losses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_work_order_losses` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `work_order_id` int DEFAULT NULL,
  `bom_loss_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `plan_loss_qty` decimal(12,2) DEFAULT '0.00',
  `actual_loss_qty` decimal(12,2) DEFAULT '0.00',
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mfg_work_order_losses_on_bom_loss_id` (`bom_loss_id`),
  KEY `index_mfg_work_order_losses_on_product_id` (`product_id`),
  KEY `index_mfg_work_order_losses_on_work_order_id` (`work_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_work_order_losses`
--

LOCK TABLES `mfg_work_order_losses` WRITE;
/*!40000 ALTER TABLE `mfg_work_order_losses` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_work_order_losses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfg_work_orders`
--

DROP TABLE IF EXISTS `mfg_work_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfg_work_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `bom_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `plan_qty` decimal(12,2) DEFAULT '0.00',
  `actual_qty` decimal(12,2) DEFAULT '0.00',
  `status` varchar(255) DEFAULT NULL,
  `plan_start` datetime(6) DEFAULT NULL,
  `plan_finish` datetime(6) DEFAULT NULL,
  `actual_start` datetime(6) DEFAULT NULL,
  `actual_finish` datetime(6) DEFAULT NULL,
  `warehouse_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `inventory_synced` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_mfg_work_orders_on_bom_id` (`bom_id`),
  KEY `index_mfg_work_orders_on_company_id` (`company_id`),
  KEY `index_mfg_work_orders_on_product_id` (`product_id`),
  KEY `index_mfg_work_orders_on_warehouse_id` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfg_work_orders`
--

LOCK TABLES `mfg_work_orders` WRITE;
/*!40000 ALTER TABLE `mfg_work_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfg_work_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nodes`
--

DROP TABLE IF EXISTS `nodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nodes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `root_id` int DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `decrypt_file` varchar(255) DEFAULT NULL,
  `info` text,
  `remark` varchar(255) DEFAULT NULL,
  `creater_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `sort` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_nodes_on_ancestry` (`ancestry`),
  KEY `index_nodes_on_company_id` (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nodes`
--

LOCK TABLES `nodes` WRITE;
/*!40000 ALTER TABLE `nodes` DISABLE KEYS */;
INSERT INTO `nodes` VALUES (1,'NODES-260324-0001','Crm::PreOrder','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-24 14:03:00.109390','2026-03-24 14:03:00.109390',NULL,NULL,NULL),(2,'NODES-260324-0002','Crm::Order','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-24 14:06:31.012159','2026-03-24 14:06:31.012159',NULL,NULL,NULL),(3,'NODES-260324-0003','Crm::Order_clone','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-24 14:36:40.501400','2026-03-24 14:36:40.501400',NULL,NULL,NULL),(4,'NODES-260324-0004','Crm::Order','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-24 14:47:22.053814','2026-03-24 14:47:22.053814',NULL,NULL,NULL),(5,'NODES-260324-0005','Crm::Order','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-24 16:22:25.207452','2026-03-24 16:22:25.207452',NULL,NULL,NULL),(6,'NODES-260324-0006','Crm::Order_clone','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-24 17:08:15.669113','2026-03-24 17:08:15.669113',NULL,NULL,NULL),(7,'NODES-260324-0007','Crm::OrderNew','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-24 17:22:40.937956','2026-03-24 17:22:40.937956',NULL,NULL,NULL),(8,'NODES-260324-0008','Crm::OrderDetail','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-24 17:59:52.274702','2026-03-24 17:59:52.274702',NULL,NULL,NULL),(9,'NODES-260324-0009','Crm::PreOrder','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-24 19:07:48.596556','2026-03-24 19:07:48.596556',NULL,NULL,NULL),(10,'NODES-260325-0001','Crm::Order_clone','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-25 12:19:04.515153','2026-03-25 12:19:04.515153',NULL,NULL,NULL),(11,'NODES-260325-0002','Crm::PreOrder_clone','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-25 12:21:08.950035','2026-03-25 12:21:08.950035',NULL,NULL,NULL),(12,'NODES-260330-0001','Crm::Order','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-30 14:42:49.106027','2026-03-30 14:42:49.106027',NULL,NULL,NULL),(13,'NODES-260330-0002','Crm::OrderDetail','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-30 14:43:48.412094','2026-03-30 14:43:48.412094',NULL,NULL,NULL),(14,'NODES-260330-0003','Crm::Order_clone','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-30 14:51:23.713034','2026-03-30 14:51:23.713034',NULL,NULL,NULL),(15,'NODES-260330-0004','Crm::OrderLine','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-30 15:11:02.731889','2026-03-30 15:11:02.731889',NULL,NULL,NULL),(16,'NODES-260330-0005','Crm::OrderDetail_clone','Folder',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2026-03-30 15:16:08.912502','2026-03-30 15:16:08.912502',NULL,NULL,NULL);
/*!40000 ALTER TABLE `nodes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `category` int DEFAULT NULL,
  `act` varchar(255) DEFAULT NULL,
  `ctrl` varchar(255) DEFAULT NULL,
  `sign` varchar(255) DEFAULT NULL,
  `core` tinyint(1) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pm_documents`
--

DROP TABLE IF EXISTS `pm_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pm_documents` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` int DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `kind` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `content` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pm_documents_on_ancestry` (`ancestry`),
  KEY `index_pm_documents_on_project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pm_documents`
--

LOCK TABLES `pm_documents` WRITE;
/*!40000 ALTER TABLE `pm_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `pm_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pm_files`
--

DROP TABLE IF EXISTS `pm_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pm_files` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` int DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `file_size` int DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `file_count` int DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT NULL,
  `kind` int DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pm_files_on_ancestry` (`ancestry`),
  KEY `index_pm_files_on_project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pm_files`
--

LOCK TABLES `pm_files` WRITE;
/*!40000 ALTER TABLE `pm_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `pm_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pm_members`
--

DROP TABLE IF EXISTS `pm_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pm_members` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `record_id` int DEFAULT NULL,
  `record_type` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `role_id` int DEFAULT NULL,
  `joined_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pm_members_on_record_type_and_record_id` (`record_type`,`record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pm_members`
--

LOCK TABLES `pm_members` WRITE;
/*!40000 ALTER TABLE `pm_members` DISABLE KEYS */;
/*!40000 ALTER TABLE `pm_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pm_portfolios`
--

DROP TABLE IF EXISTS `pm_portfolios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pm_portfolios` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `status_id` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_star` tinyint(1) DEFAULT NULL,
  `manager_id` int DEFAULT NULL,
  `description` text,
  `degree` json DEFAULT NULL,
  `labels` json DEFAULT NULL,
  `custom_fields` json DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pm_portfolios_on_company_id` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pm_portfolios`
--

LOCK TABLES `pm_portfolios` WRITE;
/*!40000 ALTER TABLE `pm_portfolios` DISABLE KEYS */;
/*!40000 ALTER TABLE `pm_portfolios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pm_projects`
--

DROP TABLE IF EXISTS `pm_projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pm_projects` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `portfolio_id` int DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `pinyin` varchar(255) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `status_id` int DEFAULT NULL,
  `source_id` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_star` tinyint(1) DEFAULT NULL,
  `manager_id` int DEFAULT NULL,
  `description` text,
  `degree` json DEFAULT NULL,
  `labels` json DEFAULT NULL,
  `custom_fields` json DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT NULL,
  `is_suspended` tinyint(1) DEFAULT NULL,
  `suspend_at` datetime(6) DEFAULT NULL,
  `suspender_id` int DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pm_projects_on_ancestry` (`ancestry`),
  KEY `index_pm_projects_on_company_id` (`company_id`),
  KEY `index_pm_projects_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pm_projects`
--

LOCK TABLES `pm_projects` WRITE;
/*!40000 ALTER TABLE `pm_projects` DISABLE KEYS */;
/*!40000 ALTER TABLE `pm_projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pm_stages`
--

DROP TABLE IF EXISTS `pm_stages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pm_stages` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `task_count` int DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pm_stages_on_project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pm_stages`
--

LOCK TABLES `pm_stages` WRITE;
/*!40000 ALTER TABLE `pm_stages` DISABLE KEYS */;
/*!40000 ALTER TABLE `pm_stages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pm_tasks`
--

DROP TABLE IF EXISTS `pm_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pm_tasks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` int DEFAULT NULL,
  `stage_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `status_id` int DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `priority_id` int DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `labels` json DEFAULT NULL,
  `custom_fields` json DEFAULT NULL,
  `due_at` datetime(6) DEFAULT NULL,
  `done_at` datetime(6) DEFAULT NULL,
  `is_star` tinyint(1) DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT NULL,
  `is_done` tinyint(1) DEFAULT NULL,
  `executor_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `description` text,
  `plan_time` decimal(12,2) DEFAULT '0.00',
  `real_time` decimal(12,2) DEFAULT '0.00',
  `progress` int DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `start_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pm_tasks_on_ancestry` (`ancestry`),
  KEY `index_pm_tasks_on_parent_id` (`parent_id`),
  KEY `index_pm_tasks_on_project_id` (`project_id`),
  KEY `index_pm_tasks_on_stage_id` (`stage_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pm_tasks`
--

LOCK TABLES `pm_tasks` WRITE;
/*!40000 ALTER TABLE `pm_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `pm_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pm_templates`
--

DROP TABLE IF EXISTS `pm_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pm_templates` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `logo` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pm_templates`
--

LOCK TABLES `pm_templates` WRITE;
/*!40000 ALTER TABLE `pm_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `pm_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pm_timesheets`
--

DROP TABLE IF EXISTS `pm_timesheets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pm_timesheets` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `kind` int DEFAULT NULL,
  `project_id` int DEFAULT NULL,
  `date` date DEFAULT NULL,
  `task_id` int DEFAULT NULL,
  `time` decimal(12,2) DEFAULT '0.00',
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pm_timesheets_on_project_id` (`project_id`),
  KEY `index_pm_timesheets_on_task_id` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pm_timesheets`
--

LOCK TABLES `pm_timesheets` WRITE;
/*!40000 ALTER TABLE `pm_timesheets` DISABLE KEYS */;
/*!40000 ALTER TABLE `pm_timesheets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `properties`
--

DROP TABLE IF EXISTS `properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `properties` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sign` varchar(255) DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `is_open` tinyint(1) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `abbr` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_properties_on_sign` (`sign`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `properties`
--

LOCK TABLES `properties` WRITE;
/*!40000 ALTER TABLE `properties` DISABLE KEYS */;
INSERT INTO `properties` VALUES (1,'product_type',NULL,'子母系列','zmxl',1,'primary',NULL,NULL,'2026-03-23 23:30:52.007588','2026-03-23 23:30:52.007588',''),(2,'product_type',NULL,'聚酯PET','jzPET',2,'primary',NULL,NULL,'2026-03-23 23:30:56.523676','2026-03-23 23:30:56.523676',''),(3,'product_type',NULL,'聚乙烯PE、多层高阻隔','jyxPE  dcgzg',3,'primary',NULL,NULL,'2026-03-23 23:31:01.465562','2026-03-23 23:31:01.465562',''),(4,'product_type',NULL,'堆码桶','dmt',4,'primary',NULL,NULL,'2026-03-23 23:31:08.589865','2026-03-23 23:31:08.589865',''),(5,'product_category',NULL,'瓶子','pz',1,'primary',NULL,NULL,'2026-03-23 23:31:52.882911','2026-03-23 23:31:52.882911',''),(6,'product_category',NULL,'盖子','gz',2,'primary',NULL,NULL,'2026-03-23 23:31:57.713177','2026-03-23 23:31:57.713177',''),(7,'product_category',NULL,'子母系列','zmxl',NULL,NULL,NULL,NULL,'2026-03-23 23:42:58.689122','2026-03-23 23:42:58.689122',NULL),(8,'product_category',NULL,'聚酯PET','jzPET',NULL,NULL,NULL,NULL,'2026-03-23 23:42:59.070354','2026-03-23 23:42:59.070354',NULL),(9,'product_category',NULL,'聚乙烯PE、多层高阻隔','jyxPE  dcgzg',NULL,NULL,NULL,NULL,'2026-03-23 23:43:00.034454','2026-03-23 23:43:00.034454',NULL),(10,'product_category',NULL,'堆码桶','dmt',NULL,NULL,NULL,NULL,'2026-03-23 23:43:04.489328','2026-03-23 23:43:04.489328',NULL),(11,'product_category',6,'未标注','wbz',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.582428','2026-03-24 08:48:28.582428',NULL),(12,'product_category',7,'100ml','100ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.630842','2026-03-24 08:48:28.630842',NULL),(13,'product_category',7,'950ml','950ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.673357','2026-03-24 08:48:28.673357',NULL),(14,'product_category',9,'200ml','200ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.704426','2026-03-24 08:48:28.704426',NULL),(15,'product_category',7,'500ml','500ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.716141','2026-03-24 08:48:28.716141',NULL),(16,'product_category',8,'1000ml','1000ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.745510','2026-03-24 08:48:28.745510',NULL),(17,'product_category',8,'100ml','100ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.798350','2026-03-24 08:48:28.798350',NULL),(18,'product_category',8,'250ml','250ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.822830','2026-03-24 08:48:28.822830',NULL),(19,'product_category',8,'400ml','400ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.849114','2026-03-24 08:48:28.849114',NULL),(20,'product_category',8,'500ml','500ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.887185','2026-03-24 08:48:28.887185',NULL),(21,'product_category',8,'800ml','800ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.902143','2026-03-24 08:48:28.902143',NULL),(22,'product_category',9,'1000ml','1000ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:28.913308','2026-03-24 08:48:28.913308',NULL),(23,'product_category',9,'100ml','100ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.040146','2026-03-24 08:48:29.040146',NULL),(24,'product_category',9,'150ml','150ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.077334','2026-03-24 08:48:29.077334',NULL),(25,'product_category',9,'10L','10L',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.092629','2026-03-24 08:48:29.092629',NULL),(26,'product_category',9,'250ml','250ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.156678','2026-03-24 08:48:29.156678',NULL),(27,'product_category',9,'2L','2L',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.233190','2026-03-24 08:48:29.233190',NULL),(28,'product_category',9,'3L','3L',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.258735','2026-03-24 08:48:29.258735',NULL),(29,'product_category',9,'3.5L','3 5L',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.284855','2026-03-24 08:48:29.284855',NULL),(30,'product_category',9,'400ml','400ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.301467','2026-03-24 08:48:29.301467',NULL),(31,'product_category',9,'4L','4L',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.307653','2026-03-24 08:48:29.307653',NULL),(32,'product_category',9,'500ml','500ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.335703','2026-03-24 08:48:29.335703',NULL),(33,'product_category',9,'50ml','50ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.413250','2026-03-24 08:48:29.413250',NULL),(34,'product_category',9,'5L','5L',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.461243','2026-03-24 08:48:29.461243',NULL),(35,'product_category',9,'750ml','750ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.552225','2026-03-24 08:48:29.552225',NULL),(36,'product_category',9,'800ml','800ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.560151','2026-03-24 08:48:29.560151',NULL),(37,'product_category',9,'900ml','900ml',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.573015','2026-03-24 08:48:29.573015',NULL),(38,'product_category',10,'20L','20L',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.584740','2026-03-24 08:48:29.584740',NULL),(39,'product_category',10,'25L','25L',NULL,NULL,NULL,NULL,'2026-03-24 08:48:29.656536','2026-03-24 08:48:29.656536',NULL),(40,'crm_settlement',NULL,'月付','yf',1,'primary',NULL,NULL,'2026-03-24 14:00:41.380812','2026-03-24 14:00:41.380812',''),(41,'crm_settlement',NULL,'年付','nf',2,'primary',NULL,NULL,'2026-03-24 14:00:49.057907','2026-03-24 14:00:49.057907',''),(42,'crm_settlement',NULL,'战略合作协议','zlhzxy',3,'primary',NULL,NULL,'2026-03-24 14:01:00.509951','2026-03-24 14:01:00.509951',''),(43,'crm_invoice_type',NULL,'增值税专用发票','zzszyfp',1,'primary',NULL,NULL,'2026-03-24 14:01:16.783474','2026-03-24 14:01:16.783474',''),(44,'crm_order_status',NULL,'待处理','dcl',1,'primary',NULL,NULL,'2026-03-24 15:44:36.500530','2026-03-24 15:44:36.500530',''),(45,'crm_order_status',NULL,'已转订单','yzdd',2,'success',NULL,NULL,'2026-03-24 15:44:49.062152','2026-03-24 15:44:49.062152',''),(46,'crm_order_status',NULL,'生产中','scz',3,'success',NULL,NULL,'2026-03-24 15:45:03.587792','2026-03-24 15:45:03.587792',''),(47,'crm_order_status',NULL,'已发货','yfh',4,'warning',NULL,NULL,'2026-03-24 15:45:10.838854','2026-03-24 15:45:10.838854',''),(48,'crm_order_status',NULL,'已付款','yfk',5,'info',NULL,NULL,'2026-03-24 15:45:19.620816','2026-03-24 15:45:19.620816','');
/*!40000 ALTER TABLE `properties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provinces`
--

DROP TABLE IF EXISTS `provinces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `provinces` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `py` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_provinces_on_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provinces`
--

LOCK TABLES `provinces` WRITE;
/*!40000 ALTER TABLE `provinces` DISABLE KEYS */;
/*!40000 ALTER TABLE `provinces` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pur_collections`
--

DROP TABLE IF EXISTS `pur_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pur_collections` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `purchase_contract_id` bigint DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `length` decimal(12,2) DEFAULT '0.00',
  `width` decimal(12,2) DEFAULT '0.00',
  `height` decimal(12,2) DEFAULT '0.00',
  `unit` varchar(255) DEFAULT NULL,
  `qty` decimal(12,2) DEFAULT '0.00',
  `price` decimal(12,2) DEFAULT '0.00',
  `amount_excl_tax` decimal(12,2) DEFAULT '0.00',
  `tax` decimal(12,2) DEFAULT '0.00',
  `amount` decimal(12,2) DEFAULT '0.00',
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `other` varchar(255) DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pur_collections_on_purchase_contract_id` (`purchase_contract_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pur_collections`
--

LOCK TABLES `pur_collections` WRITE;
/*!40000 ALTER TABLE `pur_collections` DISABLE KEYS */;
/*!40000 ALTER TABLE `pur_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pur_contacts`
--

DROP TABLE IF EXISTS `pur_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pur_contacts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `supplier_id` bigint DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `dept` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `mobile` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `is_primary` tinyint(1) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pur_contacts_on_supplier_id` (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pur_contacts`
--

LOCK TABLES `pur_contacts` WRITE;
/*!40000 ALTER TABLE `pur_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `pur_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pur_contract_workflow_logs`
--

DROP TABLE IF EXISTS `pur_contract_workflow_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pur_contract_workflow_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `pur_contract_id` bigint NOT NULL COMMENT '关联采购合同',
  `step_key` varchar(255) NOT NULL COMMENT '节点标识',
  `step_label` varchar(255) DEFAULT NULL COMMENT '节点名称',
  `operated_at` datetime(6) NOT NULL COMMENT '操作时间',
  `operator_id` int DEFAULT NULL COMMENT '操作人 ID',
  `operator_name` varchar(255) DEFAULT NULL COMMENT '操作人姓名',
  `action` text COMMENT '操作/备注内容',
  `result` varchar(255) DEFAULT NULL COMMENT '节点结果',
  `result_extra` json DEFAULT NULL COMMENT '扩展结果',
  `sort` int DEFAULT '0',
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pur_contract_workflow_logs_on_operated_at` (`operated_at`),
  KEY `index_pur_contract_workflow_logs_on_pur_contract_id` (`pur_contract_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pur_contract_workflow_logs`
--

LOCK TABLES `pur_contract_workflow_logs` WRITE;
/*!40000 ALTER TABLE `pur_contract_workflow_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `pur_contract_workflow_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pur_contract_workflow_states`
--

DROP TABLE IF EXISTS `pur_contract_workflow_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pur_contract_workflow_states` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `pur_contract_id` bigint NOT NULL COMMENT '关联采购合同',
  `step_key` varchar(255) NOT NULL COMMENT '节点标识',
  `status` varchar(255) NOT NULL DEFAULT 'pending' COMMENT 'pending/current/completed/failed',
  `completed_at` datetime(6) DEFAULT NULL COMMENT '完成时间',
  `result` varchar(255) DEFAULT NULL COMMENT '该节点最终结果',
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_pur_wf_states_contract_step` (`pur_contract_id`,`step_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pur_contract_workflow_states`
--

LOCK TABLES `pur_contract_workflow_states` WRITE;
/*!40000 ALTER TABLE `pur_contract_workflow_states` DISABLE KEYS */;
/*!40000 ALTER TABLE `pur_contract_workflow_states` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pur_contracts`
--

DROP TABLE IF EXISTS `pur_contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pur_contracts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `contract_title` varchar(255) DEFAULT NULL,
  `supplier_id` int DEFAULT NULL,
  `supplier_name` varchar(255) DEFAULT NULL,
  `client_id` int DEFAULT NULL,
  `sign` varchar(255) DEFAULT NULL,
  `client_name` varchar(255) DEFAULT NULL,
  `kind_id` int DEFAULT NULL,
  `status_id` int DEFAULT NULL,
  `contract_number` varchar(255) DEFAULT NULL,
  `signing_location` varchar(255) DEFAULT NULL,
  `signing_date` date DEFAULT NULL,
  `receive_date` date DEFAULT NULL,
  `total_amount` decimal(12,2) DEFAULT '0.00',
  `total_amount_chinese` varchar(255) DEFAULT NULL,
  `related_item` varchar(255) DEFAULT NULL,
  `quality_standard` text,
  `delivery_location_method` text,
  `transportation_cost_bearer` varchar(255) DEFAULT NULL,
  `loss_calculation_method` varchar(255) DEFAULT NULL,
  `packaging_standard` text,
  `packaging_loss_responsibility` varchar(255) DEFAULT NULL,
  `inspection_method` text,
  `reinspection_period` varchar(255) DEFAULT NULL,
  `objection_period` varchar(255) DEFAULT NULL,
  `quality_issue_responsibility` varchar(255) DEFAULT NULL,
  `spare_parts_supply` varchar(255) DEFAULT NULL,
  `settlement_method_term` text,
  `breach_of_contract_liability` varchar(255) DEFAULT NULL,
  `dispute_resolution_method` varchar(255) DEFAULT NULL,
  `other_agreements` text,
  `remark` text,
  `other` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `validity_start_date` date DEFAULT NULL,
  `validity_end_date` date DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT '合同编号',
  `fm_contract_id` int DEFAULT NULL COMMENT '关联订购合同(fm_contracts)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pur_contracts`
--

LOCK TABLES `pur_contracts` WRITE;
/*!40000 ALTER TABLE `pur_contracts` DISABLE KEYS */;
/*!40000 ALTER TABLE `pur_contracts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pur_suppliers`
--

DROP TABLE IF EXISTS `pur_suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pur_suppliers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `abbr` varchar(255) DEFAULT NULL,
  `qual_notes` varchar(255) DEFAULT NULL,
  `remark` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pur_suppliers`
--

LOCK TABLES `pur_suppliers` WRITE;
/*!40000 ALTER TABLE `pur_suppliers` DISABLE KEYS */;
/*!40000 ALTER TABLE `pur_suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rms_handover_contracts`
--

DROP TABLE IF EXISTS `rms_handover_contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rms_handover_contracts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `recipe_handover_id` bigint DEFAULT NULL,
  `contract_id` bigint DEFAULT NULL,
  `qty` decimal(12,2) DEFAULT '0.00',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `pur_contract_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rms_handover_contracts_on_contract_id` (`contract_id`),
  KEY `index_rms_handover_contracts_on_recipe_handover_id` (`recipe_handover_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rms_handover_contracts`
--

LOCK TABLES `rms_handover_contracts` WRITE;
/*!40000 ALTER TABLE `rms_handover_contracts` DISABLE KEYS */;
/*!40000 ALTER TABLE `rms_handover_contracts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rms_handover_lines`
--

DROP TABLE IF EXISTS `rms_handover_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rms_handover_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `handover_id` bigint DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `feeding_rate` decimal(12,2) DEFAULT '0.00',
  `remark` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rms_handover_lines_on_handover_id` (`handover_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rms_handover_lines`
--

LOCK TABLES `rms_handover_lines` WRITE;
/*!40000 ALTER TABLE `rms_handover_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `rms_handover_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rms_handovers`
--

DROP TABLE IF EXISTS `rms_handovers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rms_handovers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `handover_date` date DEFAULT NULL,
  `ordering_companies_text` text,
  `order_qty` decimal(12,2) DEFAULT '0.00',
  `order_qty_unit` varchar(255) DEFAULT NULL,
  `handover_order_id` bigint DEFAULT NULL,
  `prepared_id` int DEFAULT NULL,
  `received_id` int DEFAULT NULL,
  `general_notes` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rms_handovers_on_handover_order_id` (`handover_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rms_handovers`
--

LOCK TABLES `rms_handovers` WRITE;
/*!40000 ALTER TABLE `rms_handovers` DISABLE KEYS */;
/*!40000 ALTER TABLE `rms_handovers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `category` int DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `describe` varchar(255) DEFAULT NULL,
  `company_ids` text,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `sign` varchar(255) DEFAULT NULL,
  `is_open` tinyint(1) DEFAULT '1',
  `menu_ids` text,
  `company_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20250509143804'),('20250511071023'),('20250511082500'),('20250511101813'),('20250511103948'),('20250511110539'),('20250511111227'),('20250511115515'),('20250511121012'),('20250511144551'),('20250512111332'),('20250512131611'),('20250513071016'),('20250517052056'),('20250517070326'),('20250521150824'),('20250523145656'),('20250524042740'),('20250525143726'),('20250528031419'),('20250604142102'),('20251101124222'),('20251102132340'),('20251203021309'),('20251203071054'),('20251210022015'),('20251212082155'),('20251212083641'),('20251214081818'),('20251214091623'),('20251217130203'),('20251223025026'),('20260110162209'),('20260111125209'),('20260111132133'),('20260112030419'),('20260114104500'),('20260114145107'),('20260115062452'),('20260115112121'),('20260115152650'),('20260115155819'),('20260116020716'),('20260116020949'),('20260118105305'),('20260118124255'),('20260118132211'),('20260118145343'),('20260118233222'),('20260118233226'),('20260119055339'),('20260120150300'),('20260120150301'),('20260120150303'),('20260120150305'),('20260120150306'),('20260120150308'),('20260120150310'),('20260121052759'),('20260121070658'),('20260125163021'),('20260126215736'),('20260126220621'),('20260126220622'),('20260126220623'),('20260126220624'),('20260126220625'),('20260126220626'),('20260126220627'),('20260126220628'),('20260126221747'),('20260126221748'),('20260126221749'),('20260126225527'),('20260126225528'),('20260126225926'),('20260126225927'),('20260126230001'),('20260126230002'),('20260126230003'),('20260126230004'),('20260126230005'),('20260126230006'),('20260126230007'),('20260126230008'),('20260126230009'),('20260126230010'),('20260126230011'),('20260127000001'),('20260127000002'),('20260127000003'),('20260128081417'),('20260128092915'),('20260128120000'),('20260128120001'),('20260224155047'),('20260224155100'),('20260224155108'),('20260224155308'),('20260224155327'),('20260224155346'),('20260224155429'),('20260224155445'),('20260224160543'),('20260224161135'),('20260225081108'),('20260225081757'),('20260225082412'),('20260225082425'),('20260225082545'),('20260225082940'),('20260225083006'),('20260225092131'),('20260225092155'),('20260225111011'),('20260225134406'),('20260225144017'),('20260225144117'),('20260225144141'),('20260225144156'),('20260225144225'),('20260225150955'),('20260225150957'),('20260225151000'),('20260225151003'),('20260226032825'),('20260226032827'),('20260226032830'),('20260226032833'),('20260226032835'),('20260226032838'),('20260226032840'),('20260226032843'),('20260226032846'),('20260226034144'),('20260226083824'),('20260228022825'),('20260228022826'),('20260228022827'),('20260312135952'),('20260313032412'),('20260313070208'),('20260313072654'),('20260313142728'),('20260313154616'),('20260313154648'),('20260314025816'),('20260314030000'),('20260314045828'),('20260314051158'),('20260316075408'),('20260316094347'),('20260316155525'),('20260316155611'),('20260316155612'),('20260316160125'),('20260317073654'),('20260323093000'),('20260323120001'),('20260323151000'),('20260323151010'),('20260323151020'),('20260324120000'),('20260324180000'),('20260325100000'),('20260330103456'),('20260330130000');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `var` varchar(255) NOT NULL,
  `value` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_settings_on_var` (`var`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'app_name','--- 南通高强\n','2026-03-23 23:21:20.679717','2026-03-30 18:19:21.988928'),(2,'title_name','--- 南通高强包装\n','2026-03-23 23:21:20.868867','2026-03-23 23:21:20.868867'),(3,'open_captcha','--- true\n','2026-03-23 23:21:20.882449','2026-03-23 23:21:20.882449'),(4,'author_name','--- Cheenwe\n','2026-03-23 23:21:20.893633','2026-03-23 23:21:20.893633'),(5,'author_url','--- https://github.com/cheenwe\n','2026-03-23 23:21:20.906041','2026-03-23 23:21:20.906041'),(6,'logo','--- \"/uploads/attachment/2026/2/logo2.png\"\n','2026-03-23 23:21:20.912379','2026-03-23 23:23:00.188555'),(7,'favicon','--- https://v3.ice.work/img/favicon.ico\n','2026-03-23 23:21:20.960414','2026-03-23 23:21:20.960414'),(8,'icp','--- 沪ICP备6423XX号\n','2026-03-23 23:21:20.996296','2026-03-23 23:21:20.996296'),(9,'police_code','--- 沪公网安备XXX\n','2026-03-23 23:21:21.002280','2026-03-23 23:21:21.002280'),(10,'version_code','--- V1.0.0\n','2026-03-23 23:21:21.011167','2026-03-23 23:21:21.011167'),(11,'host','--- http://example.com\n','2026-03-23 23:21:21.022103','2026-03-23 23:21:21.022103'),(12,'slogan','--- 专注生产乙烯瓶/桶、多层高阻隔瓶/桶、聚脂PET、堆码桶、子母瓶\n','2026-03-23 23:22:18.001753','2026-03-23 23:22:18.001753');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms_codes`
--

DROP TABLE IF EXISTS `sms_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sms_codes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sms_codes_on_user_id_and_created_at` (`user_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms_codes`
--

LOCK TABLES `sms_codes` WRITE;
/*!40000 ALTER TABLE `sms_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `sms_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test2s`
--

DROP TABLE IF EXISTS `test2s`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test2s` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test2s`
--

LOCK TABLES `test2s` WRITE;
/*!40000 ALTER TABLE `test2s` DISABLE KEYS */;
/*!40000 ALTER TABLE `test2s` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tests`
--

DROP TABLE IF EXISTS `tests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tests` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tests`
--

LOCK TABLES `tests` WRITE;
/*!40000 ALTER TABLE `tests` DISABLE KEYS */;
/*!40000 ALTER TABLE `tests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tms_order_lines`
--

DROP TABLE IF EXISTS `tms_order_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tms_order_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shipping_order_id` bigint DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `packaging_spec` varchar(255) DEFAULT NULL,
  `pieces_capitalized` varchar(255) DEFAULT NULL,
  `pieces` int DEFAULT NULL,
  `net_weight_display` varchar(255) DEFAULT NULL,
  `net_weight_ton` decimal(12,2) DEFAULT '0.00',
  `unit_price` decimal(12,2) DEFAULT '0.00',
  `amount` decimal(12,2) DEFAULT '0.00',
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tms_order_lines_on_shipping_order_id` (`shipping_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tms_order_lines`
--

LOCK TABLES `tms_order_lines` WRITE;
/*!40000 ALTER TABLE `tms_order_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `tms_order_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tms_orders`
--

DROP TABLE IF EXISTS `tms_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tms_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `document_number` varchar(255) DEFAULT NULL,
  `document_date` date DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `reference_code` varchar(255) DEFAULT NULL,
  `consignee_name` varchar(255) DEFAULT NULL,
  `consignee_contact` varchar(255) DEFAULT NULL,
  `consignee_phone` varchar(255) DEFAULT NULL,
  `delivery_address` text,
  `carrier_id_no` varchar(255) DEFAULT NULL,
  `vehicle_no` varchar(255) DEFAULT NULL,
  `carrier_name` varchar(255) DEFAULT NULL,
  `consignee_stamp_note` varchar(255) DEFAULT NULL,
  `consignee_signature_note` varchar(255) DEFAULT NULL,
  `approved_id` int DEFAULT NULL,
  `prepared_id` int DEFAULT NULL,
  `contract_note` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tms_orders`
--

LOCK TABLES `tms_orders` WRITE;
/*!40000 ALTER TABLE `tms_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `tms_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tms_plans`
--

DROP TABLE IF EXISTS `tms_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tms_plans` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `required_warehouse_entry_date` varchar(255) DEFAULT NULL,
  `client_id` int DEFAULT NULL,
  `client_name` varchar(255) DEFAULT NULL,
  `contract_code` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `qty` decimal(12,2) DEFAULT '0.00',
  `specification` varchar(255) DEFAULT NULL,
  `outer_box_dimensions` varchar(255) DEFAULT NULL,
  `merchandiser_id` varchar(255) DEFAULT NULL,
  `pieces` varchar(255) DEFAULT NULL,
  `warehouse_address` text,
  `is_ready` varchar(255) DEFAULT NULL,
  `kind_id` int DEFAULT NULL,
  `remark` text,
  `warehouse_entry_note` varchar(255) DEFAULT NULL,
  `volume_inspection` decimal(12,2) DEFAULT '0.00',
  `gross_weight_inspection` decimal(12,2) DEFAULT '0.00',
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `status` int DEFAULT NULL,
  `ship_date` date DEFAULT NULL,
  `shiper_id` int DEFAULT NULL,
  `vehicle_usage` varchar(255) DEFAULT NULL,
  `direct_info` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tms_plans`
--

LOCK TABLES `tms_plans` WRITE;
/*!40000 ALTER TABLE `tms_plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `tms_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime(6) DEFAULT NULL,
  `remember_created_at` datetime(6) DEFAULT NULL,
  `sign_in_count` int NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime(6) DEFAULT NULL,
  `last_sign_in_at` datetime(6) DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `confirmation_token` varchar(255) DEFAULT NULL,
  `confirmed_at` datetime(6) DEFAULT NULL,
  `confirmation_sent_at` datetime(6) DEFAULT NULL,
  `unconfirmed_email` varchar(255) DEFAULT NULL,
  `failed_attempts` int NOT NULL DEFAULT '0',
  `unlock_token` varchar(255) DEFAULT NULL,
  `locked_at` datetime(6) DEFAULT NULL,
  `nickname` varchar(255) NOT NULL DEFAULT '' COMMENT '昵称',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '姓名',
  `phone` varchar(255) NOT NULL DEFAULT '' COMMENT '电话',
  `approved` tinyint(1) NOT NULL DEFAULT '0' COMMENT '允许使用',
  `uuid` varchar(255) NOT NULL DEFAULT '' COMMENT 'UUID',
  `code` varchar(255) NOT NULL DEFAULT '' COMMENT '编号',
  `sex` varchar(255) NOT NULL DEFAULT '' COMMENT '性别',
  `marriage` varchar(255) NOT NULL DEFAULT '' COMMENT '婚姻, Y：已婚  N：未婚  O：其他  L：离异  S：丧偶  B：保密',
  `cardnum` varchar(255) NOT NULL DEFAULT '' COMMENT '身份证号',
  `brondate` date DEFAULT NULL COMMENT '出生日期',
  `department_id` int DEFAULT NULL COMMENT '部门',
  `post_id` int DEFAULT NULL COMMENT '岗位',
  `hire_date` date DEFAULT NULL COMMENT '入职日期',
  `fire_date` date DEFAULT NULL COMMENT '离职日期',
  `director_id` int DEFAULT NULL COMMENT '直接主管',
  `role_id` int NOT NULL DEFAULT '0' COMMENT '角色',
  `status` int NOT NULL DEFAULT '0' COMMENT '同步标识',
  `avatar` varchar(255) NOT NULL DEFAULT '' COMMENT '头像',
  `remark` text COMMENT '备注',
  `whitelists` text COMMENT 'IP白名单',
  `change_passowrd` tinyint(1) DEFAULT '0' COMMENT '是否强制修改密码',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `company_id` int DEFAULT NULL,
  `current_company_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_name` (`name`),
  UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  KEY `index_users_on_company_id` (`company_id`),
  KEY `index_users_on_department_id` (`department_id`),
  KEY `index_users_on_role_id` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin1@qq.com','$2a$12$x0I1vi.WgoiCT.5mMo18u.ko5v9xMl45betaccDPHNSViXnDWdkk2',NULL,NULL,NULL,10,'2026-04-06 16:26:07.217943','2026-04-06 15:43:06.030497','127.0.0.1','127.0.0.1',NULL,NULL,NULL,NULL,0,NULL,NULL,'管理员','user1','18516053751',1,'89c0a65e174c461e84179ded227915f0','ac01','','','152112199012093451',NULL,NULL,NULL,NULL,NULL,NULL,1,0,'刘飞.png',NULL,'0.0.0.0',0,'2026-03-23 23:15:46.910759','2026-04-06 16:26:07.217945',NULL,NULL),(2,'admin2@qq.com','$2a$12$Hm7Ht.lxEZ8R/JezAMEu8.67BBtmrvRPaHts.FkI0ufMchmob8GtK',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'管理员','user2','18516053752',1,'4699e457ed94442d9c085753e7c6ffe0','ac02','','','152112199012093452',NULL,NULL,NULL,NULL,NULL,NULL,2,0,'ac02.png',NULL,'0.0.0.0',0,'2026-03-23 23:15:47.160795','2026-03-23 23:15:47.160795',NULL,NULL),(3,'admin3@qq.com','$2a$12$a6DAx2DqZtxiKJPWcuK99.c3AaHVQrOxw1t1EE4R1fOXNsnzJM1I.',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'管理员','user3','18516053753',1,'a33b43976e4c4bc1a8220ca1cecfbabb','ac03','','','152112199012093453',NULL,NULL,NULL,NULL,NULL,NULL,3,0,'ac03.png',NULL,'0.0.0.0',0,'2026-03-23 23:15:47.432357','2026-03-23 23:15:47.432357',NULL,NULL),(4,'admin4@qq.com','$2a$12$AxqdOu4HzhzIcx8YCc6Kt..tLP/2KLpRwE5Fp3cY.WZoK/aiPAZ1q',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'管理员','user4','18516053754',1,'1f64a5f14cc14c46a209c2d640ac76db','ac04','','','152112199012093454',NULL,NULL,NULL,NULL,NULL,NULL,4,0,'ac04.png',NULL,'0.0.0.0',0,'2026-03-23 23:15:47.684652','2026-03-23 23:15:47.684652',NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_areas`
--

DROP TABLE IF EXISTS `wms_areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_areas` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `warehouse_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `abbr` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `type_id` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `description` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `pinyin` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_areas_on_warehouse_id` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_areas`
--

LOCK TABLES `wms_areas` WRITE;
/*!40000 ALTER TABLE `wms_areas` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_areas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_locations`
--

DROP TABLE IF EXISTS `wms_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_locations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `warehouse_id` int DEFAULT NULL,
  `area_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `abbr` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `type_id` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `is_adjustment` tinyint(1) DEFAULT NULL,
  `is_reservation` tinyint(1) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `description` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `pinyin` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_locations_on_area_id` (`area_id`),
  KEY `index_wms_locations_on_warehouse_id` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_locations`
--

LOCK TABLES `wms_locations` WRITE;
/*!40000 ALTER TABLE `wms_locations` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_notice_lines`
--

DROP TABLE IF EXISTS `wms_notice_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_notice_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `notice_id` bigint DEFAULT NULL,
  `order_no` varchar(255) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `qty` varchar(255) DEFAULT NULL,
  `qty_unit` varchar(255) DEFAULT NULL,
  `packaging_note` varchar(255) DEFAULT NULL,
  `pieces` int DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_notice_lines_on_notice_id` (`notice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_notice_lines`
--

LOCK TABLES `wms_notice_lines` WRITE;
/*!40000 ALTER TABLE `wms_notice_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_notice_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_notices`
--

DROP TABLE IF EXISTS `wms_notices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_notices` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` int DEFAULT NULL,
  `recipient` varchar(255) DEFAULT NULL,
  `issuing_company` varchar(255) DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `total_pieces` int DEFAULT NULL,
  `unloading_fee_per_cbm` varchar(255) DEFAULT NULL,
  `minimum_charge_per_shipment` varchar(255) DEFAULT NULL,
  `entry_fee_per_vehicle` varchar(255) DEFAULT NULL,
  `nighttime_surcharge_note` text,
  `dangerous_goods_vehicle_fee` varchar(255) DEFAULT NULL,
  `box_truck_surcharge_note` varchar(255) DEFAULT NULL,
  `important_notes` text,
  `warehousing_number` varchar(255) DEFAULT NULL,
  `delivery_deadline` datetime(6) DEFAULT NULL,
  `warehouse_name` varchar(255) DEFAULT NULL,
  `warehouse_address` text,
  `contact_person` varchar(255) DEFAULT NULL,
  `contact_phone` varchar(255) DEFAULT NULL,
  `contact_hours` varchar(255) DEFAULT NULL,
  `dangerous_goods_receiving_note` varchar(255) DEFAULT NULL,
  `remarks_contact` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_notices`
--

LOCK TABLES `wms_notices` WRITE;
/*!40000 ALTER TABLE `wms_notices` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_notices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_pick_order_lines`
--

DROP TABLE IF EXISTS `wms_pick_order_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_pick_order_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `pick_order_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `plan_qty` decimal(12,2) DEFAULT '0.00',
  `picked_qty` decimal(12,2) DEFAULT '0.00',
  `status` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_pick_order_lines_on_item_id` (`item_id`),
  KEY `index_wms_pick_order_lines_on_location_id` (`location_id`),
  KEY `index_wms_pick_order_lines_on_pick_order_id` (`pick_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_pick_order_lines`
--

LOCK TABLES `wms_pick_order_lines` WRITE;
/*!40000 ALTER TABLE `wms_pick_order_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_pick_order_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_pick_orders`
--

DROP TABLE IF EXISTS `wms_pick_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_pick_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `work_order_id` int DEFAULT NULL,
  `order_category` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `warehouse_id` int DEFAULT NULL,
  `plan_date` datetime(6) DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `description` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_pick_orders_on_company_id` (`company_id`),
  KEY `index_wms_pick_orders_on_warehouse_id` (`warehouse_id`),
  KEY `index_wms_pick_orders_on_work_order_id` (`work_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_pick_orders`
--

LOCK TABLES `wms_pick_orders` WRITE;
/*!40000 ALTER TABLE `wms_pick_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_pick_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_receive_order_lines`
--

DROP TABLE IF EXISTS `wms_receive_order_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_receive_order_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `receive_order_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `plan_qty` decimal(12,2) DEFAULT '0.00',
  `received_qty` decimal(12,2) DEFAULT '0.00',
  `status` varchar(255) DEFAULT NULL,
  `work_order_byproduct_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_receive_order_lines_on_item_id` (`item_id`),
  KEY `index_wms_receive_order_lines_on_location_id` (`location_id`),
  KEY `index_wms_receive_order_lines_on_receive_order_id` (`receive_order_id`),
  KEY `index_wms_receive_order_lines_on_work_order_byproduct_id` (`work_order_byproduct_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_receive_order_lines`
--

LOCK TABLES `wms_receive_order_lines` WRITE;
/*!40000 ALTER TABLE `wms_receive_order_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_receive_order_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_receive_orders`
--

DROP TABLE IF EXISTS `wms_receive_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_receive_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `work_order_id` int DEFAULT NULL,
  `order_category` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `warehouse_id` int DEFAULT NULL,
  `plan_date` datetime(6) DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `description` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_receive_orders_on_company_id` (`company_id`),
  KEY `index_wms_receive_orders_on_warehouse_id` (`warehouse_id`),
  KEY `index_wms_receive_orders_on_work_order_id` (`work_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_receive_orders`
--

LOCK TABLES `wms_receive_orders` WRITE;
/*!40000 ALTER TABLE `wms_receive_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_receive_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_return_order_lines`
--

DROP TABLE IF EXISTS `wms_return_order_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_return_order_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `return_order_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `returned_qty` decimal(12,2) DEFAULT '0.00',
  `damage_status` varchar(255) DEFAULT NULL,
  `inventory_status_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_return_order_lines_on_inventory_status_id` (`inventory_status_id`),
  KEY `index_wms_return_order_lines_on_item_id` (`item_id`),
  KEY `index_wms_return_order_lines_on_location_id` (`location_id`),
  KEY `index_wms_return_order_lines_on_return_order_id` (`return_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_return_order_lines`
--

LOCK TABLES `wms_return_order_lines` WRITE;
/*!40000 ALTER TABLE `wms_return_order_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_return_order_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_return_orders`
--

DROP TABLE IF EXISTS `wms_return_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_return_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `return_category` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `original_order_id` int DEFAULT NULL,
  `warehouse_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_return_orders_on_original_order_id` (`original_order_id`),
  KEY `index_wms_return_orders_on_warehouse_id` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_return_orders`
--

LOCK TABLES `wms_return_orders` WRITE;
/*!40000 ALTER TABLE `wms_return_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_return_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_transfer_order_lines`
--

DROP TABLE IF EXISTS `wms_transfer_order_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_transfer_order_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `transfer_order_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `from_location_id` int DEFAULT NULL,
  `to_location_id` int DEFAULT NULL,
  `plan_qty` decimal(12,2) DEFAULT '0.00',
  `moved_qty` decimal(12,2) DEFAULT '0.00',
  `received_qty` decimal(12,2) DEFAULT '0.00',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_transfer_order_lines_on_from_location_id` (`from_location_id`),
  KEY `index_wms_transfer_order_lines_on_item_id` (`item_id`),
  KEY `index_wms_transfer_order_lines_on_to_location_id` (`to_location_id`),
  KEY `index_wms_transfer_order_lines_on_transfer_order_id` (`transfer_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_transfer_order_lines`
--

LOCK TABLES `wms_transfer_order_lines` WRITE;
/*!40000 ALTER TABLE `wms_transfer_order_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_transfer_order_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_transfer_orders`
--

DROP TABLE IF EXISTS `wms_transfer_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_transfer_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `transfer_type` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `from_warehouse_id` int DEFAULT NULL,
  `to_warehouse_id` int DEFAULT NULL,
  `move_category` varchar(255) DEFAULT NULL,
  `plan_date` datetime(6) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_transfer_orders_on_from_warehouse_id` (`from_warehouse_id`),
  KEY `index_wms_transfer_orders_on_to_warehouse_id` (`to_warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_transfer_orders`
--

LOCK TABLES `wms_transfer_orders` WRITE;
/*!40000 ALTER TABLE `wms_transfer_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_transfer_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wms_warehouses`
--

DROP TABLE IF EXISTS `wms_warehouses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wms_warehouses` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `abbr` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `type_id` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `description` text,
  `user_id` int DEFAULT NULL,
  `updater_id` int DEFAULT NULL,
  `py` varchar(255) DEFAULT NULL,
  `pinyin` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wms_warehouses_on_company_id` (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wms_warehouses`
--

LOCK TABLES `wms_warehouses` WRITE;
/*!40000 ALTER TABLE `wms_warehouses` DISABLE KEYS */;
/*!40000 ALTER TABLE `wms_warehouses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_edges`
--

DROP TABLE IF EXISTS `workflow_edges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_edges` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `template_id` bigint NOT NULL,
  `source_key` varchar(255) NOT NULL COMMENT '源节点 key',
  `target_key` varchar(255) NOT NULL COMMENT '目标节点 key',
  `label` varchar(255) DEFAULT NULL COMMENT '边的标签',
  `result_value` varchar(255) DEFAULT NULL COMMENT '条件结果',
  `sort` int DEFAULT '0',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_wf_edges_template_source_target` (`template_id`,`source_key`,`target_key`),
  KEY `index_workflow_edges_on_template_id` (`template_id`),
  CONSTRAINT `fk_rails_8fd2eb4f0d` FOREIGN KEY (`template_id`) REFERENCES `workflow_templates` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_edges`
--

LOCK TABLES `workflow_edges` WRITE;
/*!40000 ALTER TABLE `workflow_edges` DISABLE KEYS */;
INSERT INTO `workflow_edges` VALUES (1,1,'order','formula',NULL,NULL,0,'2026-03-23 23:15:48.158931','2026-03-23 23:15:48.158931'),(2,1,'order','cancel',NULL,NULL,1,'2026-03-23 23:15:48.170356','2026-03-23 23:15:48.170356'),(3,1,'formula','rd','无现成配方','new',2,'2026-03-23 23:15:48.176009','2026-03-23 23:15:48.176009'),(4,1,'formula','purchase','配方成熟','existing',3,'2026-03-23 23:15:48.183035','2026-03-23 23:15:48.183035'),(5,1,'rd','test_rd',NULL,NULL,4,'2026-03-23 23:15:48.187635','2026-03-23 23:15:48.187635'),(6,1,'test_rd','rd','不通过','rework',5,'2026-03-23 23:15:48.191882','2026-03-23 23:15:48.191882'),(7,1,'test_rd','formula','配方不成功','fail',6,'2026-03-23 23:15:48.195144','2026-03-23 23:15:48.195144'),(8,1,'purchase','pack_m',NULL,NULL,7,'2026-03-23 23:15:48.200685','2026-03-23 23:15:48.200685'),(9,1,'purchase','raw_m',NULL,NULL,8,'2026-03-23 23:15:48.205541','2026-03-23 23:15:48.205541'),(10,1,'pack_m','warehouse',NULL,NULL,9,'2026-03-23 23:15:48.213039','2026-03-23 23:15:48.213039'),(11,1,'raw_m','warehouse',NULL,NULL,10,'2026-03-23 23:15:48.218779','2026-03-23 23:15:48.218779'),(12,1,'warehouse','inspect',NULL,NULL,11,'2026-03-23 23:15:48.228267','2026-03-23 23:15:48.228267'),(13,1,'inspect','return_s','不合格','reject',12,'2026-03-23 23:15:48.233685','2026-03-23 23:15:48.233685'),(14,1,'inspect','downgrade','降级使用','downgrade',13,'2026-03-23 23:15:48.239306','2026-03-23 23:15:48.239306'),(15,1,'inspect','plan','合格','pass',14,'2026-03-23 23:15:48.246525','2026-03-23 23:15:48.246525'),(16,1,'plan','schedule',NULL,NULL,15,'2026-03-23 23:15:48.270500','2026-03-23 23:15:48.270500'),(17,1,'concession','plan','反馈',NULL,16,'2026-03-23 23:15:48.275668','2026-03-23 23:15:48.275668'),(18,1,'schedule','formulate',NULL,NULL,17,'2026-03-23 23:15:48.279711','2026-03-23 23:15:48.279711'),(19,1,'formulate','test_qc',NULL,NULL,18,'2026-03-23 23:15:48.289027','2026-03-23 23:15:48.289027'),(20,1,'test_qc','formulate','不合格','rework',19,'2026-03-23 23:15:48.294184','2026-03-23 23:15:48.294184'),(21,1,'test_qc','pack_setup','合格','pass',20,'2026-03-23 23:15:48.300911','2026-03-23 23:15:48.300911'),(22,1,'pack_setup','first_bottle',NULL,NULL,21,'2026-03-23 23:15:48.305910','2026-03-23 23:15:48.305910'),(23,1,'first_bottle','pack_setup','不通过','redo',22,'2026-03-23 23:15:48.311218','2026-03-23 23:15:48.311218'),(24,1,'first_bottle','packing','通过','pass',23,'2026-03-23 23:15:48.317393','2026-03-23 23:15:48.317393'),(25,1,'first_bottle','formulate','返工','rework',24,'2026-03-23 23:15:48.322084','2026-03-23 23:15:48.322084'),(26,1,'packing','sampling',NULL,NULL,25,'2026-03-23 23:15:48.330520','2026-03-23 23:15:48.330520'),(27,1,'sampling','biz_confirm','不合格','fail',26,'2026-03-23 23:15:48.336207','2026-03-23 23:15:48.336207'),(28,1,'sampling','ship','合格','pass',27,'2026-03-23 23:15:48.340095','2026-03-23 23:15:48.340095'),(29,1,'biz_confirm','concession',NULL,NULL,28,'2026-03-23 23:15:48.344969','2026-03-23 23:15:48.344969'),(30,1,'biz_confirm','ship',NULL,NULL,29,'2026-03-23 23:15:48.352902','2026-03-23 23:15:48.352902'),(31,1,'concession','ship',NULL,NULL,30,'2026-03-23 23:15:48.358603','2026-03-23 23:15:48.358603');
/*!40000 ALTER TABLE `workflow_edges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_node_results`
--

DROP TABLE IF EXISTS `workflow_node_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_node_results` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `template_id` bigint NOT NULL,
  `node_key` varchar(255) NOT NULL COMMENT '所属节点 key',
  `result_value` varchar(255) NOT NULL COMMENT '结果值',
  `result_label` varchar(255) DEFAULT NULL COMMENT '结果标签',
  `target_key` varchar(255) DEFAULT NULL COMMENT '跳转的节点 key',
  `sort` int DEFAULT '0',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_wf_node_results_uniq` (`template_id`,`node_key`,`result_value`),
  KEY `index_workflow_node_results_on_template_id` (`template_id`),
  CONSTRAINT `fk_rails_2cb8fb6b65` FOREIGN KEY (`template_id`) REFERENCES `workflow_templates` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_node_results`
--

LOCK TABLES `workflow_node_results` WRITE;
/*!40000 ALTER TABLE `workflow_node_results` DISABLE KEYS */;
INSERT INTO `workflow_node_results` VALUES (1,1,'formula','existing','现成配方','purchase',0,'2026-03-23 23:15:48.393111','2026-03-23 23:15:48.393111'),(2,1,'formula','new','需研发试验','rd',1,'2026-03-23 23:15:48.402749','2026-03-23 23:15:48.402749'),(3,1,'inspect','pass','合格','plan',2,'2026-03-23 23:15:48.410551','2026-03-23 23:15:48.410551'),(4,1,'inspect','downgrade','降级使用','downgrade',3,'2026-03-23 23:15:48.415827','2026-03-23 23:15:48.415827'),(5,1,'inspect','reject','不合格退回','return_s',4,'2026-03-23 23:15:48.421231','2026-03-23 23:15:48.421231'),(6,1,'test_qc','pass','合格','pack_setup',5,'2026-03-23 23:15:48.426501','2026-03-23 23:15:48.426501'),(7,1,'test_qc','rework','不合格返工','formulate',6,'2026-03-23 23:15:48.433146','2026-03-23 23:15:48.433146'),(8,1,'first_bottle','pass','通过','packing',7,'2026-03-23 23:15:48.437614','2026-03-23 23:15:48.437614'),(9,1,'first_bottle','redo','不通过重调','pack_setup',8,'2026-03-23 23:15:48.446637','2026-03-23 23:15:48.446637'),(10,1,'sampling','pass','合格','ship',9,'2026-03-23 23:15:48.452447','2026-03-23 23:15:48.452447'),(11,1,'sampling','fail','不合格','biz_confirm',10,'2026-03-23 23:15:48.458080','2026-03-23 23:15:48.458080'),(12,1,'biz_confirm','concession','让步接收','concession',11,'2026-03-23 23:15:48.469387','2026-03-23 23:15:48.469387'),(13,1,'biz_confirm','ship','直接发货','ship',12,'2026-03-23 23:15:48.476215','2026-03-23 23:15:48.476215');
/*!40000 ALTER TABLE `workflow_node_results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_nodes`
--

DROP TABLE IF EXISTS `workflow_nodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_nodes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `template_id` bigint NOT NULL,
  `key` varchar(255) NOT NULL COMMENT '节点标识，如 order、formula',
  `label` varchar(255) NOT NULL COMMENT '节点名称',
  `description` text COMMENT '节点描述',
  `position_x` int DEFAULT '0' COMMENT '画布 x 坐标',
  `position_y` int DEFAULT '0' COMMENT '画布 y 坐标',
  `sort` int DEFAULT '0',
  `has_result_options` tinyint(1) DEFAULT '0' COMMENT '是否有分支结果',
  `node_type` varchar(255) DEFAULT 'workflow' COMMENT '节点类型',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_workflow_nodes_on_template_id_and_key` (`template_id`,`key`),
  KEY `index_workflow_nodes_on_template_id` (`template_id`),
  CONSTRAINT `fk_rails_1a40d445e1` FOREIGN KEY (`template_id`) REFERENCES `workflow_templates` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_nodes`
--

LOCK TABLES `workflow_nodes` WRITE;
/*!40000 ALTER TABLE `workflow_nodes` DISABLE KEYS */;
INSERT INTO `workflow_nodes` VALUES (1,1,'order','订单',NULL,140,0,0,0,'workflow','2026-03-23 23:15:47.847204','2026-03-23 23:15:47.847204'),(2,1,'cancel','取消订单',NULL,380,0,1,0,'workflow','2026-03-23 23:15:47.865007','2026-03-23 23:15:47.865007'),(3,1,'formula','配方确认',NULL,140,70,2,1,'workflow','2026-03-23 23:15:47.882381','2026-03-23 23:15:47.882381'),(4,1,'rd','研发试验',NULL,20,150,3,0,'workflow','2026-03-23 23:15:47.912396','2026-03-23 23:15:47.912396'),(5,1,'test_rd','检测',NULL,20,230,4,0,'workflow','2026-03-23 23:15:47.920417','2026-03-23 23:15:47.920417'),(6,1,'purchase','采购',NULL,260,150,5,0,'workflow','2026-03-23 23:15:47.981012','2026-03-23 23:15:47.981012'),(7,1,'pack_m','包材、硬头、标签',NULL,80,230,6,0,'workflow','2026-03-23 23:15:47.989418','2026-03-23 23:15:47.989418'),(8,1,'raw_m','原药、助剂',NULL,280,230,7,0,'workflow','2026-03-23 23:15:47.996538','2026-03-23 23:15:47.996538'),(9,1,'warehouse','仓库收货',NULL,180,310,8,0,'workflow','2026-03-23 23:15:48.019416','2026-03-23 23:15:48.019416'),(10,1,'inspect','验收',NULL,180,390,9,1,'workflow','2026-03-23 23:15:48.028950','2026-03-23 23:15:48.028950'),(11,1,'return_s','退回供应商',NULL,0,470,10,0,'workflow','2026-03-23 23:15:48.037683','2026-03-23 23:15:48.037683'),(12,1,'downgrade','降级使用',NULL,120,470,11,0,'workflow','2026-03-23 23:15:48.051369','2026-03-23 23:15:48.051369'),(13,1,'plan','生产计划',NULL,300,470,12,0,'workflow','2026-03-23 23:15:48.057036','2026-03-23 23:15:48.057036'),(14,1,'schedule','排单',NULL,180,550,13,0,'workflow','2026-03-23 23:15:48.063507','2026-03-23 23:15:48.063507'),(15,1,'formulate','配制',NULL,180,630,14,0,'workflow','2026-03-23 23:15:48.076239','2026-03-23 23:15:48.076239'),(16,1,'test_qc','检测',NULL,180,710,15,1,'workflow','2026-03-23 23:15:48.087855','2026-03-23 23:15:48.087855'),(17,1,'pack_setup','包装调机',NULL,180,790,16,0,'workflow','2026-03-23 23:15:48.094337','2026-03-23 23:15:48.094337'),(18,1,'first_bottle','首瓶确认',NULL,180,870,17,1,'workflow','2026-03-23 23:15:48.100785','2026-03-23 23:15:48.100785'),(19,1,'packing','包装',NULL,180,950,18,0,'workflow','2026-03-23 23:15:48.106538','2026-03-23 23:15:48.106538'),(20,1,'sampling','抽检',NULL,180,1030,19,1,'workflow','2026-03-23 23:15:48.111837','2026-03-23 23:15:48.111837'),(21,1,'biz_confirm','业务确认',NULL,180,1110,20,1,'workflow','2026-03-23 23:15:48.117655','2026-03-23 23:15:48.117655'),(22,1,'concession','让步接收',NULL,180,1190,21,0,'workflow','2026-03-23 23:15:48.124701','2026-03-23 23:15:48.124701'),(23,1,'ship','发货',NULL,180,1270,22,0,'workflow','2026-03-23 23:15:48.132550','2026-03-23 23:15:48.132550');
/*!40000 ALTER TABLE `workflow_nodes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_templates`
--

DROP TABLE IF EXISTS `workflow_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workflow_templates` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL COMMENT '模板编码，如 contract_full',
  `name` varchar(255) NOT NULL COMMENT '模板名称',
  `description` text COMMENT '描述',
  `main_step_keys` json DEFAULT NULL COMMENT '主流程节点顺序',
  `is_default` tinyint(1) DEFAULT '0' COMMENT '是否默认模板',
  `sort` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否启用',
  `user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_workflow_templates_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_templates`
--

LOCK TABLES `workflow_templates` WRITE;
/*!40000 ALTER TABLE `workflow_templates` DISABLE KEYS */;
INSERT INTO `workflow_templates` VALUES (1,'contract_full','订购合同全流程','合同从订单到发货的完整流程','[\"order\", \"formula\", \"purchase\", \"warehouse\", \"inspect\", \"plan\", \"schedule\", \"formulate\", \"test_qc\", \"pack_setup\", \"first_bottle\", \"packing\", \"sampling\", \"ship\"]',1,0,1,NULL,'2026-03-23 23:15:47.773677','2026-03-23 23:15:47.773677');
/*!40000 ALTER TABLE `workflow_templates` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-07 12:54:39
