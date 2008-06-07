------------------------------------------------------------------------------
-- RackMonkey - Know Your Racks - http://www.rackmonkey.org                 --
-- Version 1.2.%BUILD%                                                      --
-- (C)2004-2008 Will Green (wgreen at users.sourceforge.net)                --
-- Test content for RackMonkey database                                     --
------------------------------------------------------------------------------

-- The inclusion of a company or product in this file does not consitute an endorement by the author. 
-- All trademarks are the property of their respective owners.

-- This data is designed to help test RackMonkey and provide a simple set of items for the creation of screenshots and other documentation.
-- This file should not be included in final distributions

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