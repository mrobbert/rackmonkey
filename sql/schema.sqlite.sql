------------------------------------------------------------------------
-- RackMonkey - Know Your Racks - http://www.rackmonkey.org
-- Version 1.2.%BUILD%
-- (C)2007 Will Green (wgreen at users.sourceforge.net)
-- Database schema for SQLite database
------------------------------------------------------------------------

-- Building the device resides in
CREATE TABLE building
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR UNIQUE NOT NULL COLLATE NOCASE,
	name_short CHAR UNIQUE COLLATE NOCASE,
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR		
);


-- The room the device resides in
CREATE TABLE room
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR NOT NULL COLLATE NOCASE,
	building INTEGER NOT NULL
		CONSTRAINT fk_room_building_id REFERENCES building(id),
	has_rows INTEGER,
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR
);


-- The row the rack resides in
CREATE TABLE row
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR NOT NULL COLLATE NOCASE,
	room INTEGER NOT NULL
		CONSTRAINT fk_room_id REFERENCES room(id),
	room_pos INTEGER NOT NULL,
	hidden_row INTEGER NOT NULL DEFAULT 0,
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR
);


-- The rack the device resides in
CREATE TABLE rack
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR NOT NULL COLLATE NOCASE,
	row INTEGER NOT NULL
		CONSTRAINT fk_row_id REFERENCES row(id),	
	row_pos INTEGER NOT NULL,
	hidden_rack INTEGER NOT NULL DEFAULT 0,
	size INTEGER,
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR
);


-- Organisation or department, e.g. Human Resources, IBM, MI5
CREATE TABLE org
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR UNIQUE NOT NULL COLLATE NOCASE,
	account_no CHAR,
	customer INTEGER NOT NULL,
	software INTEGER NOT NULL,
	hardware INTEGER NOT NULL,
	descript CHAR,
	home_page CHAR,
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR
);

-- Organisation related views
CREATE VIEW customer AS SELECT * FROM org WHERE customer = 1;
CREATE VIEW software_manufacturer AS SELECT * FROM org WHERE software = 1;
CREATE VIEW hardware_manufacturer AS SELECT * FROM org WHERE hardware = 1;


-- Service level of a device
CREATE TABLE service
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR UNIQUE NOT NULL COLLATE NOCASE,
	descript CHAR,
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR
);


-- Device domain
CREATE TABLE domain
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR UNIQUE NOT NULL COLLATE NOCASE,
	descript CHAR,
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR
);


-- Operating System
CREATE TABLE os
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR UNIQUE NOT NULL COLLATE NOCASE,
	manufacturer INTEGER NOT NULL
		CONSTRAINT fk_manufacturer_id REFERENCES org(id),	
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR
);


-- A specifc model of hardware, e.g. Sun v240, Apple Xserve 
CREATE TABLE hardware
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR UNIQUE NOT NULL COLLATE NOCASE,
	manufacturer INTEGER NOT NULL
		CONSTRAINT fk_manufacturer_id REFERENCES org(id),	
	size INTEGER NOT NULL,
	image CHAR,
	support_url CHAR,
	spec_url CHAR,
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR
);


-- Role played by the device, e.g. web server, Oracle server, router
CREATE TABLE role
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR UNIQUE NOT NULL COLLATE NOCASE,
	descript CHAR,
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR
);


-- An individual piece of hardware
CREATE TABLE device
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR NOT NULL COLLATE NOCASE,
	domain INTEGER 
		CONSTRAINT fk_rack_id REFERENCES domain(id),
	rack INTEGER NOT NULL
		CONSTRAINT fk_rack_id REFERENCES rack(id),	
	rack_pos INTEGER NOT NULL,
	hardware INTEGER NOT NULL
		CONSTRAINT fk_hardware_id REFERENCES hardware(id),	
	serial CHAR,
	asset CHAR,
	purchased CHAR,
	os INTEGER NOT NULL
		CONSTRAINT fk_os_id REFERENCES os(id),	
	os_version CHAR,
	customer INTEGER
		CONSTRAINT fk_customer_id REFERENCES org(id),	
	service INTEGER NOT NULL
		CONSTRAINT fk_service_id REFERENCES service(id),	
	role INTEGER
		CONSTRAINT fk_role_id REFERENCES role(id),	
	monitored INTEGER,
	in_service INTEGER,
	monitor_url CHAR,
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR
);

-- Applications and services provided by the device
CREATE TABLE application
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR UNIQUE NOT NULL COLLATE NOCASE,
	descript CHAR,
	notes CHAR,
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time CHAR,
	meta_update_user CHAR
);

-- To store meta information about Rackmonkey database, e.g. revision.
CREATE TABLE rm_meta
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name CHAR NOT NULL COLLATE NOCASE,
	value CHAR COLLATE NOCASE
);


