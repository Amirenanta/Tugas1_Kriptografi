-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 28, 2024 at 10:30 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `asset_management`
--
CREATE DATABASE IF NOT EXISTS `asset_management` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `asset_management`;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `role` enum('Administrator','User') DEFAULT 'User',
  `email` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `full_name`, `role`, `email`, `created_at`, `updated_at`) VALUES
(1, 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator', 'Administrator', 'admin@assetmanagement.com', '2024-11-28 03:00:00', '2024-11-28 03:00:00'),
(2, 'user', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Regular User', 'User', 'user@assetmanagement.com', '2024-11-28 03:00:00', '2024-11-28 03:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `assets`
--

DROP TABLE IF EXISTS `assets`;
CREATE TABLE IF NOT EXISTS `assets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `asset_code` varchar(100) NOT NULL,
  `asset_name` text NOT NULL,
  `category` varchar(50) NOT NULL,
  `location` text NOT NULL,
  `status` enum('Active','Maintenance','Retired','Disposed') DEFAULT 'Active',
  `purchase_date` date NOT NULL,
  `price` text NOT NULL,
  `specifications` text DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `asset_code` (`asset_code`),
  KEY `idx_asset_code` (`asset_code`),
  KEY `idx_category` (`category`),
  KEY `idx_status` (`status`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `assets_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `assets`
--

INSERT INTO `assets` (`id`, `asset_code`, `asset_name`, `category`, `location`, `status`, `purchase_date`, `price`, `specifications`, `serial_number`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'HW-001', 'Dell PowerEdge R740', 'Server', 'Data Center A', 'Active', '2023-01-15', '50000000', '2x Intel Xeon Gold 6230, 256GB RAM, 8TB Storage', 'DL-R740-2023-001', 1, '2024-11-28 03:10:00', '2024-11-28 03:10:00'),
(2, 'HW-002', 'HP ProLiant DL380', 'Server', 'Data Center B', 'Active', '2023-03-20', '45000000', '2x Intel Xeon Silver 4214, 128GB RAM, 4TB Storage', 'HP-DL380-2023-002', 1, '2024-11-28 03:15:00', '2024-11-28 03:15:00'),
(3, 'HW-003', 'Cisco Catalyst 9300', 'Network', 'Network Room', 'Active', '2023-05-10', '30000000', '48-Port Gigabit Switch with 10G Uplinks', 'CS-9300-2023-003', 1, '2024-11-28 03:20:00', '2024-11-28 03:20:00'),
(4, 'HW-004', 'Lenovo ThinkStation P620', 'Desktop', 'Design Department', 'Active', '2023-06-15', '35000000', 'AMD Threadripper PRO 3975WX, 128GB RAM, NVIDIA RTX A5000', 'TS-P620-2023-004', 1, '2024-11-28 03:25:00', '2024-11-28 03:25:00'),
(5, 'HW-005', 'HPE MSA 2050', 'Storage', 'Data Center A', 'Active', '2023-07-20', '60000000', 'SAN Storage 24TB, Dual Controllers', 'HPE-MSA-2023-005', 1, '2024-11-28 03:30:00', '2024-11-28 03:30:00'),
(6, 'HW-006', 'Dell Latitude 7420', 'Laptop', 'IT Department', 'Maintenance', '2023-08-10', '18000000', 'Intel Core i7-1185G7, 16GB RAM, 512GB SSD', 'DL-7420-2023-006', 1, '2024-11-28 03:35:00', '2024-11-28 04:00:00'),
(7, 'HW-007', 'HP LaserJet Enterprise M607', 'Printer', 'Floor 3 Print Room', 'Active', '2023-09-05', '12000000', 'Monochrome Laser Printer, Duplex, Network', 'HP-M607-2023-007', 1, '2024-11-28 03:40:00', '2024-11-28 03:40:00'),
(8, 'HW-008', 'Synology DS1821+', 'Storage', 'Backup Room', 'Active', '2023-10-12', '25000000', 'NAS 8-Bay, AMD Ryzen V1500B, 32GB RAM', 'SYN-DS1821-2023-008', 1, '2024-11-28 03:45:00', '2024-11-28 03:45:00');

-- --------------------------------------------------------

--
-- Table structure for table `asset_history`
--

DROP TABLE IF EXISTS `asset_history`;
CREATE TABLE IF NOT EXISTS `asset_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `asset_id` int(11) NOT NULL,
  `action_type` enum('CREATE','UPDATE','DELETE') NOT NULL,
  `old_data` text DEFAULT NULL,
  `new_data` text DEFAULT NULL,
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_asset_id` (`asset_id`),
  KEY `idx_changed_at` (`changed_at`),
  KEY `changed_by` (`changed_by`),
  CONSTRAINT `asset_history_ibfk_1` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `asset_history_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `asset_history`
--

INSERT INTO `asset_history` (`id`, `asset_id`, `action_type`, `old_data`, `new_data`, `changed_by`, `changed_at`, `notes`) VALUES
(1, 1, 'CREATE', NULL, 'Initial asset creation', 1, '2024-11-28 03:10:00', 'Added new server to inventory'),
(2, 2, 'CREATE', NULL, 'Initial asset creation', 1, '2024-11-28 03:15:00', 'Added new server to inventory'),
(3, 3, 'CREATE', NULL, 'Initial asset creation', 1, '2024-11-28 03:20:00', 'Added network switch'),
(4, 6, 'UPDATE', 'Status changed from Active to Maintenance', NULL, 1, '2024-11-28 04:00:00', 'Hardware issue - needs repair');

-- --------------------------------------------------------

--
-- Table structure for table `encryption_keys`
--

DROP TABLE IF EXISTS `encryption_keys`;
CREATE TABLE IF NOT EXISTS `encryption_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key_name` varchar(50) NOT NULL,
  `encryption_key` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `key_name` (`key_name`),
  KEY `idx_key_name` (`key_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `encryption_keys`
--

INSERT INTO `encryption_keys` (`id`, `key_name`, `encryption_key`, `is_active`, `created_at`) VALUES
(1, 'default_key', 'AssetSecureKey2024', 1, '2024-11-28 03:00:00');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_asset_category_summary`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `v_asset_category_summary`;
CREATE TABLE IF NOT EXISTS `v_asset_category_summary` (
`category` varchar(50)
,`total_assets` bigint(21)
,`active_count` decimal(22,0)
,`maintenance_count` decimal(22,0)
,`retired_count` decimal(22,0)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_recent_activities`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `v_recent_activities`;
CREATE TABLE IF NOT EXISTS `v_recent_activities` (
`id` int(11)
,`asset_code` varchar(100)
,`asset_name` text
,`action_type` enum('CREATE','UPDATE','DELETE')
,`changed_by_user` varchar(50)
,`changed_at` timestamp
,`notes` text
);

-- --------------------------------------------------------

--
-- Structure for view `v_asset_category_summary`
--
DROP TABLE IF EXISTS `v_asset_category_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_asset_category_summary`  AS SELECT `assets`.`category` AS `category`, count(0) AS `total_assets`, sum(case when `assets`.`status` = 'Active' then 1 else 0 end) AS `active_count`, sum(case when `assets`.`status` = 'Maintenance' then 1 else 0 end) AS `maintenance_count`, sum(case when `assets`.`status` = 'Retired' then 1 else 0 end) AS `retired_count` FROM `assets` GROUP BY `assets`.`category` ;

-- --------------------------------------------------------

--
-- Structure for view `v_recent_activities`
--
DROP TABLE IF EXISTS `v_recent_activities`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_recent_activities`  AS SELECT `ah`.`id` AS `id`, `a`.`asset_code` AS `asset_code`, `a`.`asset_name` AS `asset_name`, `ah`.`action_type` AS `action_type`, `u`.`username` AS `changed_by_user`, `ah`.`changed_at` AS `changed_at`, `ah`.`notes` AS `notes` FROM ((`asset_history` `ah` left join `assets` `a` on(`ah`.`asset_id` = `a`.`id`)) left join `users` `u` on(`ah`.`changed_by` = `u`.`id`)) ORDER BY `ah`.`changed_at` DESC LIMIT 0, 50 ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `idx_username` (`username`);

--
-- Indexes for table `assets`
--
ALTER TABLE `assets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `asset_code` (`asset_code`),
  ADD KEY `idx_asset_code` (`asset_code`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `asset_history`
--
ALTER TABLE `asset_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_asset_id` (`asset_id`),
  ADD KEY `idx_changed_at` (`changed_at`),
  ADD KEY `changed_by` (`changed_by`);

--
-- Indexes for table `encryption_keys`
--
ALTER TABLE `encryption_keys`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `key_name` (`key_name`),
  ADD KEY `idx_key_name` (`key_name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `assets`
--
ALTER TABLE `assets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `asset_history`
--
ALTER TABLE `asset_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `encryption_keys`
--
ALTER TABLE `encryption_keys`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `assets`
--
ALTER TABLE `assets`
  ADD CONSTRAINT `assets_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `asset_history`
--
ALTER TABLE `asset_history`
  ADD CONSTRAINT `asset_history_ibfk_1` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `asset_history_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `sp_get_asset_statistics`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_asset_statistics` ()   BEGIN
    SELECT 
        COUNT(*) as total_assets,
        SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) as active_assets,
        SUM(CASE WHEN status = 'Maintenance' THEN 1 ELSE 0 END) as maintenance_assets,
        SUM(CASE WHEN status = 'Retired' THEN 1 ELSE 0 END) as retired_assets,
        SUM(CASE WHEN status = 'Disposed' THEN 1 ELSE 0 END) as disposed_assets,
        COUNT(DISTINCT category) as total_categories
    FROM assets;
END$$

DROP PROCEDURE IF EXISTS `sp_log_asset_change`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_log_asset_change` (IN `p_asset_id` INT, IN `p_action_type` VARCHAR(10), IN `p_old_data` TEXT, IN `p_new_data` TEXT, IN `p_changed_by` INT, IN `p_notes` TEXT)   BEGIN
    INSERT INTO asset_history (asset_id, action_type, old_data, new_data, changed_by, notes)
    VALUES (p_asset_id, p_action_type, p_old_data, p_new_data, p_changed_by, p_notes);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Triggers
--

DELIMITER $$
DROP TRIGGER IF EXISTS `tr_asset_after_update`$$
CREATE TRIGGER `tr_asset_after_update` AFTER UPDATE ON `assets` FOR EACH ROW BEGIN
    INSERT INTO asset_history (asset_id, action_type, old_data, new_data, notes)
    VALUES (
        NEW.id,
        'UPDATE',
        CONCAT('Status: ', OLD.status, ', Location: ', OLD.location),
        CONCAT('Status: ', NEW.status, ', Location: ', NEW.location),
        'Auto-logged by trigger'
    );
END$$
DELIMITER ;

COMMIT;
