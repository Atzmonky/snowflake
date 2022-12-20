use database atzmon_db;
use schema challenges;


-- Creating hero_powers table
create or replace table hero_powers (
    hero_name VARCHAR(50),
    flight VARCHAR(50),
    laser_eyes VARCHAR(50),
    invisibility VARCHAR(50),
    invincibility VARCHAR(50),
    psychic VARCHAR(50),
    magic VARCHAR(50),
    super_speed VARCHAR(50),
    super_strength VARCHAR(50)
    );
    
-- Populating the table
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) 
    values ('The Impossible Guard', '++', '-', '-', '-', '-', '-', '-', '+');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) 
    values ('The Clever Daggers', '-', '+', '-', '-', '-', '-', '-', '++');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) 
    values ('The Quick Jackal', '+', '-', '++', '-', '-', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) 
    values ('The Steel Spy', '-', '++', '-', '-', '+', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) 
    values ('Agent Thundering Sage', '++', '+', '-', '-', '-', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) 
    values ('Mister Unarmed Genius', '-', '-', '-', '-', '-', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) 
    values ('Doctor Galactic Spectacle', '-', '-', '-', '++', '-', '-', '-', '+');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) 
    values ('Master Rapid Illusionist', '-', '-', '-', '-', '++', '-', '+', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) 
    values ('Galactic Gargoyle', '+', '-', '-', '-', '-', '-', '++', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) 
    values ('Alley Cat', '-', '++', '-', '-', '-', '-', '-', '+');
    
-- Check table   
select * from hero_powers;

-- unpivot and pivot
with unpivoted as (
    select * 
    from hero_powers
        unpivot(value for key in (FLIGHT, 
                                  LASER_EYES, 
                                  INVISIBILITY, 
                                  INVINCIBILITY, 
                                  PSYCHIC, 
                                  MAGIC, 
                                  SUPER_SPEED, 
                                  SUPER_STRENGTH)
               )
        )
    
select *
from unpivoted
    pivot(max(key) for value in ('++', '+')) as p(hero_name, main, secondary)
where main is not null
    or secondary is not null
;
