------------------------------------------------------------------------------
-- RackMonkey - Know Your Racks - http://www.rackmonkey.org                 --
-- Version 1.2.%BUILD%                                                      --
-- (C)2004-2009 Will Green (wgreen at users.sourceforge.net)                --
-- Test content for RackMonkey database                                     --
------------------------------------------------------------------------------

-- The inclusion of a company or product in this file does not consitute an endorement by the author. 
-- All trademarks are the property of their respective owners.

-- This data is designed to help test RackMonkey and provide a simple set of items for the creation of screenshots and other documentation.
-- This data should be applied after the default and sample data

-- Test Buildings (there is already one building in the sample data set)
INSERT INTO building (name, name_short, notes, meta_update_time, meta_update_user) VALUES('Telehouse Docklands', 'THDO', 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO building (name, name_short, notes, meta_update_time, meta_update_user) VALUES('Telehouse New York', 'THNY', 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');

-- Test Rooms (there is already one room in the sample data set)
INSERT INTO room (name, building, has_rows, notes, meta_update_time, meta_update_user) VALUES('TFM40', 7, 0, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO room (name, building, has_rows, notes, meta_update_time, meta_update_user) VALUES('TFM4', 7, 0, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO room (name, building, has_rows, notes, meta_update_time, meta_update_user) VALUES('TFM8', 7, 0, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');

-- Test Rows (not fully supported in v1.2.4 - so we add one hidden row per room)
INSERT INTO row (name, room, room_pos, hidden_row, notes, meta_update_time, meta_update_user) VALUES('-', 7, 0, 1, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO row (name, room, room_pos, hidden_row, notes, meta_update_time, meta_update_user) VALUES('-', 8, 0, 1, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO row (name, room, room_pos, hidden_row, notes, meta_update_time, meta_update_user) VALUES('-', 9, 0, 1, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');

-- Test Racks
INSERT INTO rack (name, row, row_pos, hidden_rack, size, notes, meta_update_time, meta_update_user) VALUES('A1', 7, 0, 0, 20, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO rack (name, row, row_pos, hidden_rack, size, notes, meta_update_time, meta_update_user) VALUES('A2', 7, 0, 0, 20, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO rack (name, row, row_pos, hidden_rack, size, notes, meta_update_time, meta_update_user) VALUES('A3', 7, 0, 0, 20, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO rack (name, row, row_pos, hidden_rack, size, notes, meta_update_time, meta_update_user) VALUES('A4', 7, 0, 0, 20, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO rack (name, row, row_pos, hidden_rack, size, notes, meta_update_time, meta_update_user) VALUES('A1', 8, 0, 0, 20, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO rack (name, row, row_pos, hidden_rack, size, notes, meta_update_time, meta_update_user) VALUES('A2', 8, 0, 0, 20, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO rack (name, row, row_pos, hidden_rack, size, notes, meta_update_time, meta_update_user) VALUES('A3', 8, 0, 0, 20, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO rack (name, row, row_pos, hidden_rack, size, notes, meta_update_time, meta_update_user) VALUES('A4', 8, 0, 0, 20, 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');

-- Test Domains
INSERT INTO domain (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('coyote.example.com', '', 'Test data included with RackMonkey.', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO domain (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('roadrunner.example.com', '', 'Test data included with RackMonkey.', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO domain (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('rackmonkey.org', '', 'Test data included with RackMonkey.', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO domain (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('example.com', '', 'Test data included with RackMonkey.', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Test Customers
INSERT INTO org (name, account_no, customer, software, hardware, descript, home_page, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('Coyote', NULL, 1, 0, 0, 'Wile E. Coyote', 101, 'Test data included with RackMonkey.', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO org (name, account_no, customer, software, hardware, descript, home_page, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('Road Runner', NULL, 1, 0, 0, 'Road Runner', 102, 'Test data included with RackMonkey.', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Test Service Levels
INSERT INTO service (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('Basic', 'Basic office hours support.', 'Test data included with RackMonkey.', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO service (name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES('24/7', '24/7 support.', 'Test data included with RackMonkey.', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Test Hardware
INSERT INTO hardware (name, manufacturer, size, image, support_url, spec_url, notes, meta_update_time, meta_update_user) VALUES('Fire x4600', 24, 4, NULL, 'http://sunsolve.sun.com/handbook_pub/Systems/SunFireX4600_M2/SunFireX4600_M2.html', 'http://sunsolve.sun.com/handbook_pub/Systems/SunFireX4600_M2/spec.html', 'Test data included with RackMonkey.', '1988-02-15 00:00:00', 'rackmonkey');

-- Test Devices
-- Two switches
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('sw1', 3, 11, 20, 2, 'ABC123', 'CH1001', '2004-02-29', 11, '', 26, 2, 21, 1, 'Test data included with RackMonkey.', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('sw2', 3, 12, 20, 2, 'ABC124', 'CH1002', '2004-02-29', 11, '', 26, 2, 21, 1, 'Test data included with RackMonkey.', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Two database servers
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, monitored, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('db1', 4, 11, 2, 5, 'T1234', '', '2007-09-05', 19, '10', 27, 4, 8, NULL, 1, '', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, monitored, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('db2', 4, 12, 2, 5, 'T1235', '', '2007-09-05', 19, '10', 27, 4, 8, NULL, 1, '', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- One monitoring server
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, monitored, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('mon', 3, 11, 17, 4, 'ABC125', 'CH1003', '2005-03-01', 8, '6', 26, 2, 16, NULL, 0, '', 0, '1988-02-15 00:00:00', 'rackmonkey');

-- Four web servers
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, monitored, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('www1', 4, 11, 7, 3, 'T4567', '', '2007-06-24', 19, '10', 27, 4, 24, NULL, 1, '', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, monitored, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('www2', 4, 12, 7, 3, 'T4568', '', '2007-06-24', 19, '10', 27, 4, 24, NULL, 1, '', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, monitored, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('www4', 4, 12, 10, 3, 'T4570', '', '2007-06-24', 19, '10', 27, 4, 24, NULL, 1, '', 0, '1988-02-15 00:00:00', 'rackmonkey');
INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, monitored, in_service, notes, meta_default_data, meta_update_time, meta_update_user) VALUES ('www3', 4, 11, 10, 3, 'T4569', '', '2007-06-24', 19, '10', 27, 4, 24, NULL, 1, '', 0, '1988-02-15 00:00:00', 'rackmonkey');
