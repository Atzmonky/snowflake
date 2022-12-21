use ATZMON_DB;
use schema CHALLENGES;
create or replace table data_batch_1(
                                                                 id STRING,
                                                                 first_name STRING,
                                                                 last_name STRING,
                                                                 email2 STRING,
                                                                 gender STRING,
                                                                 email STRING
                                                                 );
put file:///Users/atzmonky/Downloads/splitcsv-c18c2b43-ca57-4e6e-8d95
                                                               -f2a689335892-results/data_batch_1*.csv @atzmon_db.challenges.%data_b
                                                               atch_1;
list @atzmon_db.challenges.%data_batch_1;
select * from DATA_BATCH_1;
copy into DATA_BATCH_1
                                                               from @%data_batch_1
                                                               file_format = (type=csv field_optionally_enclosed_by='"' skip_header=
                                                               1)
                                                               pattern='.*data_batch_1.*[.]csv.gz'
                                                               on_error='skip_file';
