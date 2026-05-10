-- 外跟单模块 MySQL 建表脚本
-- 说明：当前仅包含外跟单主表与外跟单明细表。
-- 数据库建议：MySQL 8.x，字符集 utf8mb4。

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `wgd_order_lines`;
DROP TABLE IF EXISTS `wgd_orders`;

CREATE TABLE `wgd_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(40) DEFAULT NULL COMMENT '外跟单编号',
  `receive_date` date DEFAULT NULL COMMENT '接单日期',
  `client_id` bigint DEFAULT NULL COMMENT '客户ID，关联 crm_clients.id',
  `client_name` varchar(255) DEFAULT NULL COMMENT '客户原始名称',
  `contract_code` varchar(255) DEFAULT NULL COMMENT '合同编号',
  `hazard_pack_month` varchar(100) DEFAULT NULL COMMENT '危包月份',
  `customer_delivery_date_text` varchar(255) DEFAULT NULL COMMENT '客户交期，保留文本',
  `follow_at` datetime(6) DEFAULT NULL COMMENT '跟进日期',
  `follow_progress` text COMMENT '跟进内容',
  `follower_id` bigint DEFAULT NULL COMMENT '跟单员ID，关联 users.id',
  `follower_name` varchar(100) DEFAULT NULL COMMENT '跟单员原始名称',
  `invoice_status` varchar(100) DEFAULT NULL COMMENT '开票情况',
  `invoice_at` datetime(6) DEFAULT NULL COMMENT '开票日期',
  `amount` decimal(14,2) DEFAULT NULL COMMENT '订单金额',
  `status_id` bigint DEFAULT NULL COMMENT '订单状态ID，可关联 properties.id',
  `remark` text COMMENT '备注',
  `user_id` bigint DEFAULT NULL COMMENT '创建人ID',
  `updater_id` bigint DEFAULT NULL COMMENT '更新人ID',
  `created_at` datetime(6) NOT NULL COMMENT '创建时间',
  `updated_at` datetime(6) NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_wgd_orders_code` (`code`),
  KEY `idx_wgd_orders_client_id` (`client_id`),
  KEY `idx_wgd_orders_follower_id` (`follower_id`),
  KEY `idx_wgd_orders_status_id` (`status_id`),
  KEY `idx_wgd_orders_receive_date` (`receive_date`),
  KEY `idx_wgd_orders_contract_code` (`contract_code`),
  CONSTRAINT `fk_wgd_orders_client`
    FOREIGN KEY (`client_id`) REFERENCES `crm_clients` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_wgd_orders_follower`
    FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='外跟单订单主表';

CREATE TABLE `wgd_order_lines` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint NOT NULL COMMENT '外跟单订单ID，关联 wgd_orders.id',
  `product_name` varchar(255) DEFAULT NULL COMMENT '产品名称',
  `model` varchar(255) DEFAULT NULL COMMENT '型号',
  `foil_pad_status` varchar(255) DEFAULT NULL COMMENT '铝箔垫情况',
  `color` varchar(255) DEFAULT NULL COMMENT '颜色',
  `requirements` text COMMENT '要求',
  `weight` varchar(100) DEFAULT NULL COMMENT '克重，保留原始格式',
  `color_master_status` varchar(255) DEFAULT NULL COMMENT '色母情况',
  `product_image_text` varchar(255) DEFAULT NULL COMMENT '产品图文说明',
  `qty` decimal(14,3) DEFAULT NULL COMMENT '订单量',
  `unit` varchar(50) DEFAULT NULL COMMENT '单位',
  `unit_price` decimal(12,2) DEFAULT NULL COMMENT '单价',
  `line_amount` decimal(14,2) DEFAULT NULL COMMENT '明细金额',
  `delivered_qty` decimal(14,3) DEFAULT NULL COMMENT '已发量',
  `undelivered_qty` decimal(14,3) DEFAULT NULL COMMENT '未发量',
  `sort` int DEFAULT NULL COMMENT '排序，保留 Excel 行内顺序',
  `remark` text COMMENT '备注',
  `created_at` datetime(6) NOT NULL COMMENT '创建时间',
  `updated_at` datetime(6) NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_wgd_order_lines_order_id` (`order_id`),
  KEY `idx_wgd_order_lines_product_name` (`product_name`),
  KEY `idx_wgd_order_lines_model` (`model`),
  KEY `idx_wgd_order_lines_sort` (`sort`),
  CONSTRAINT `fk_wgd_order_lines_order`
    FOREIGN KEY (`order_id`) REFERENCES `wgd_orders` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='外跟单订单明细表';

SET FOREIGN_KEY_CHECKS = 1;
