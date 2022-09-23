// Environment Configuration
USE WAREHOUSE compute_wh;
USE DATABASE atzmon_db;
USE SCHEMA challenges;

// Creating a table with one column 'numbers'
// with a data type of NUMBER
CREATE OR REPLACE TABLE ch5_sample_tbl (numbers NUMBER);

// Inserting values to the 'numbers' column
INSERT INTO ch5_sample_tbl
VALUES (1), (2), (3), (4), (5)

// Creating a Python UDF
// Create a Python function of multiplying an integer*3
CREATE OR REPLACE FUNCTION multi_3(input INT)
RETURNS INT NOT NULL
language python
runtime_version = '3.8'    // <python_version>
handler = 'multi_3_py'     // '<function_name>'
AS
$$
def multi_3_py(input: int):
return input*3
$$;

// Calling and Validating our Python UDF with ch5_sample_tbl
SELECT
    numbers,
    numbers*3 as validation,
    multi_3(numbers) as python_udf
FROM ch5_sample_tbl;
