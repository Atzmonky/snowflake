// Creating a CSV file format
CREATE OR REPLACE file format ch1_csvformat
    type = 'CSV'
    field_delimiter = ','
    skip_header = 1;
  
// Creating a Stage Object to 
// reference data files stored in a s3 bucket
CREATE OR REPLACE stage ch1_csv_stage
    file_format = ch1_csvformat
    url = 's3://frostyfridaychallenges/challenge_1';
    
// Checking the CSV in stage
select $1,$2
from @ch1_csv_stage(file_format => ch1_csvformat);


// Creating a table in the database with schema
CREATE OR REPLACE TABLE "ATZMON_DB"."PUBLIC"."CH1_CSV_TABLE" 
    ("C1" STRING);

// Loading the CSV data into a table within the DB
COPY INTO "ATZMON_DB"."PUBLIC"."CH1_CSV_TABLE"
    FROM @ch1_csv_stage;
    
// Checking table 
select * from "ATZMON_DB"."PUBLIC"."CH1_CSV_TABLE"
