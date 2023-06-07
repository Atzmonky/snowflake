from datetime import date
import snowflake.snowpark
from snowflake.snowpark.session import Session
from snowflake.snowpark.types import *
from snowflake.snowpark.functions import udf
from snowflake.snowpark.functions import col
from snowflake.snowpark.functions import call_udf

from configs import conn_params

# Creating Snowpark Session
def snowpark_session():  
    session = Session.builder.configs(conn_params).create()
    session.sql_simplifier_enabled = True
    return session

# Using function to create a session
session = snowpark_session()

session.use_database('atzmon_db')
session.use_schema('challenges')
udf_stage = 'udf_stage'

# Create Snowflake udf_stage
session.sql(f"create or replace stage {udf_stage} DIRECTORY = (ENABLE = TRUE);").collect()

# Fiscal year Function
def calc_fiscal_year(start_date: date):
    start_month = start_date.month

    if start_month >= 5:
        fiscal_year = start_date.year +1
    else:
        fiscal_year = start_date.year
        
    return fiscal_year
  
# Register UDF from a file to Snowflake
session.udf.register(
    func=calc_fiscal_year,
    return_type = IntegerType(),
    input_types = [DateType()],
    name = 'calc_fiscal_year',
    replace = True,
    stage_location = '@UDF_STAGE',
    is_permanent=True
)

data = session.table('ch29_tbl').select(
    col("id"),
    col("first_name"),
    col("surname"),
    col("email"),
    col("start_date"),
    call_udf('calc_fiscal_year', col('start_date')).alias('fiscal_year')
)

data.show()

data.group_by("fiscal_year").agg(col("*"), "count").show()




