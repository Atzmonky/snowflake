-- Start up Code
CREATE OR REPLACE TABLE week_14 (
    superhero_name varchar(50),
    country_of_residence varchar(50),
    notable_exploits varchar(180),
    superpower varchar(100),
    second_superpower varchar(100),
    third_superpower varchar(100)
);

INSERT INTO week_14 
    VALUES ('Superpig', 
            'Ireland', 
            'Saved head of Irish Farmer\'s Association from terrorist cell', 
            'Super-Oinks', NULL, NULL);
INSERT INTO week_14 
    VALUES ('Señor Mediocre', 
            'Mexico', 
            'Defeated corrupt convention of fruit lobbyists by telling anecdote that lasted 33 hours with 16 tangents that lead to 17 resignations from the board', 
            'Public speaking', 
            'Stamp collecting', 
            'Laser vision');
INSERT INTO week_14 
    VALUES ('The CLAW', 
            'USA', 
            'Horrifically violent duel to the death with mass murdering super villain accidentally created art                   installation last valued at $14,450,000 by Sotheby\'s', 
            'Back scratching', 
            'Extendable arms', 
            NULL);
INSERT INTO week_14 
    VALUES ('Il Segreto', 
            'Italy', 
            NULL, 
            NULL, 
            NULL, 
            NULL);
INSERT INTO week_14 
    VALUES ('Frosty Man', 
            'UK', 
            'Rescued a delegation of data engineers from a DevOps conference', 
            'Knows, by memory, 15 definitions of an obscure codex known as "the data mesh"', 
            'can copy and paste from StackOverflow with the blink of an eye', 
            NULL);
-- Checking the table            
select * from week_14;

-- Answer
with bas_tbl as (
select superhero_name,
    country_of_residence,
    to_array(superpower) as sp1, 
    to_array(second_superpower) as sp2,
    to_array(third_superpower) as sp3
from week_14
    ),
    
arrays as (
    select superhero_name,
        country_of_residence,
        array_cat(ifnull(sp1, array_construct()), ifnull(sp2, array_construct())) as sp12,
        sp3
    from bas_tbl
    ),

final_tbl as (
    select superhero_name,
        country_of_residence,
        array_cat(sp12, ifnull(sp3, array_construct())) as superpowers
    from arrays
    )
    
    select object_construct('superhero_name', superhero_name, 
                            'country_of_residence', country_of_residence, 
                            'superpowers', iff(ARRAY_SIZE(superpowers) > 0, superpowers, array_construct('Undefined'))
                            )
    from final_tbl;
