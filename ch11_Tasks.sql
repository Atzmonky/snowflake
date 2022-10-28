-- Set the database and schema
use warehouse SNOWFLAKE_WH;
use database ATZMON_DB;
use schema PUBLIC;

// Create file format
create or replace file format ch11_csv_ff
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1;
  
-- Create the stage that points at the data.
create stage week_11_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_11/'
    file_format = ch11_csv_ff;

-- Create the table as a CTAS statement.
create or replace table atzmon_db.public.ch11_tbl
as
select m.$1 as milking_datetime,
       m.$2 as cow_number,
       m.$3 as fat_percentage,
       m.$4 as farm_code,
       m.$5 as centrifuge_start_time,
       m.$6 as centrifuge_end_time,
       m.$7 as centrifuge_kwph,
       m.$8 as centrifuge_electricity_used,
       m.$9 as centrifuge_processing_time,
       m.$10 as task_used
from @week_11_frosty_stage (file_format => 'ch11_csv_ff', 
                            pattern => '.*milk_data.*[.]csv') m;

select * from ch11_tbl;

-- TASK 1: Remove all the centrifuge dates and centrifuge kwph and replace them with NULLs WHERE fat = 3. 
-- Add note to task_used.
create or replace task whole_milk_updates
    warehouse = snowflake_wh
    schedule = '1400 minutes'
as
  update 
    ch11_tbl
  set 
    CENTRIFUGE_START_TIME = NULL,
    CENTRIFUGE_END_TIME = NULL,
    CENTRIFUGE_KWPH = NULL,
    TASK_USED = system$current_user_task_name()
  where 
    FAT_PERCENTAGE = '3'; 


-- TASK 2: Calculate centrifuge processing time (difference between start and end time) WHERE fat != 3. 
-- Add note to task_used.
create or replace task skim_milk_updates
    after atzmon_db.public.whole_milk_updates
as
  update 
    ch11_tbl
  set
    CENTRIFUGE_START_TIME = to_timestamp_ntz(CENTRIFUGE_START_TIME),
    CENTRIFUGE_END_TIME = to_timestamp_ntz(CENTRIFUGE_END_TIME),
    CENTRIFUGE_PROCESSING_TIME = datediff(minute, CENTRIFUGE_START_TIME, CENTRIFUGE_END_TIME),
    TASK_USED = system$current_user_task_name()
  where 
    FAT_PERCENTAGE != '3'; 


-- Manually execute the task.
execute task whole_milk_updates;
select system$task_dependents_enable('atzmon_db.public.whole_milk_updates');

-- A few checkups
select *
from table(information_schema.task_history())
order by scheduled_time;
  
show tasks;
describe task skim_milk_updates;

-- Check that the data looks as it should.
select * from ch11_tbl;

-- Check that the numbers are correct.
select task_used, count(*) as row_count from ch11_tbl group by task_used;

-- Resume/Suspend the root task
alter task whole_milk_updates resume;
