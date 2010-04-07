dropdb rackmonkey-trunk
createdb -O rackmonkey-trunk rackmonkey-trunk
psql -U rackmonkey-trunk rackmonkey-trunk < sql/schema/schema.postgres.sql 
psql -U rackmonkey-trunk rackmonkey-trunk < sql/data/default_data.sql 
psql -U rackmonkey-trunk rackmonkey-trunk < sql/data/sample_data.sql 
psql -U rackmonkey-trunk rackmonkey-trunk < sql/data/test_data.sql
