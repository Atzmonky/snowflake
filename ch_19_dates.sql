alter session set week_of_year_policy = 1;

--A few checks
select datediff(day, '2000-01-01', '2000-01-06');

select dateadd(day, seq4(), '2000-01-01')::DATE as date_seq
from table(generator(rowcount => 365 * 23) );
    
select TIMEADD('day', row_number() over (order by 1), '2020-01-01')::date as date_seq 
from table(GENERATOR(ROWCOUNT => 10));

-- Let's start!
-- Creating a dates scaffold table
create or replace transient table ch19_tbl (
    date_seq DATE,
    date_yrs NUMBER,
    month_name VARCHAR,
    date_month NUMBER,
    month_full_name VARCHAR,
    date_day NUMBER,
    day_part NUMBER,
    week_of_year NUMBER,
    day_of_year NUMBER
    )
    as 
with skeleton as (
    SELECT
        dateadd(day, seq4(), '2000-01-01')::DATE as date_seq
    FROM TABLE(generator(rowcount => 365 * 23) )
    )
select date_seq,
    extract(year from date_seq) as date_yrs,
    monthname(date_seq) as month_name,
    extract(month from date_seq) as date_month,
    to_char(date_seq, 'MMMM') as month_full_name,
    extract(day from date_seq) as date_day,
    dayofweek(date_seq) as day_part,
    weekofyear(date_seq) as week_of_year,
    dayofyear(date_seq) as day_of_year
from skeleton;

select * from ch19_tbl;

-- Creating UDF(SQL)
create or replace function calc_business_days(
    start_date DATE, 
    end_date DATE,
    bool BOOLEAN)
    returns NUMBER
    as
    $$
    select count(*)           
    from ch19_tbl
    where day_part not in (6,0)
     and date_seq between start_date and (end_date + bool::NUMBER)
   
    $$;
    
-- Creating our test data   
create or replace transient table testing_data (
    id INT,
    start_date DATE,
    end_date DATE
    );
insert into testing_data (id, start_date, end_date) values (1, '11/11/2020', '9/3/2022');
insert into testing_data (id, start_date, end_date) values (2, '12/8/2020', '1/19/2022');
insert into testing_data (id, start_date, end_date) values (3, '12/24/2020', '1/15/2022');
insert into testing_data (id, start_date, end_date) values (4, '12/5/2020', '3/3/2022');
insert into testing_data (id, start_date, end_date) values (5, '12/24/2020', '6/20/2022');
insert into testing_data (id, start_date, end_date) values (6, '12/24/2020', '5/19/2022');
insert into testing_data (id, start_date, end_date) values (7, '12/31/2020', '5/6/2022');
insert into testing_data (id, start_date, end_date) values (8, '12/4/2020', '9/16/2022');
insert into testing_data (id, start_date, end_date) values (9, '11/27/2020', '4/14/2022');
insert into testing_data (id, start_date, end_date) values (10, '11/20/2020', '1/18/2022');
insert into testing_data (id, start_date, end_date) values (11, '12/1/2020', '3/31/2022');
insert into testing_data (id, start_date, end_date) values (12, '11/30/2020', '7/5/2022');
insert into testing_data (id, start_date, end_date) values (13, '11/28/2020', '6/19/2022');
insert into testing_data (id, start_date, end_date) values (14, '12/21/2020', '9/7/2022');
insert into testing_data (id, start_date, end_date) values (15, '12/13/2020', '8/15/2022');
insert into testing_data (id, start_date, end_date) values (16, '11/4/2020', '3/22/2022');
insert into testing_data (id, start_date, end_date) values (17, '12/24/2020', '8/29/2022');
insert into testing_data (id, start_date, end_date) values (18, '11/29/2020', '10/13/2022');
insert into testing_data (id, start_date, end_date) values (19, '12/10/2020', '7/31/2022');
insert into testing_data (id, start_date, end_date) values (20, '11/1/2020', '10/23/2021');
    
select * from testing_data;

-- A quick check
select calc_business_days('2000-01-01', '2000-01-06', true);

-- Let's check it with the testing data
select start_date, end_date,
    calc_business_days(start_date, end_date, true) as include,
    calc_business_days(start_date, end_date, false) as exclude
from testing_data;
