from configparser import ConfigParser
import streamlit as st
import pandas as pd
import snowflake.connector

# Reading the configuration file with 'configparser' package
config_sf = ConfigParser()
config_sf.sections()
config_sf.read('config_sf.ini')

# Assigning snowflake configuration (Environment)
sfAccount = config_sf['Snowflake']['sfAccount']
sfUser = config_sf['Snowflake']['sfUser']
sfPassword = config_sf['Snowflake']['sfPassword']
sfWarehouse = config_sf['Snowflake']['sfWarehouse']
sfDatabase = config_sf['Snowflake']['sfDatabase']
sfSchema = config_sf['Snowflake']['sfSchema']

# Connect to Snowflake using the configurations above
conn = snowflake.connector.connect(
    user=sfUser,
    password=sfPassword,
    account=sfAccount,
    warehouse=sfWarehouse,
    database=sfDatabase,
    schema=sfSchema
    )

# SQL query
query = """
    SELECT 
        DATE_TRUNC('WEEK', TO_DATE(PAYMENT_DATE)) as payment_date,
        SUM(amount) as amount_per_week
    FROM CH8_TBL
    GROUP BY 1;
    """

# This keeps a cache in place so the query isn't constantly re-run.
@st.cache

# Creating a function to load the data into a pandas dataframe
def load_data():
    cur = conn.cursor().execute(query)
    payments_df = pd.DataFrame.from_records(iter(cur), columns=[x[0] for x in cur.description])
    payments_df['PAYMENT_DATE'] = pd.to_datetime(payments_df['PAYMENT_DATE'])
    payments_df = payments_df.set_index('PAYMENT_DATE')
    return payments_df

# Using the load_data() function to load the data
payments_df = load_data() # This creates what we call a 'dataframe' called payments_df, think of this as
                            # a table. To create the table, we use the above function. So, basically,
                            # every time your write 'payments_df' in your code, you're referencing
                            # the result of your query.

# This function returns the earliest date present in the dataset
def get_min_date():
    return min(payments_df.index.to_list()).date()

# This function returns the latest date present in the dataset
def get_max_date():
    return max(payments_df.index.to_list()).date()

# This function creates the app with title, min and max slider
def app_creation():
    st.title('Payments in 2021')
    min_filter = st.slider('Select Min date',
                           min_value=get_min_date(),
                           max_value=get_max_date(),
                           value=get_min_date()
                           )
    max_filter = st.slider('Select Max date',
                           min_value=get_min_date(),
                           max_value=get_max_date(),
                           value=get_max_date()
                           )
    mask = (payments_df.index >= pd.to_datetime(min_filter)) \
             & (payments_df.index <= pd.to_datetime(max_filter))

    # This line creates a new dataframe (table) that filters
    # your results to between the range of your min
    # slider, and your max slider.
    payments_df_filtered = payments_df.loc[mask]

    # Create a line chart using the new payments_df_filtered dataframe.
    st.line_chart(payments_df_filtered)

# The function above is now invoked
app_creation()
