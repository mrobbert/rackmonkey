-- ---------------------------------------------------------------------------
-- RackMonkey - Know Your Racks - http://www.rackmonkey.org                 --
-- Version 1.2.%BUILD%                                                      --
-- (C)2004-2009 Will Green (wgreen at users.sourceforge.net)                --
-- Update Postgres database schema to v4                                    --
-- ---------------------------------------------------------------------------

BEGIN;

ALTER TABLE device ADD COLUMN pxe_mac VARCHAR;
ALTER TABLE device ADD COLUMN net_install_build VARCHAR;
ALTER TABLE device ADD COLUMN custom_info VARCHAR;

CREATE UNIQUE INDEX device_app_unique ON device_app (app, device, relation); -- ensure we don't create identical device/app relationships

UPDATE rm_meta SET value='%BUILD%' WHERE name='system_build';
UPDATE rm_meta SET value='4' WHERE name='schema_version';

COMMIT;

VACUUM;

SELECT name,value from rm_meta where name = 'schema_version';
