-- ---------------------------------------------------------------------------
-- RackMonkey - Know Your Racks - http://www.rackmonkey.org                 --
-- Version 1.2.%BUILD%                                                      --
-- (C)2004-2009 Will Green (wgreen at users.sourceforge.net)                --
-- Update database schema to v3 for SQLite                                  --
-- ---------------------------------------------------------------------------

ALTER TABLE rack ADD COLUMN numbering_direction INTEGER NOT NULL DEFAULT 0;
ALTER TABLE device ADD COLUMN os_licence_key CHAR;