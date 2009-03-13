dropdb rackmonkey
createdb -O rackmonkey rackmonkey
psql -U rackmonkey rackmonkey < sql/schema/schema.postgres.sql 
psql -U rackmonkey rackmonkey < sql/data/default_data.sql 
psql -U rackmonkey rackmonkey < sql/data/sample_data.sql 
psql -U rackmonkey rackmonkey < sql/data/test_data.sql