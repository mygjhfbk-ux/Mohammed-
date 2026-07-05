-- mc_db_new.sql
-- ملف SQL كامل لإنشاء قاعدة البيانات محسّنة

DROP DATABASE IF EXISTS `mc_db`;
CREATE DATABASE `mc_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `mc_db`;

-- users
CREATE TABLE `users` (
  `User-id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `User-Name` VARCHAR(255) NOT NULL,
  `User-Email` VARCHAR(255) DEFAULT NULL,
  `Password` VARCHAR(255) NOT NULL,
  `User-type` VARCHAR(50) NOT NULL,
  `User-phone` VARCHAR(50) DEFAULT NULL,
  `verification_code` VARCHAR(255) DEFAULT NULL,
  `is_verified` TINYINT(1) NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`User-id`),
  UNIQUE KEY `users_user_email_unique` (`User-Email`),
  INDEX idx_user_phone (`User-phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- merchants
CREATE TABLE `merchants` (
  `Merchant-id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `User-id` BIGINT(20) UNSIGNED NOT NULL,
  `Merchant-Name` VARCHAR(255) NOT NULL,
  `Merchant-BusinessName` VARCHAR(255) DEFAULT NULL,
  `Merchant-address` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Merchant-id`),
  INDEX idx_merchants_userid (`User-id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- customers
CREATE TABLE `customers` (
  `Customer-id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `User-id` BIGINT(20) UNSIGNED NOT NULL,
  `Customer-Name` VARCHAR(255) NOT NULL,
  `Customer-address` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Customer-id`),
  INDEX idx_customers_userid (`User-id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- subscriptions
CREATE TABLE `subscriptions` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `User-id` BIGINT(20) UNSIGNED NOT NULL,
  `plan_type` ENUM('free','silver','gold','pro') DEFAULT 'free',
  `period` ENUM('monthly','annual','lifetime') DEFAULT 'monthly',
  `status` ENUM('active','expired','cancelled','trial') DEFAULT 'trial',
  `amount_paid` DECIMAL(12,2) DEFAULT 0.00,
  `start_at` TIMESTAMP NULL DEFAULT NULL,
  `end_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_subscription_user (`User-id`),
  INDEX idx_sub_user (`User-id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ads
CREATE TABLE `ads` (
  `ad_id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `ad_title` VARCHAR(255) NOT NULL,
  `ad_image` VARCHAR(500) NOT NULL,
  `ad_link` VARCHAR(500) DEFAULT NULL,
  `ad_type` ENUM('banner','popup','slider') DEFAULT 'slider',
  `start_date` DATE DEFAULT NULL,
  `end_date` DATE DEFAULT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `click_count` INT(11) DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ad_id`),
  INDEX idx_ads_active (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- merchant_wallets
CREATE TABLE `merchant_wallets` (
  `wallet_id` INT(11) NOT NULL AUTO_INCREMENT,
  `merchant_id` BIGINT(20) UNSIGNED NOT NULL,
  `wallet_type` VARCHAR(50) NOT NULL,
  `wallet_number` VARCHAR(50) NOT NULL,
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`wallet_id`),
  INDEX idx_wallet_merchant (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- requests
CREATE TABLE `requests` (
  `Request-id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `Merchant-id` BIGINT(20) UNSIGNED NOT NULL,
  `Customer-id` BIGINT(20) UNSIGNED NULL,
  `Request-status` TINYINT(1) NOT NULL DEFAULT 0,
  `total_debt` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `account_limit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `Customer-Name` VARCHAR(255) NOT NULL,
  `is_local` TINYINT(1) NOT NULL DEFAULT 0,
  `address` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Request-id`),
  INDEX idx_requests_merchant (`Merchant-id`),
  INDEX idx_requests_customer (`Customer-id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- transactions
CREATE TABLE `transactions` (
  `Transaction-id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `Merchant-id` BIGINT(20) UNSIGNED NOT NULL,
  `Request-id` BIGINT(20) UNSIGNED NOT NULL,
  `Amount` DECIMAL(15,2) NOT NULL,
  `Debit` DECIMAL(15,2) DEFAULT 0.00,
  `Credit` DECIMAL(15,2) DEFAULT 0.00,
  `Balance_After` DECIMAL(15,2) DEFAULT 0.00,
  `Transaction-type` VARCHAR(50) NOT NULL,
  `Description` TEXT DEFAULT NULL,
  `Transaction-Date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Transaction-id`),
  INDEX idx_trans_request (`Request-id`),
  INDEX idx_trans_merchant (`Merchant-id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- transaction_details
CREATE TABLE `transaction_details` (
  `Detail-id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `Transaction-id` BIGINT(20) UNSIGNED NOT NULL,
  `Item-Name` VARCHAR(255) NOT NULL,
  `Quantity` DECIMAL(10,2) NOT NULL DEFAULT 1.00,
  `Price` DECIMAL(15,2) NOT NULL,
  `Total-Price` DECIMAL(20,2) AS (Quantity * Price) STORED,
  PRIMARY KEY (`Detail-id`),
  INDEX idx_detail_transaction (`Transaction-id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- notifications
CREATE TABLE `notifications` (
  `Not-id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `Sender-id` BIGINT(20) UNSIGNED NULL,
  `Receiver-id` BIGINT(20) UNSIGNED NULL,
  `Not-content` TEXT NOT NULL,
  `Not-isread` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Not-id`),
  INDEX idx_notifications_receiver (`Receiver-id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- refresh_tokens
CREATE TABLE IF NOT EXISTS `refresh_tokens` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT(20) NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `expires_at` DATETIME NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- indexes and foreign keys (add after cleaning data when migrating live)
ALTER TABLE `merchants` ADD INDEX (`User-id`);
ALTER TABLE `customers` ADD INDEX (`User-id`);
ALTER TABLE `requests` ADD INDEX (`Merchant-id`);
ALTER TABLE `transactions` ADD INDEX (`Request-id`);

-- sample admin user (password bcrypt for 'password')
INSERT INTO `users` (`User-Name`, `User-Email`, `Password`, `User-type`, `User-phone`, `is_verified`, `is_active`) VALUES ('Admin','admin@example.com','$2y$10$HSaYdDHxIrzLM6LWk45.TOZYvI.TqoHy0aujv0l7nGWW2dZq/9Es2','admin','000000000',1,1);

-- end of file
