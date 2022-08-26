// Environment Configuration
USE WAREHOUSE COMPUTE_WH;
USE DATABASE ATZMON_DB;
USE SCHEMA challenges;

// Creating a CSV file format
CREATE OR REPLACE FILE FORMAT ch3_csvformat
    type = 'CSV'
    field_delimiter = ','
    skip_header = 1;

// Creating a Stage Object to reference data files stored in a s3 bucket
CREATE OR REPLACE STAGE ch3_stage
    file_format = ch3_csvformat
    url = 's3://frostyfridaychallenges/challenge_3/';
    
// View files in stage
LIST @ch3_stage;

// Checking the file
SELECT
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    $1,
    $2,
    $3
FROM @ch3_stage/keywords (file_format => 'ch3_csvformat');

// Creating an empty table 'ch3_keywords_tbl'
CREATE OR REPLACE TABLE ch3_keywords_tbl (keyword VARCHAR, added_by VARCHAR);

// Load data into the keywords table
COPY INTO ch3_keywords_tbl
FROM 
    (
     SELECT $1, $2 
     FROM @ch3_stage/keywords (file_format => 'ch3_csvformat')
    );

// Checking the newly created table with 3 records
SELECT * FROM ch3_keywords_tbl;

// Query the stage for all distinct files containing the requested keywords
SELECT DISTINCT(METADATA$FILENAME::STRING) as FILE_NAME
FROM @ch3_stage (file_format => 'ch3_csvformat')
WHERE
    CONTAINS(METADATA$FILENAME::STRING, 'week3')
    AND METADATA$FILENAME::STRING LIKE ANY (SELECT CONCAT('%', keyword, '%')
        FROM ch3_keywords_tbl);
        
