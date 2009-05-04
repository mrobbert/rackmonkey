-- ---------------------------------------------------------------------------
-- RackMonkey - Know Your Racks - http://www.rackmonkey.org                 --
-- Version 1.2.%BUILD%                                                      --
-- (C)2004-2009 Will Green (wgreen at users.sourceforge.net)                --
-- Update MySQL database schema to v4                                       --
-- ---------------------------------------------------------------------------

BEGIN;

ALTER TABLE building MODIFY COLUMN notes TEXT;
ALTER TABLE room MODIFY COLUMN notes TEXT;
ALTER TABLE row MODIFY COLUMN notes TEXT;
ALTER TABLE rack MODIFY COLUMN notes TEXT;
ALTER TABLE org MODIFY COLUMN notes TEXT;
ALTER TABLE service MODIFY COLUMN notes TEXT;
ALTER TABLE domain MODIFY COLUMN notes TEXT;
ALTER TABLE os MODIFY COLUMN notes TEXT;
ALTER TABLE hardware MODIFY COLUMN notes TEXT;
ALTER TABLE role MODIFY COLUMN notes TEXT;
ALTER TABLE device MODIFY COLUMN notes TEXT;
ALTER TABLE app MODIFY COLUMN notes TEXT;


ALTER TABLE device ADD COLUMN pxe_mac VARCHAR(255);
ALTER TABLE device ADD COLUMN net_install_build VARCHAR(255);
ALTER TABLE device ADD COLUMN custom_info TEXT;

CREATE UNIQUE INDEX device_app_unique ON device_app (app, device, relation); -- ensure we don't create identical device/app relationships

UPDATE rm_meta SET value='%BUILD%' WHERE name='system_build';
UPDATE rm_meta SET value='4' WHERE name='schema_version';

COMMIT;

SELECT name,value from rm_meta where name = 'schema_version';
