// Environment Configuration
USE WAREHOUSE COMPUTE_WH;
USE DATABASE ATZMON_DB;
USE SCHEMA challenges;

// Create JSON file format
CREATE OR REPLACE FILE FORMAT ch4_json_ff
  type = 'json'
  strip_outer_array = TRUE;
  
  // Create a stage
CREATE OR REPLACE STAGE ch4_stg
file_format = 'ch4_json_ff'
url = 's3://frostyfridaychallenges/challenge_4/';

// And list files in the stage
LIST @ch4_stg;

// View Json in stage
SELECT $1 as col1
FROM @ch4_stg (pattern => '.*Spanish_Monarchs.json');

// Viewing first level key in Json
SELECT a.$1:Era::VARCHAR as era
FROM @ch4_stg (pattern => '.*Spanish_Monarchs.json') a

// Viewing first and second level keys in Json
SELECT a.$1:Era::VARCHAR as era,
    h.value:House::VARCHAR as house
FROM @ch4_stg (pattern => '.*Spanish_Monarchs.json') a,
    LATERAL FLATTEN(input => a.$1:Houses) h;
    
// Viewing all needed keys in Json 
SELECT a.$1:Era::VARCHAR as era,
    h.value:House::VARCHAR as house,
    m.value['Age at Time of Death']::VARCHAR as age_at_time_of_death,
    m.value['Birth']::DATE as birth,
    m.value['Burial Place']::VARCHAR as burial_place,
    m.value['Consort\\/Queen Consort'][0]::VARCHAR as queen_consort1,
    m.value['Consort\\/Queen Consort'][1]::VARCHAR as queen_consort2,
    m.value['Consort\\/Queen Consort'][2]::VARCHAR as queen_consort3,
    m.value['Death']::DATE as death,
    m.value['Duration']::VARCHAR as duration,
    m.value['End of Reign']::DATE as end_of_reign,
    m.value['Name']::VARCHAR as name,
    m.value['Nickname'][0]::VARCHAR as nickname1,
    m.value['Nickname'][1]::VARCHAR as nickname2,
    m.value['Nickname'][2]::VARCHAR as nickname3,
    m.value['Place of Birth']::VARCHAR as place_of_birth,
    m.value['Place of Death']::VARCHAR as place_of_death,
    m.value['Start of Reign']::VARCHAR as start_of_reign
FROM @ch4_stg (pattern => '.*Spanish_Monarchs.json') a,
    LATERAL FLATTEN(input => a.$1:Houses) h,
    LATERAL FLATTEN(input => h.value:Monarchs) m;
    
FINAL:

// Extracting values from Json using LATERAL FLATTEN
// and creating a flat table
CREATE OR REPLACE TABLE ch4_flat_tbl as
  (        
SELECT 
    ROW_NUMBER() OVER(ORDER BY m.value['Birth']::DATE) as birth_idx,
    m.index+1 as raw_idx, 
    a.$1:Era::VARCHAR as era,
    h.value:House::VARCHAR as house,
    m.value['Age at Time of Death']::VARCHAR as age_at_time_of_death,
    m.value['Birth']::DATE as birth,
    m.value['Burial Place']::VARCHAR as burial_place,
    m.value['Consort\\/Queen Consort'][0]::VARCHAR as queen_consort1,
    m.value['Consort\\/Queen Consort'][1]::VARCHAR as queen_consort2,
    m.value['Consort\\/Queen Consort'][2]::VARCHAR as queen_consort3,
    m.value['Death']::DATE as death,
    m.value['Duration']::VARCHAR as duration,
    m.value['End of Reign']::DATE as end_of_reign,
    m.value['Name']::VARCHAR as name,
    m.value['Nickname'][0]::VARCHAR as nickname1,
    m.value['Nickname'][1]::VARCHAR as nickname2,
    m.value['Nickname'][2]::VARCHAR as nickname3,
    m.value['Place of Birth']::VARCHAR as place_of_birth,
    m.value['Place of Death']::VARCHAR as place_of_death,
    m.value['Start of Reign']::VARCHAR as start_of_reign
FROM @ch4_stg (pattern => '.*Spanish_Monarchs.json') a,
    LATERAL FLATTEN(input => a.$1:Houses) h,
    LATERAL FLATTEN(input => h.value:Monarchs) m
  );
  
  
