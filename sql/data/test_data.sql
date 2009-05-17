-- ---------------------------------------------------------------------------
-- RackMonkey - Know Your Racks - http://www.rackmonkey.org                 --
-- Version 1.2.%BUILD%                                                      --
-- (C)2004-2009 Will Green (wgreen at users.sourceforge.net)                --
-- Test content for RackMonkey database schema v4                           --
-- ---------------------------------------------------------------------------

-- The inclusion of a company or product in this file does not consitute an endorement by the author. 
-- All trademarks are the property of their respective owners.

-- This data is designed to help test RackMonkey and provide a simple set of items for the creation of screenshots and other documentation.
-- This data should be applied after the default and sample data

-- Test Buildings (there is already one building in the sample data set)
INSERT INTO building (name, name_short, notes, meta_update_time, meta_update_user) VALUES('Telehouse Docklands', 'THDO', 'Test data', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO building (name, name_short, notes, meta_update_time, meta_update_user) VALUES('Telehouse New York', 'THNY', 'Test data', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO building (name, name_short, notes, meta_update_time, meta_update_user) VALUES('Telecity Sovereign House', 'SOV', 'Test data', '1988-02-15 00:00:00', 'rackmonkey');

-- Test Rooms (there is already one room in the sample data set)
INSERT INTO room (name, building, has_rows, notes, meta_update_time, meta_update_user) VALUES('TFM4', 7, 0, 'Test data', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO room (name, building, has_rows, notes, meta_update_time, meta_update_user) VALUES('TFM8', 7, 0, 'Test data', '1988-02-15 00:00:00', 'rackmonkey');

-- Test Rows (not fully supported in v1.2.4 - so we add one hidden row per room)
INSERT INTO row (name, room, room_pos, hidden_row, notes, meta_update_time, meta_update_user) VALUES('-', 7, 0, 1, 'Test data', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO row (name, room, room_pos, hidden_row, notes, meta_update_time, meta_update_user) VALUES('-', 8, 0, 1, 'Test data', '1988-02-15 00:00:00', 'rackmonkey');

-- Test Racks
INSERT INTO rack (name, row, row_pos, hidden_rack, size, numbering_direction, notes, meta_update_time, meta_update_user) VALUES('A1', 7, 0, 0, 20, 0, 'Test data', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO rack (name, row, row_pos, hidden_rack, size, numbering_direction, notes, meta_update_time, meta_update_user) VALUES('A2', 7, 0, 0, 20, 0, 'Test data', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO rack (name, row, row_pos, hidden_rack, size, numbering_direction, notes, meta_update_time, meta_update_user) VALUES('R100', 8, 0, 0, 42, 1, 'Test data', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO rack (name, row, row_pos, hidden_rack, size, numbering_direction, notes, meta_update_time, meta_update_user) VALUES('R101', 8, 0, 0, 42, 1, 'Test data', '1988-02-15 00:00:00', 'rackmonkey');

-- Test Domains
INSERT INTO domain (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('coyote.example.com', '', 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO domain (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('roadrunner.example.com', '', 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO domain (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('rackmonkey.org', '', 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO domain (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('example.com', '', 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Test Customers
INSERT INTO org (name, account_no, customer, software, hardware, descript, home_page, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('Coyote', NULL, 1, 0, 0, 'Wile E. Coyote', 101, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO org (name, account_no, customer, software, hardware, descript, home_page, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('Road Runner', NULL, 1, 0, 0, 'Road Runner', 102, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Test Service Levels
INSERT INTO service (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('Basic', 'Basic office hours support.', 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO service (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('24/7', '24/7 support.', 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Test Devices
-- Two switches
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('sw1', 3, 7, 20, 2, 'ABC123', 'CH1001', '2004-02-29', 11, '12', 26, 2, 21, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('sw2', 3, 8, 20, 2, 'ABC124', 'CH1002', '2004-02-29', 11, '12', 26, 2, 21, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Two database servers
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('db1', 4, 7, 2, 5, 'T1234', '', '2009-01-01', 17, '4', 27, 4, 8, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('db2', 4, 8, 2, 5, 'T1235', '', '2009-01-14', 17, '4', 27, 4, 8, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Two monitoring servers
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('mon1', 3, 7, 17, 4, 'ABC125', 'CH1003', '2008-11-01', 8, '6', 26, 2, 16, 0, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('mon2', 3, 8, 17, 4, 'ABC126', 'CH1004', '2008-11-01', 8, '6', 26, 2, 16, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Four web servers
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('www1', 4, 7, 5, 3, 'T4567', '', '2007-06-24', 21, '8.04', 27, 4, 24, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('www2', 4, 8, 5, 3, 'T4568', '', '2007-06-24', 21, '8.04', 27, 4, 24, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('www4', 4, 8, 7, 3, 'T4570', '', '2007-06-24', 21, '8.04', 27, 4, 24, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('www3', 4, 7, 7, 3, 'T4569', '', '2007-06-24', 21, '8.04', 27, 4, 24, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Three app servers
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('app1', 4, 7, 10, 7, 'T9909', '', '2007-09-24', 19, '10', 27, 4, 3, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('app2', 4, 8, 10, 7, 'T9910', '', '2007-10-24', 19, '10', 27, 4, 3, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('appdev', 4, 8, 12, 7, 'T9998', '', '2007-04-24', 16, '2008.11', 27, 4, 3, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Windows fileserver, includes OS licence key
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, os_licence_key, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('winfs', 5, 7, 12, 4, 'T9909', '', '2007-09-24', 24, '2003', 'AAAAA-BBBBB-CCCCC-DDDDD-EEEEE', 27, 4, 12, 1, 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- A couple of devices for racks numbered from top, includes primary_mac and install_build fields (not exposed in GUI in v1.2.5)
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, primary_mac, install_build, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('www10', 5, 9, 10, 4, 'T9909', '', '2009-01-02', 21, '9.04', 27, 4, 3, 1, '00:1e:c2:04:63:94', 'ubuntu_8_04_web', 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, primary_mac, install_build, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('www11', 5, 9, 11, 4, 'T9910', '', '2009-01-02', 21, '9.04', 27, 4, 3, 1, '00:1e:c2:04:63:95', 'ubuntu_8_04_web', 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Test Apps
INSERT INTO app (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('Acme CDB', 'Acme Customer Database', 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO app (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('Roadrunner Route', 'Roadrunner Mapping Software', 'Test data', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Associate apps with a device
INSERT INTO device_app (app, device, relation, meta_update_time, meta_update_user) VALUES (1, 3, 6, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device_app (app, device, relation, meta_update_time, meta_update_user) VALUES (1, 4, 6, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device_app (app, device, relation, meta_update_time, meta_update_user) VALUES (1, 12, 1, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device_app (app, device, relation, meta_update_time, meta_update_user) VALUES (2, 11, 1, '1988-02-15 00:00:00', 'rackmonkey');
