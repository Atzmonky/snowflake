-- Environment
use database atzmon_db;
use schema challenges;

-- File format to read the CSV
create or replace file format frosty22_csv
    type = csv
    field_delimiter = ','
    field_optionally_enclosed_by = '"'
    skip_header = 1;
    
-- Creates stage to read the CSV
create or replace stage w22_frosty_stage
  url = 's3://frostyfridaychallenges/challenge_22/'
  file_format = frosty22_csv;
  
-- Roles needed for challenge
use role securityadmin;
create role rep1;
create role rep2;

-- Grant roles to self for testing
grant role rep1 to user ATZMONBENBINYAMIN;
grant role rep2 to user ATZMONBENBINYAMIN;

-- Enable warehouse usage. Assumes that `public` has access to the warehouse
grant role public to role rep1;
grant role public to role rep2;

-- Create the table from the CSV in S3
use role sysadmin;
create or replace table atzmon_db.challenges.week22 as
select 
    t.$1::int id, 
    t.$2::varchar(50) city, 
    t.$3::int district 
from @w22_frosty_stage (pattern=>'.*sales_areas.*') t;

-- Checking table and checking mod(district, 2) behavior for mapping table  
select *, mod(id, 2) from atzmon_db.challenges.week22;

-- Code for creating a mapping table
create or replace table mapping22_tbl(
    role_name STRING, 
    kind INTEGER
    ); 
insert into mapping22_tbl(role_name, kind)
    values('rep1', 1);
insert into mapping22_tbl(role_name, kind)
    values('rep2', 0);

select * from mapping22_tbl;

-- Code for creating the secure view
create or replace secure view secure_cities as
    select 
        uuid_string() as id, -- UUID_STRING returns a 128-bit value, formatted as a string
        w22.city,
        w22.district
    from atzmon_db.challenges.week22 w22
    where mod(w22.id, 2) = (select kind 
                                  from mapping22_tbl
                                  where current_role() = upper(role_name)
                                    );

        

    
-- Roles need DB access
grant usage on database atzmon_db to role rep1;
grant usage on database atzmon_db to role rep2;
-- And schema access
grant usage on schema atzmon_db.challenges to role rep1;
grant usage on schema atzmon_db.challenges to role rep2;
-- And usage of view
grant select on view atzmon_db.challenges.secure_cities to role rep1;
grant select on view atzmon_db.challenges.secure_cities to role rep2;

-- Get the result of queries
use role rep1;
select * from atzmon_db.challenges.secure_cities;

use role rep2;
select * from atzmon_db.challenges.secure_cities;
