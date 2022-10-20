// Creating a Database
CREATE OR REPLACE DATABASE atzmon_db;

// Creating a Warehouse
CREATE WAREHOUSE snowflake_wh
WITH
  WAREHOUSE_SIZE = XSMALL
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = 300
  STATEMENT_TIMEOUT_IN_SECONDS = 600;

// Environment Configuration
USE WAREHOUSE snowflake_wh;
USE DATABASE atzmon_db;
USE SCHEMA public;

// Creating a CSV file format
CREATE OR REPLACE FILE FORMAT ch8_csv
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1;
  
// Creating a Stage
CREATE OR REPLACE STAGE ch8_stg
  file_format = ch8_csv
  url = 's3://frostyfridaychallenges/challenge_8/payments.csv';

// List objects in stage
LIST @ch8_stg;

// Checking the CSV in stage
SELECT $1,$2, $3, $4
FROM @ch8_stg (file_format => ch8_csv);

// Creating a table and table schema  
CREATE OR REPLACE TABLE ch8_tbl(
    id VARCHAR,
    payment_date VARCHAR,
    card VARCHAR,
    amount NUMBER
    );
  
// Copy data to newly created table  
COPY INTO ch8_tbl 
FROM @ch8_stg;

SELECT * FROM ch8_tbl;
