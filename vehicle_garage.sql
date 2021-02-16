CREATE TABLE `vehicle_garage` (
	`vehicle` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`owner` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`plate` VARCHAR(12) NOT NULL COLLATE 'utf8mb4_general_ci',
	`type` VARCHAR(20) NOT NULL DEFAULT 'car' COLLATE 'utf8mb4_general_ci',
	`name` VARCHAR(20) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`plate`) USING BTREE,
	CONSTRAINT `vehicle` CHECK (json_valid(`vehicle`))
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;