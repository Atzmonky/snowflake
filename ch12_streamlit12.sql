create schema atzmon_db.world_bank_metadata;

create or replace table atzmon_db.world_bank_metadata.country_metadata
(
    country_code varchar(3),
    region string,
    income_group string
);

create schema atzmon_db.world_bank_economic_indicators;

create or replace table atzmon_db.world_bank_economic_indicators.gdp
(
    country_name string,
    country_code varchar(3),
    year int,
    gdp_usd double
);

create table atzmon_db.world_bank_economic_indicators.gov_expenditure
(
    country_name string,
    country_code varchar(3),
    year int,
    gov_expenditure_pct_gdp double
);

create schema atzmon_db.world_bank_social_indiactors;

create or replace table atzmon_db.world_bank_social_indiactors.life_expectancy
(
    country_name string,
    country_code varchar(3),
    year int,
    life_expectancy float
);

create or replace table atzmon_db.world_bank_social_indiactors.adult_literacy_rate
(
    country_name string,
    country_code varchar(3),
    year int,
    adult_literacy_rate float
);

create or replace table atzmon_db.world_bank_social_indiactors.progression_to_secondary_school
(
    country_name string,
    country_code varchar(3),
    year int,
    progression_to_secondary_school float
);


SELECT * 
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA 
WHERE schema_name != 'PUBLIC';

SELECT table_name 
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES 
WHERE table_schema = 'WORLD_BANK_SOCIAL_INDIACTORS';
