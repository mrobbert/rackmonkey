##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.3.%BUILD%                                                        #
# (C)2004-2010 Will Green (wgreen at users.sourceforge.net)                  #
# Create a SQLite DB for testing                                             #
##############################################################################

DB_FILE=/var/tmp/rackmonkey.db
rm $DB_FILE
sqlite3 $DB_FILE < sql/schema/schema.sqlite.sql 
sqlite3 $DB_FILE < sql/data/default_data.sql 
chmod 777 $DB_FILE
