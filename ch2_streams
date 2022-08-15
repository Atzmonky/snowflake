// Environment Configuration
USE database ATZMON_DB;
USE warehouse COMPUTE_WH;

// Create schema
CREATE OR REPLACE schema Week2;
USE schema Week2;

// Creating a PARQUET file format
CREATE OR REPLACE file format ch2_parquet
    type = 'parquet';

// Create internal stage and load the parquet file
CREATE OR REPLACE stage ch2_parq_stg
    url='s3://frostyfridaychallenges/challenge_2';
// View files in stage
LIST @ch2_parq_stg;

// Using INFER_SCHEMA function to
// check the column definitions for Parquet files in ch2_parq_stg stage:
SELECT *
FROM TABLE (
    infer_schema(
        location =>'@ch2_parq_stg/',
        file_format =>'ch2_parquet')
            );
// Checking file contents
SELECT *
FROM @ch2_parq_stg (
    file_format => 'ch2_parquet',
    pattern => 'challenge_2/employees.parquet');
    
--- Get the Column name and their respective Data Type
SELECT generate_column_description(array_agg(object_construct(*)), 'table') as columns
  FROM TABLE (
    infer_schema(
      location=>'@ch2_parq_stg/',
      file_format=>'ch2_parquet'
    )
  );

// Create an empty table 'ch2_parquet_tbl' automatically using template 
// while using array_agg(object_construct(*)) and infer_schema() functions

CREATE OR REPLACE TABLE ch2_parquet_tbl USING template (
  SELECT array_agg(object_construct(*)) 
  FROM table (
    infer_schema(
      location=>'@ch2_parq_stg/',
      file_format=>'ch2_parquet')
   ));
   
// Loading the data into 'ch2_parquet_tbl' 
// To insure columns order mismatch we will use MATCH_BY_COLUMN_NAME argument
COPY INTO ch2_parquet_tbl 
FROM @ch2_parq_stg 
  file_format = 'ch2_parquet',
  ON_ERROR = 'ABORT_STATEMENT' 
  MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
  PURGE = FALSE; // Boolean that specifies whether to remove the data files from the stage automatically after the data is loaded successfully.

// Creating a view based on ch2_parquet_tbl with the requested columns
CREATE OR REPLACE VIEW ch2_parquet_view as 
 SELECT "employee_id",
    "job_title",
    "dept"
 FROM ch2_parquet_tbl;
 
// Creating a stream to record data changes made to a table
CREATE OR REPLACE STREAM ch2_parquet_stream ON view ch2_parquet_view;

// Execute the following commands:
UPDATE ch2_parquet_tbl SET "country" = 'Japan' WHERE "employee_id" = 8;
UPDATE ch2_parquet_tbl SET "last_name" = 'Forester' WHERE "employee_id" = 22;
UPDATE ch2_parquet_tbl SET "dept" = 'Marketing' WHERE "employee_id" = 25;
UPDATE ch2_parquet_tbl SET "title" = 'Ms' WHERE "employee_id" = 32;
UPDATE ch2_parquet_tbl SET "job_title" = 'Senior Financial Analyst' WHERE "employee_id" = 68;

// Checking the stream ch2_parquet_stream - View shows changes made on specific columns: dept, job_title
SELECT * FROM ch2_parquet_stream;
