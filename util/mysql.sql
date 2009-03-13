DROP DATABASE rackmonkey;
CREATE DATABASE rackmonkey;
USE rackmonkey;
\. /Users/flux/Sites/trunk/sql/schema/schema.mysql.sql
\. /Users/flux/Sites/trunk/sql/data/default_data.sql
\. /Users/flux/Sites/trunk/sql/data/sample_data.sql
\. /Users/flux/Sites/trunk/sql/data/test_data.sql
GRANT ALL ON rackmonkey.* TO 'rackmonkey'@'localhost' IDENTIFIED BY '7jhH#98*';
GRANT ALL ON rackmonkey.* TO 'rackmonkey'@'%' IDENTIFIED BY '7jhH#98*';
FLUSH PRIVILEGES;
