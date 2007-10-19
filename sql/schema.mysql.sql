------------------------------------------------------------------------------
-- RackMonkey - Know Your Racks - http://www.rackmonkey.org                 --
-- Version 1.2.%BUILD%                                                      --
-- (C)2007 Will Green (wgreen at users.sourceforge.net)                     --
-- Database schema for MySQL database                                       --
------------------------------------------------------------------------------

-- Building the device resides in
CREATE TABLE building
(
	id INTEGER AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) UNIQUE NOT NULL,
	name_short VARCHAR(255),
	notes VARCHAR(255),
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)
) ENGINE = InnoDB;


-- The room the device resides in
CREATE TABLE room
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	building INTEGER REFERENCES building,
	has_rows INTEGER,
	notes VARCHAR(255),
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)	
);


-- The row the rack resides in
CREATE TABLE row
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	room INTEGER REFERENCES room,
	room_pos INTEGER NOT NULL,
	hidden_row INTEGER NOT NULL DEFAULT 0,
	notes VARCHAR(255),
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)	
);


-- The rack the device resides in
CREATE TABLE rack
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	row INTEGER REFERENCES row,
	row_pos INTEGER NOT NULL,
	hidden_rack INTEGER NOT NULL DEFAULT 0,
	size INTEGER,
	notes VARCHAR(255),
	meta_default_data INTEGER DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)	
);


-- Organisation or department, e.g. Human Resources, IBM, MI5
CREATE TABLE org
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) UNIQUE NOT NULL,
	account_no VARCHAR(255),
	customer INTEGER NOT NULL,
	software INTEGER NOT NULL,
	hardware INTEGER NOT NULL,
	descript VARCHAR(255),
	home_page VARCHAR(255),
	notes VARCHAR(255),
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)
);

-- Organisation related views
CREATE VIEW customer AS SELECT * FROM org WHERE customer = 1;
CREATE VIEW software_manufacturer AS SELECT * FROM org WHERE software = 1;
CREATE VIEW hardware_manufacturer AS SELECT * FROM org WHERE hardware = 1;


-- Service level of a device
CREATE TABLE service
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) UNIQUE NOT NULL,
	descript VARCHAR(255),
	notes VARCHAR(255),
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)	
);


-- Device domain
CREATE TABLE domain
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) UNIQUE NOT NULL,
	descript VARCHAR(255),
	notes VARCHAR(255),
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)	
);


-- Operating System
CREATE TABLE os
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) UNIQUE NOT NULL,
	manufacturer INTEGER REFERENCES org,
	notes VARCHAR(255),
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)	
);


-- A specifc model of hardware, e.g. Sun v240, Apple Xserve 
CREATE TABLE hardware
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) UNIQUE NOT NULL,
	manufacturer INTEGER REFERENCES org,
	size INTEGER NOT NULL,
	image VARCHAR(255),
	support_url VARCHAR(255),
	spec_url VARCHAR(255),
	notes VARCHAR(255),
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)	
);


-- Role played by the device, e.g. web server, Oracle server, router
CREATE TABLE role
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) UNIQUE NOT NULL,
	descript VARCHAR(255),
	notes VARCHAR(255),
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)	
);


-- An individual piece of hardware
CREATE TABLE device
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	domain INTEGER REFERENCES domain,
	rack INTEGER REFERENCES rack,
	rack_pos INTEGER,
	hardware INTEGER REFERENCES hardware,
	serial_no VARCHAR(255),
	asset_no VARCHAR(255),
	purchased CHAR(10),
	os INTEGER REFERENCES os,
	os_version VARCHAR(255), 
	customer INTEGER REFERENCES org,
	service INTEGER REFERENCES service,
	role INTEGER REFERENCES role,
	monitored INTEGER,
	in_service INTEGER,
	notes VARCHAR(255),
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)	
);


-- Applications and services provided by the device
CREATE TABLE app
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) UNIQUE NOT NULL,
	descript VARCHAR(255),
	notes VARCHAR(255),
	meta_default_data INTEGER NOT NULL DEFAULT 0,
	meta_update_time VARCHAR(255),
	meta_update_user VARCHAR(255)	
);


-- Relationships applications can have with devices
CREATE TABLE app_relation
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) UNIQUE NOT NULL
);


-- Relates devices to apps
CREATE TABLE device_app
(
	app INTEGER REFERENCES app,
	device INTEGER REFERENCES device,
	relation INTEGER REFERENCES app_relation
);


-- To log changes in RackMonkey entries
CREATE TABLE logging
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	table_changed VARCHAR(255) NOT NULL,
	id_changed INTEGER NOT NULL,
	name_changed VARCHAR(255),
	change_type VARCHAR(255),
	descript VARCHAR(255),
	update_time VARCHAR(255),
	update_user VARCHAR(255)
);


-- To store meta information about Rackmonkey database, e.g. revision.
CREATE TABLE rm_meta
(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	value VARCHAR(255) NOT NULL
);


-- Indexes
CREATE UNIQUE INDEX device_name_unique ON device (name, domain); -- ensure name and domain are together unique
CREATE UNIQUE INDEX rack_row_unique ON rack (name, row); -- ensure row and rack name are together unique
CREATE UNIQUE INDEX row_room_unique ON row (name, room); -- ensure room and row name are together unique
CREATE UNIQUE INDEX room_building_unique ON room (name, building); -- ensure building and room name are together unique