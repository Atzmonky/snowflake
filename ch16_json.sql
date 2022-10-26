-- Env configuration
use database ATZMON_DB;
use warehouse SNOWFLAKE_WH;
use schema PUBLIC

-- File Format
create or replace file format json_ff
    type = json
    strip_outer_array = TRUE;
    
-- Stage    
create or replace stage week_16_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_16/'
    file_format = json_ff;

-- Table
create or replace table public.week16 as
    select t.$1:word::text word, 
        t.$1:url::text url, 
        t.$1:definition::variant definition  
from @week_16_frosty_stage (file_format => 'json_ff', pattern=>'.*week16.*') t;

-- Check table
select * from week16;

-- Creating a view for requested table
create or replace view w16_view 
as
select w.word, w.url, 
    w2.value:partOfSpeech::VARCHAR as part_of_speech,
    w2.value:synonyms::VARIANT as general_synonyms,
    w2.value:antonyms::VARIANT as general_antonyms,
    w3.value:definition::VARCHAR as definition,
    w3.value:example::VARCHAR as example_if_applicable,
    w3.value:synonyms::VARCHAR as definitional_synonyms,
    w3.value:antonyms::VARCHAR as definitional_antonyms    
from week16 w,
    lateral flatten(input => w.definition) w1,
    lateral flatten(input => w1.value:meanings) w2,
    lateral flatten(input => w2.value:definitions) w3
;
-- Checking counts 
select count(word) as cnt, 
    count(DISTINCT word) as cnt_dist
from w16_view
