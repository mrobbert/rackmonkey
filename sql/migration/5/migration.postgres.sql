-- ---------------------------------------------------------------------------
-- RackMonkey - Know Your Racks - http://www.rackmonkey.org                 --
-- Version 1.3.%BUILD%                                                      --
-- (C)2004-2010 Will Green (wgreen at users.sourceforge.net)                --
-- Update Postgres database schema to v5                                    --
-- ---------------------------------------------------------------------------

-- NB. This script currently only corrects rack and device sizes to 1/10th U.
--     It doesn't update the schema itself. This will come later.

BEGIN;

UPDATE rack SET size = size * 10;
UPDATE hardware SET size = size * 10;
UPDATE device SET rack_pos = rack_pos * 10;

COMMIT;

VACUUM;

SELECT name,value from rm_meta where name = 'schema_version';