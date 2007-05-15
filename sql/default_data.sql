------------------------------------------------------------------------
-- RackMonkey - Know Your Racks - http://www.rackmonkey.org
-- Version 1.2.%BUILD%
-- (C)2007 Will Green (wgreen at users.sourceforge.net)
-- Default data for RackMonkey database
------------------------------------------------------------------------

-- install system information
INSERT INTO rm_meta(id, name, value) VALUES (1, 'system_version', '1.2');
INSERT INTO rm_meta(id, name, value) VALUES (2, 'system_build', '%BUILD%');

-- default buildings
INSERT INTO building (id, name, name_short, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (1, 'unknown', 'unknown', 'Default data included with RackMonkey.', 5, '2007-01-01 00:00:00', 'install');
INSERT INTO building (id, name, name_short, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (2, 'planned', 'plan', 'Default data included with RackMonkey.', 4, '2007-01-01 00:00:00', 'install');
INSERT INTO building (id, name, name_short, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (3, 'on order', 'order', 'Default data included with RackMonkey.', 3, '2007-01-01 00:00:00', 'install');
INSERT INTO building (id, name, name_short, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (4, 'being repaired', 'repair', 'Default data included with RackMonkey.', 2, '2007-01-01 00:00:00', 'install');
INSERT INTO building (id, name, name_short, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (5, 'decommissioned', 'decom', 'Default data included with RackMonkey.', 1, '2007-01-01 00:00:00', 'install');

-- default rooms
INSERT INTO room (id, name, building, has_rows, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (1, 'unknown', 1, 0, 'Default data included with RackMonkey.', 5, '2007-01-01 00:00:00', 'install');
INSERT INTO room (id, name, building, has_rows, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (2, 'planned', 2, 0, 'Default data included with RackMonkey.', 4, '2007-01-01 00:00:00', 'install');
INSERT INTO room (id, name, building, has_rows, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (3, 'on order', 3, 0, 'Default data included with RackMonkey.', 3, '2007-01-01 00:00:00', 'install');
INSERT INTO room (id, name, building, has_rows, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (4, 'being repaired', 4, 0, 'Default data included with RackMonkey.', 2, '2007-01-01 00:00:00', 'install');
INSERT INTO room (id, name, building, has_rows, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (5, 'decommissioned', 5, 0, 'Default data included with RackMonkey.', 1, '2007-01-01 00:00:00', 'install');

-- default rows
INSERT INTO row (id, name, room, room_pos, hidden_row, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (1, 'unknown', 1, 1, 1, 'Default data included with RackMonkey.', 5, '2007-01-01 00:00:00', 'install');
INSERT INTO row (id, name, room, room_pos, hidden_row, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (2, 'planned', 2, 1, 1, 'Default data included with RackMonkey.', 4, '2007-01-01 00:00:00', 'install');
INSERT INTO row (id, name, room, room_pos, hidden_row, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (3, 'on order', 3, 1, 1, 'Default data included with RackMonkey.', 3, '2007-01-01 00:00:00', 'install');
INSERT INTO row (id, name, room, room_pos, hidden_row, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (4, 'being repaired', 4, 1, 1, 'Default data included with RackMonkey.', 2, '2007-01-01 00:00:00', 'install');
INSERT INTO row (id, name, room, room_pos, hidden_row, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (5, 'decommissioned', 5, 1, 1, 'Default data included with RackMonkey.', 1, '2007-01-01 00:00:00', 'install');

-- default racks
INSERT INTO rack (id, name, row, row_pos, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (1, 'unknown', 1, 1, 'Default data included with RackMonkey.', 5, '2007-01-01 00:00:00', 'install');
INSERT INTO rack (id, name, row, row_pos, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (2, 'planned', 2, 1, 'Default data included with RackMonkey.', 4, '2007-01-01 00:00:00', 'install');
INSERT INTO rack (id, name, row, row_pos, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (3, 'on order', 3, 1, 'Default data included with RackMonkey.', 3, '2007-01-01 00:00:00', 'install');
INSERT INTO rack (id, name, row, row_pos, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (4, 'being repaired', 4, 1, 'Default data included with RackMonkey.', 2, '2007-01-01 00:00:00', 'install');
INSERT INTO rack (id, name, row, row_pos, notes, meta_default_data, meta_update_time, meta_update_user) VALUES (5, 'decommissioned', 5, 1, 'Default data included with RackMonkey.', 1, '2007-01-01 00:00:00', 'install');

-- default organisation
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_default_data, meta_update_time, meta_update_user) VALUES(1, 'unknown', NULL, 1, 1, 1, 'Organisation not known.', NULL, 'Default data included with RackMonkey.', 2, '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_default_data, meta_update_time, meta_update_user) VALUES(2, 'not applicable',	NULL, 1, 1, 1, 'Organisation not applicable.', NULL, 'Default data included with RackMonkey.', 1, '2007-01-01 00:00:00', 'install');

-- default service level
INSERT INTO service (id, name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES(1, 'unknown', 'Service level not known.', 'Default data included with RackMonkey.', 2, '2007-01-01 00:00:00', 'install');
INSERT INTO service (id, name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES(2, 'not applicable', 'Service level not applicable.', 'Default data included with RackMonkey.', 1, '2007-01-01 00:00:00', 'install');

-- default domain
INSERT INTO domain (id, name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES(1, 'unknown', 'Domain not known.', 'Default data included with RackMonkey.', 2, '2007-01-01 00:00:00', 'install');
INSERT INTO domain (id, name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES(2, 'not applicable', 'Domain not applicable.', 'Default data included with RackMonkey.', 1, '2007-01-01 00:00:00', 'install');

-- default operating systems
INSERT INTO os (id, name, manufacturer, notes, meta_default_data, meta_update_time, meta_update_user) VALUES(1, 'unknown', 1, 'Default data included with RackMonkey.', 2, '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_default_data, meta_update_time, meta_update_user) VALUES(2, 'not applicable', 2, 'Default data included with RackMonkey.', 1, '2007-01-01 00:00:00', 'install');

-- default hardware
INSERT INTO hardware (id, name, manufacturer, size, image, support_url, spec_url, notes, meta_default_data, meta_update_time, meta_update_user) VALUES(1, 'unknown', 1, 1, NULL, NULL, NULL, 'Default data included with RackMonkey.', 1, '2007-01-01 00:00:00', 'install');

-- default roles
INSERT INTO role (id, name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES(1, 'unknown', 'Role not known.', 'Default data included with RackMonkey.', 2, '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_default_data, meta_update_time, meta_update_user) VALUES(2, 'none', 'Role not currently assigned.', 'Default data included with RackMonkey.', 1, '2007-01-01 00:00:00', 'install');

-- default application relationships
INSERT INTO application_relationship (id, name) VALUES (1, 'is run on');
INSERT INTO application_relationship (id, name) VALUES (2, 'is developed on');
INSERT INTO application_relationship (id, name) VALUES (3, 'is tested on');
INSERT INTO application_relationship (id, name) VALUES (4, 'is staged on');
INSERT INTO application_relationship (id, name) VALUES (5, 'is on standby on');
INSERT INTO application_relationship (id, name) VALUES (6, 'uses');





