// Environment
USE WAREHOUSE snowflake_wh;
USE DATABASE atzmon_db;
USE SCHEMA public;

// Create data
CREATE OR REPLACE TABLE data_to_be_masked(first_name varchar, last_name varchar,hero_name varchar);
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) 
    VALUES ('Eveleen', 'Danzelman','The Quiet Antman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) 
    VALUES ('Harlie', 'Filipowicz','The Yellow Vulture');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) 
    VALUES ('Mozes', 'McWhin','The Broken Shaman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) 
    VALUES ('Horatio', 'Hamshere','The Quiet Charmer');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) 
    VALUES ('Julianna', 'Pellington','Professor Ancient Spectacle');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) 
    VALUES ('Grenville', 'Southouse','Fire Wonder');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) 
    VALUES ('Analise', 'Beards','Purple Fighter');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) 
    VALUES ('Darnell', 'Bims','Mister Majestic Mothman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) 
    VALUES ('Micky', 'Shillan','Switcher');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) 
    VALUES ('Ware', 'Ledstone','Optimo');
    
SELECT * FROM data_to_be_masked;

// Creating roles foo1 and foo2
CREATE ROLE foo1;
CREATE ROLE foo2;

GRANT ROLE foo1 TO USER atzmonky;
GRANT ROLE foo2 TO USER atzmonky;

SHOW ROLES;

// Grant operate, usage and select privileges to role foo1
GRANT USAGE ON WAREHOUSE snowflake_wh TO ROLE foo1;
GRANT USAGE ON DATABASE atzmon_db TO ROLE foo1;
GRANT USAGE ON SCHEMA atzmon_db.public TO ROLE foo1;
GRANT SELECT ON ALL TABLES in SCHEMA public TO ROLE foo1;

// Grant operate, usage and select privileges to role foo2
USE ROLE ACCOUNTADMIN;
GRANT USAGE ON WAREHOUSE snowflake_wh TO ROLE foo2;
GRANT USAGE ON DATABASE atzmon_db TO ROLE foo2;
GRANT USAGE ON SCHEMA atzmon_db.public TO ROLE foo2;
GRANT SELECT ON ALL TABLES in SCHEMA public TO ROLE foo2;

// Creating TAG (sec_class) 
CREATE TAG sec_class;

// Associate TAG and assigning a value to columns in TABLE (data_to_be_masked)
ALTER TABLE data_to_be_masked MODIFY COLUMN first_name SET TAG sec_class = 'low';
ALTER TABLE data_to_be_masked MODIFY COLUMN last_name SET TAG sec_class = 'high';

// Checking TAGS and related info
SHOW TAGS in SCHEMA public;
SELECT * FROM TABLE (
    atzmon_db.information_schema.TAG_REFERENCES_ALL_COLUMNS(
        'data_to_be_masked', 'table')
    );

// Creating MASKING POLICY mask_sec_class based on tags values and roles
USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE MASKING POLICY mask_sec_class as (val STRING)
    RETURNS STRING ->
    CASE
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('sec_class') = 'high'
        AND current_role() = 'FOO1' THEN val
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('sec_class') = 'low'
        AND (current_role() = 'FOO1' OR current_role() = 'FOO2') THEN val
      ELSE '***MASKED***'
    END;


// Assigning
USE ROLE ACCOUNTADMIN;
ALTER TAG sec_class SET MASKING POLICY mask_sec_class;

// Checking existing policies
USE ROLE ACCOUNTADMIN;
SELECT *
FROM TABLE (
    snowflake.information_schema.policy_references(
        ref_entity_domain => 'TABLE',
        ref_entity_name => 'data_to_be_masked')
    );

// Checking ACCOUNTADMIN 
USE ROLE ACCOUNTADMIN;
SELECT * FROM data_to_be_masked;

// Checking FOO1
USE ROLE foo1;
USE WAREHOUSE snowflake_wh;
USE DATABASE atzmon_db;
SELECT * FROM data_to_be_masked;
    
// Checking FOO1
USE ROLE foo1;
USE WAREHOUSE snowflake_wh;
USE DATABASE atzmon_db;
SELECT * FROM data_to_be_masked;
