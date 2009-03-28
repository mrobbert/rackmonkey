DB_FILE=/Users/flux/Sites/data/rackmonkey.db
rm $DB_FILE
sqlite3 $DB_FILE < sql/schema/schema.sqlite.sql 
sqlite3 $DB_FILE < sql/data/default_data.sql 
sqlite3 $DB_FILE < sql/data/sample_data.sql 
sqlite3 $DB_FILE < sql/data/test_data.sql 
chmod 777 $DB_FILE
