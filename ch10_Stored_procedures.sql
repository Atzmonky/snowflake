// Environment
USE WAREHOUSE snowflake_wh;
USE DATABASE atzmon_db;
USE SCHEMA public;


// Create the warehouses
create warehouse if not exists my_xsmall_wh 
    with 
    warehouse_size = XSMALL
    auto_suspend = 120;
    
create warehouse if not exists my_small_wh 
    with 
    warehouse_size = SMALL
    auto_suspend = 120;

// Create the table
create or replace table ch10_tbl
(
    date_time DATETIME,
    trans_amount DOUBLE
);

// Create file format
create or replace file format ch10_csv_ff
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1;

// Create the stage
create or replace stage ch10_stg
    url = 's3://frostyfridaychallenges/challenge_10/'
    file_format = ch10_csv_ff;

show stages like $$ ch10_stg $$;
list @ch10_stg;
SELECT "name", split_part("name", '/', -1), "size" FROM TABLE(result_scan(last_query_id()));
desc stage ch10_stg;
select 
    METADATA$FILENAME::STRING as FILE_NAME
  , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
  , $1::VARIANT as CONTENTS
from @ch10_stg/challenge_10/2022-07-01.csv;

// Create the stored procedure
create or replace procedure dynamic_warehouse_data_load(
      stage_name STRING,
      table_name STRING  
        )
  returns STRING
  language SQL
  execute as caller
  as
    declare
      tbl_records NUMBER :=0;
    begin
      execute immediate 'ls @' || stage_name;
      let stg_rec resultset := (select "name" as name, "size" as size 
                                from table(result_scan(last_query_id())) 
                                );
      // Using a cursor and Checking file size                          
      let cur cursor for stg_rec;
      for i in cur do
        if (i.size < 10000) then
            execute immediate 'use warehouse my_xsmall_wh';
        else
            execute immediate 'use warehouse my_small_wh';
        end if;
      
      --for i in cur do
        
        // Checking file size (i) 
        --if i > 10000 then execute immediate 'USE WAREHOUSE my_small_wh'
        --else execute immediate 'USE WAREHOUSE my_xsmall_wh'
        --end if;
        //
         execute immediate 'copy into ' || table_name || 
                           ' from @' || stage_name || 
                           ' files = (''' || split_part(i.name, '/', -1) || ''')';
      end for;
      
      select count(*) into :tbl_records from identifier(:table_name);
      return tbl_records;
      
    end;

// Call the stored procedure.
call dynamic_warehouse_data_load('ch10_stg', 'ch10_tbl');
select * from ch10_tbl;


// Create the stored procedure
create or replace procedure 
  dynamic_warehouse_data_load(
      stage_name STRING,
      table_name STRING  
        )
  returns STRING
  language PYTHON
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python', 'pandas') 
  handler = 'run'
  execute as caller
as
$$
import pandas as pd

def run(session, stage_name, table_name):
  stg = session.sql(
                    'list@' + stage_name
                    ).collect()
  stg_list = [{'name': row.as_dict()['name'], 
               'size': row.as_dict()['size']} for row in stg]
  for i in stg_list:
    if i[0]['size'] > 10000:
      compute_wh = 'my_small_wh'
    else:
      compute_wh = 'my_xsmall_wh'
  return stg_list
$$;

// Call the stored procedure.
call dynamic_warehouse_data_load('ch10_stg');
select * from ch10_tbl;
