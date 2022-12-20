-- Creating roles
use role ACCOUNTADMIN;
create or replace role frosty_role_one;
create or replace role frosty_role_two;
create or replace role frosty_role_three;

-- Creating schema and table
use role SYSADMIN;
create or replace schema cold_lonely_schema;
create or replace table cold_lonely_schema.table_one (key int, value varchar);

-- Assign grants on schema to all roles
grant all on schema cold_lonely_schema to frosty_role_one;
grant all on schema cold_lonely_schema to frosty_role_two;
grant all on schema cold_lonely_schema to frosty_role_three;

-- Assign grants on table to all roles
grant all on table cold_lonely_schema.table_one to frosty_role_one;
grant all on table cold_lonely_schema.table_one to frosty_role_two;
grant all on table cold_lonely_schema.table_one to frosty_role_three;

-- Procedure to clone schema and copy all grants for the schema
create or replace procedure schema_clone_with_copy_grants(
    database_name VARCHAR, 
    schema_name VARCHAR,
    target_database VARCHAR,
    cloned_schema_name VARCHAR,
    at_or_before_statement VARCHAR
    )
returns table()
language SQL
execute as caller
as
--declare

begin
    execute immediate 'use database ' || database_name;
    execute immediate 'create or replace schema ' || target_database || '.' || cloned_schema_name || ' clone ' || 
                                    database_name || '.' || schema_name || coalesce(' ' || at_or_before_statement,'');
    execute immediate 'show grants on schema ' || database_name || '.' || schema_name;
    
    let src_gts resultset := (select "privilege" as privilege,
                                "granted_on" as granted_on,
                                "grantee_name" as grantee_name
                              from table(result_scan(last_query_id()))
                                );
    let cur cursor for src_gts;
    for i in cur do
        execute immediate 'GRANT ' || i.privilege || ' ON ' || i.granted_on || ' ' || cloned_schema_name || ' TO ROLE ' || i.grantee_name;
    end for;
    return table(src_gts);
end;

 
    

call schema_clone_with_copy_grants('atzmon_db', 
                               'cold_lonely_schema',
                                   'atzmon_db',
                               'cold_lonely_schema_cloned',
                                   NULL);