-- Indexes
CREATE UNIQUE INDEX device_name_unique ON device (name, domain); -- ensure name and domain are together unqiue
CREATE UNIQUE INDEX rack_row_unique ON rack (name, row); -- ensure row and rack name are together unqiue
CREATE UNIQUE INDEX row_room_unique ON row (name, room); -- ensure room and row name are together unqiue
CREATE UNIQUE INDEX room_building_unique ON room (name, building); -- ensure building and room name are together unqiue


------------------------------------------------------------------------
-- Foreign Key Constraints
--
-- Because SQLite does not enforce foreign key constraints, 
-- it is necessery to use triggers to enforce them.
-- Thanks to http://www.sqlite.org/cvstrac/wiki?p=ForeignKeyTriggers
------------------------------------------------------------------------

-- NEED TO FINISHING ADDING CONSTRAINTS

--
-- Table: Room
--

-- Prevent inserts into room table unless building exists
CREATE TRIGGER fki_room_building_id
BEFORE INSERT ON room
FOR EACH ROW BEGIN
	SELECT RAISE(ROLLBACK, 'insert on table "room" violates foreign key constraint "fki_room_building_id"')
 	WHERE NEW.building IS NOT NULL AND (SELECT id FROM building WHERE id = new.building) IS NULL;
END;

-- Prevent updates on room table unless building exists
CREATE TRIGGER fku_room_building_id
BEFORE UPDATE ON room
FOR EACH ROW BEGIN
	SELECT RAISE(ROLLBACK, 'update on table "room" violates foreign key constraint "fku_room_building_id"')
	WHERE NEW.building IS NOT NULL AND (SELECT id FROM building WHERE id = NEW.building) IS NULL;
END;

-- Prevent deletions of buildings used by the room table
CREATE TRIGGER fkd_room_building_id
BEFORE DELETE ON building
FOR EACH ROW BEGIN
	SELECT RAISE(ROLLBACK, 'delete on table "building" violates foreign key constraint "fkd_room_building_id"')
	WHERE (SELECT building FROM room WHERE building = OLD.id) IS NOT NULL;
END;


--
-- Table: Row
--

--
-- Table: Rack
--


--
-- Table: Hardware
--

-- Prevent inserts into hardware table unless manufacturer exists
CREATE TRIGGER fki_hardware_manufacturer_id
BEFORE INSERT ON hardware
FOR EACH ROW BEGIN
	SELECT RAISE(ROLLBACK, 'insert on table "hardware" violates foreign key constraint "fki_hardware_manufacturer_id"')
 	WHERE NEW.manufacturer IS NOT NULL AND (SELECT id FROM org WHERE id = new.manufacturer) IS NULL;
END;

-- Prevent updates on hardware table unless manufacturer exists
CREATE TRIGGER fku_hardware_manufacturer_id
BEFORE UPDATE ON hardware
FOR EACH ROW BEGIN
	SELECT RAISE(ROLLBACK, 'update on table "hardware" violates foreign key constraint "fku_hardware_manufacturer_id"')
	WHERE NEW.manufacturer IS NOT NULL AND (SELECT id FROM org WHERE id = NEW.manufacturer) IS NULL;
END;

-- Prevent deletions of manufacturers (org) used by the hardware table
CREATE TRIGGER fkd_hardware_manufacturer_id
BEFORE DELETE ON org
FOR EACH ROW BEGIN
	SELECT RAISE(ROLLBACK, 'delete on table "org" violates foreign key constraint "fkd_hardware_manufacturer_id"')
	WHERE (SELECT manufacturer FROM hardware WHERE manufacturer = OLD.id) IS NOT NULL;
END;


--
-- Table: os
--

-- Prevent inserts into os table unless manufacturer exists
CREATE TRIGGER fki_os_manufacturer_id
BEFORE INSERT ON os
FOR EACH ROW BEGIN
	SELECT RAISE(ROLLBACK, 'insert on table "os" violates foreign key constraint "fki_os_manufacturer_id"')
 	WHERE NEW.manufacturer IS NOT NULL AND (SELECT id FROM org WHERE id = new.manufacturer) IS NULL;
END;

-- Prevent updates on os table unless manufacturer exists
CREATE TRIGGER fku_os_manufacturer_id
BEFORE UPDATE ON os
FOR EACH ROW BEGIN
	SELECT RAISE(ROLLBACK, 'update on table "os" violates foreign key constraint "fku_os_manufacturer_id"')
	WHERE NEW.manufacturer IS NOT NULL AND (SELECT id FROM org WHERE id = NEW.manufacturer) IS NULL;
END;

-- Prevent deletions of manufacturers (org) used by the os table
CREATE TRIGGER fkd_os_manufacturer_id
BEFORE DELETE ON org
FOR EACH ROW BEGIN
	SELECT RAISE(ROLLBACK, 'delete on table "org" violates foreign key constraint "fkd_os_manufacturer_id"')
	WHERE (SELECT manufacturer FROM os WHERE manufacturer = OLD.id) IS NOT NULL;
END;
