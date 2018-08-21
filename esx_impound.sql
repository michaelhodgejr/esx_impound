USE `essentialmode`;

CREATE TABLE `impounded_vehicles` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`vehicle` TEXT NULL,
	`owner` VARCHAR(250) NULL DEFAULT NULL,
	`impounded_at` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`id`),
	INDEX `owner` (`owner`)
)
