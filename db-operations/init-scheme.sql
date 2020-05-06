/* The size table which has all the sizes used. */
CREATE TABLE `size` (
  `id` varchar(10) NOT NULL COMMENT 'String representation for the size' PRIMARY KEY,
  `value` int NOT NULL COMMENT 'Value to help compare different ids'
) COMMENT='Table with sizes and respective attributes';

/* The color table with the list of all colors */
CREATE TABLE `color` (
  `id` varchar(10) NOT NULL COMMENT 'name of the color' PRIMARY KEY
) COMMENT='Table with colors';

/* The container type table with the list of container supported */
CREATE TABLE `container_type` (
  `id` varchar(10) NOT NULL COMMENT 'name of the container' PRIMARY KEY
) COMMENT='Table with list of container type supported';

/* The container type and colors are mapped to help with color rules */
CREATE TABLE `container_type_color_map` (
  `id` int NOT NULL COMMENT 'unique id for each container type color map reference' AUTO_INCREMENT PRIMARY KEY,
  `container_type` varchar(10) NOT NULL COMMENT 'container type reference',
  `color` varchar(10) NOT NULL COMMENT 'color type reference',
	FOREIGN KEY (`container_type`) REFERENCES `container_type` (`id`),
	FOREIGN KEY (`color`) REFERENCES `color` (`id`)
) COMMENT='Table with container_type and color mapping.';
ALTER TABLE `container_type_color_map`
ADD INDEX `color_container_type_idx` (`color`, `container_type`);

/* The container which stores the baubles */
CREATE TABLE `container` (
  `id` int NOT NULL COMMENT 'unique container id' AUTO_INCREMENT PRIMARY KEY,
  `type` varchar(10) NOT NULL COMMENT 'the type of the container',
  `size` varchar(10) NOT NULL COMMENT 'the size of the container',
	FOREIGN KEY (`type`) REFERENCES `container_type` (`id`),
	FOREIGN KEY (`size`) REFERENCES `size` (`id`)
) COMMENT='Table for the various containers.';

/* The table which stores the bauble */
CREATE TABLE `bauble` (
  `id` int NOT NULL COMMENT 'id for each bauble',
  `container_id` int NOT NULL COMMENT 'the container which the bauble belongs to',
  `color` varchar(10) COLLATE 'utf8mb4_0900_ai_ci' NOT NULL COMMENT 'the color of the bauble',
  `size` varchar(10) COLLATE 'utf8mb4_0900_ai_ci' NOT NULL COMMENT 'the size of the bauble',
  FOREIGN KEY (`container_id`) REFERENCES `container` (`id`),
  FOREIGN KEY (`color`) REFERENCES `color` (`id`),
  FOREIGN KEY (`size`) REFERENCES `size` (`id`)
) COMMENT='Table with baubles with the respective information and container it belongs to';
/* ensure that bauble are deleted or update if the container are deleted or updated */
ALTER TABLE `bauble`
DROP FOREIGN KEY `bauble_ibfk_1`,
ADD FOREIGN KEY (`container_id`) REFERENCES `container` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
/* since the baubles are in the millions which can be handled by int but this is safer */
ALTER TABLE `test`.`bauble` 
CHANGE COLUMN `id` `id` BIGINT AUTO_INCREMENT PRIMARY KEY NOT NULL COMMENT 'id for each bauble' ;

/* business logic triggers for baubles */
/* for insert */
DROP TRIGGER IF EXISTS `test`.`bauble_BEFORE_INSERT`;

DELIMITER $$
USE `test`$$
CREATE DEFINER=`user`@`%` TRIGGER `bauble_BEFORE_INSERT` BEFORE INSERT ON `bauble` FOR EACH ROW BEGIN
	DECLARE bauble_value int;
    DECLARE container_value int;
    DECLARE container_size varchar(10);
    DECLARE container_type_id varchar(10);
    DECLARE container_count int;
    /* get container information */
    SELECT size, type into container_size, container_type_id FROM container WHERE id = NEW.container_id;
	/* check if the size of the bauble is adequate for the container */
	SELECT value into bauble_value FROM size WHERE id = NEW.size;
    SELECT value into container_value FROM size WHERE id = container_size;
    IF (container_value < bauble_value) THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'bauble too big for container', MYSQL_ERRNO = 1001;
    END IF;
    /* check if the color of the bauble is valid for the container */
    SELECT count(id) into container_count FROM container_type_color_map where color = NEW.color
		and container_type = container_type_id;
    IF (container_count = 0) THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'bauble color not valid for container', MYSQL_ERRNO = 1002;
    END IF;
END$$
DELIMITER ;
/* for update */
DROP TRIGGER IF EXISTS `test`.`bauble_BEFORE_UPDATE`;

DELIMITER $$
USE `test`$$
CREATE DEFINER=`user`@`%` TRIGGER `bauble_BEFORE_UPDATE` BEFORE UPDATE ON `bauble` FOR EACH ROW BEGIN
DECLARE bauble_value int;
    DECLARE container_value int;
    DECLARE container_size varchar(10);
    DECLARE container_type_id varchar(10);
    DECLARE container_count int;
    /* get container information */
    SELECT size, type into container_size, container_type_id FROM container WHERE id = NEW.container_id;
	/* check if the size of the bauble is adequate for the container */
	SELECT value into bauble_value FROM size WHERE id = NEW.size;
    SELECT value into container_value FROM size WHERE id = container_size;
    IF (container_value < bauble_value) THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'bauble too big for container', MYSQL_ERRNO = 1001;
    END IF;
    /* check if the color of the bauble is valid for the container */
    SELECT count(id) into container_count FROM container_type_color_map where color = NEW.color
		and container_type = container_type_id;
    IF (container_count = 0) THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'bauble color not valid for container', MYSQL_ERRNO = 1002;
    END IF;
END$$
DELIMITER ;

/* Populate the tables with data which is required for the initial setup */
/* ensure both type of container are present */
INSERT INTO `container_type` (`id`) VALUES ('bucket');
INSERT INTO `container_type` (`id`) VALUES ('box');

/* various sizes and a value associated with it */
INSERT INTO `size` (`id`, `value`) VALUES ('small', '10');
INSERT INTO `size` (`id`, `value`) VALUES ('medium', '20');
INSERT INTO `size` (`id`, `value`) VALUES ('large', '30');

/* various colors for the baubles */
INSERT INTO `color` (`id`) VALUES ('red');
INSERT INTO `color` (`id`) VALUES ('green');
INSERT INTO `color` (`id`) VALUES ('blue');
INSERT INTO `color` (`id`) VALUES ('orange');
INSERT INTO `color` (`id`) VALUES ('yellow');

/* rules for the container and the colors supported */
INSERT INTO `container_type_color_map` (`container_type`, `color`) VALUES ('bucket', 'red');
INSERT INTO `container_type_color_map` (`container_type`, `color`) VALUES ('bucket', 'blue');
INSERT INTO `container_type_color_map` (`container_type`, `color`) VALUES ('bucket', 'green');
INSERT INTO `container_type_color_map` (`container_type`, `color`) VALUES ('box', 'orange');
INSERT INTO `container_type_color_map` (`container_type`, `color`) VALUES ('box', 'yellow');