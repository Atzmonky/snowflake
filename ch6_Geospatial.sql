// Environment
USE WAREHOUSE compute_wh;
USE DATABASE atzmon_db;
USE SCHEMA challenges;

// Creating a FILE FORMAT
CREATE OR REPLACE FILE FORMAT ch6_csv_ff
TYPE = 'CSV'
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

// Staging
CREATE OR REPLACE STAGE ch6_stage
FILE_FORMAT = ch6_csv_ff
URL = 's3://frostyfridaychallenges/challenge_6/';

// Creating Nations/Regions table
CREATE OR REPLACE TABLE nations_regions as (
  SELECT
    a.$1::VARCHAR as nation,
    a.$2::VARCHAR as type,
    a.$3::VARCHAR as sequence_num,
    a.$4::FLOAT as longitude,
    a.$5::FLOAT as latitude,
    a.$6::VARCHAR as part
  FROM @ch6_stage/nations_and_regions.csv (file_format => ch6_csv_ff) a
);

// Creating Empty table
CREATE OR REPLACE TABLE west_constituency_pts (
  constituency VARCHAR,
  sequence_num NUMBER,
  longitude FLOAT,
  latitude FLOAT,
  part VARCHAR
  );

// Copying records
COPY INTO west_constituency_pts
FROM @ch6_stage/westminster_constituency_points.csv
  file_format = 'ch6_csv_ff',
  PURGE = FALSE;
  
  // Set the output format back to WKT
ALTER SESSION SET geography_output_format = 'WKT';

// REGIONS DATA
// Construct a GEOGRAPHY object that represent a point with the specified 
// longitude and latitude
CREATE OR REPLACE TABLE nations_regions_pols AS (
WITH pts AS (
  SELECT nation, type, sequence_num, longitude, latitude, part,
    ST_MAKEPOINT(longitude, latitude) as geo_pts
  FROM nations_regions
),

// Construct the FIRST point GEOGRAPHY object
pts_0 AS (
    SELECT nation, type, sequence_num, longitude, latitude, part, 
        ST_MAKEPOINT(longitude, latitude) as geo_pts_0
    FROM nations_regions
    WHERE sequence_num = 0
    ),

// collecting all points
collect_pts AS (
    SELECT nation, type, part, 
        ARRAY_AGG(sequence_num) as seq,
        ST_COLLECT(geo_pts) as collection_pts
    FROM pts
    WHERE sequence_num != 0
    GROUP BY nation, type, part
    ),

// Joining start/End point and rest of the points in a table 
lines_tbl AS (
    SELECT cp.nation, cp.type, cp.part, 
        cp.seq, cp.collection_pts,
        pz.geo_pts_0
    FROM collect_pts cp
    LEFT JOIN pts_0 pz ON cp.nation = pz.nation
        AND cp.type = pz.type
        AND cp.part = pz.part 
    ),


// Construct a GEOGRAPHY object that represents a line 
// connecting the points in the input objects
lines AS (
    SELECT nation, type, part, seq,
        ST_MAKELINE(geo_pts_0, collection_pts) as geo_lines
    FROM lines_tbl
    ),

// Constructs a GEOGRAPHY object that represents a polygon without holes.
// Function uses the specified LineString as the outer loop
pols AS (
SELECT nation, type, part, seq, 
    ST_MAKEPOLYGON(geo_lines) as part_pols
FROM lines
    )

// Finally, getting what we need
SELECT nation, type, ST_COLLECT(part_pols) as all_pols
FROM pols
GROUP BY nation, type
    );
    
// WESTMINSTER SEATS DATA
CREATE OR REPLACE TABLE west_const_pols AS (
WITH pts AS (
    SELECT constituency, sequence_num, longitude, latitude, part,
      ST_MAKEPOINT(longitude, latitude) as geo_pts
    FROM west_constituency_pts
),

// Constructing the FIRST point GEOGRAPHY object
pts_0 AS (
    SELECT constituency, sequence_num, longitude, latitude, part, 
      ST_MAKEPOINT(longitude, latitude) as geo_pts_0
    FROM west_constituency_pts
    WHERE sequence_num = 0
    ),

// collecting all points
collect_pts AS (
    SELECT constituency, part, 
        ARRAY_AGG(sequence_num) as seq,
        ST_COLLECT(geo_pts) as collection_pts
    FROM pts
    WHERE sequence_num != 0
    GROUP BY constituency, part
    ),
  
// Joining start/End point and rest of the points in a table 
lines_tbl AS (
    SELECT cp.constituency, cp.part, 
        cp.seq, cp.collection_pts,
        pz.geo_pts_0
    FROM collect_pts cp
    LEFT JOIN pts_0 pz ON cp.constituency = pz.constituency
        AND cp.part = pz.part 
    ),
 
// Construct a GEOGRAPHY object that represents a line 
// connecting the points in the input objects   
lines AS (
    SELECT constituency, part, seq,
        ST_MAKELINE(geo_pts_0, collection_pts) as geo_lines
    FROM lines_tbl
    ),
 
// Constructs a GEOGRAPHY object that represents a polygon without holes.
// Function uses the specified LineString as the outer loop
pols AS (
SELECT constituency, part, seq, 
    ST_MAKEPOLYGON(geo_lines) as part_pols
FROM lines
    )

SELECT constituency, ST_COLLECT(part_pols) as all_pols
FROM pols
GROUP BY constituency
    );
    

// Final
CREATE OR REPLACE VIEW product AS
SELECT np.nation, COUNT(wp.constituency) as cnt_const
FROM nations_regions_pols np
LEFT JOIN west_const_pols wp ON ST_INTERSECTS(np.all_pols, wp.all_pols)
GROUP BY 1
ORDER BY 2 DESC;

// Checking the results
SELECT * FROM product; 
