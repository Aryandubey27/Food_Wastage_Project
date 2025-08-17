import streamlit as st
import pandas as pd
import psycopg2

# --- DATABASE CONNECTION ---
# Initialize connection.
# Uses st.cache_resource to only run once.


@st.cache_resource
def init_connection():
    return psycopg2.connect(**st.secrets["postgres"])


conn = init_connection()

# --- DATA FETCHING ---
# Uses st.cache_data to only rerun when the query changes or after 10 min.


@st.cache_data(ttl=600)
def run_query(query):
    with conn.cursor() as cur:
        cur.execute(query)
        return cur.fetchall()


# --- PAGE CONFIGURATION ---
st.set_page_config(
    page_title="Food Wastage Management",
    page_icon="🍲",
    layout="wide"
)

st.title("🍲 Local Food Wastage Management System")

# --- SIDEBAR FILTERS ---
st.sidebar.header("Filter Options")

# City Filter
cities = pd.read_sql(
    "SELECT DISTINCT City FROM Providers ORDER BY City;", conn)
selected_city = st.sidebar.selectbox("Select a City", cities["city"].tolist(
), index=None, placeholder="Select a city...")

# Provider Type Filter
provider_types = pd.read_sql(
    "SELECT DISTINCT Type FROM Providers ORDER BY Type;", conn)
selected_provider_type = st.sidebar.selectbox(
    "Select Provider Type", provider_types["type"].tolist(), index=None, placeholder="Select a type...")

# --- MAIN PAGE DISPLAY ---
st.header("Available Food Listings")

# Build the query based on filters
query = "SELECT fl.food_name, fl.quantity, fl.expiry_date, p.name as provider_name, fl.location, fl.food_type, fl.meal_type FROM Food_Listings fl JOIN Providers p ON fl.provider_id = p.provider_id WHERE 1=1"

if selected_city:
    query += f" AND p.City = '{selected_city}'"
if selected_provider_type:
    query += f" AND p.Type = '{selected_provider_type}'"

# Fetch and display data
try:
    available_food_df = pd.read_sql(query, conn)
    st.dataframe(available_food_df, use_container_width=True)
except Exception as e:
    st.error(f"Error fetching data: {e}")


# --- ANALYSIS SECTION ---
st.header("📈 Project Analysis & Insights")

# Create columns for layout
col1, col2 = st.columns(2)

with col1:
    st.subheader("Food Contributions by Provider Type")
    query1 = """
    SELECT p.Type AS provider_type, SUM(fl.Quantity) AS total_quantity
    FROM Providers p JOIN Food_Listings fl ON p.Provider_ID = fl.Provider_ID
    GROUP BY p.Type ORDER BY total_quantity DESC;
    """
    provider_contribution_df = pd.read_sql(query1, conn)
    st.bar_chart(provider_contribution_df,
                 x='provider_type', y='total_quantity')

with col2:
    st.subheader("Claim Status Distribution")
    query2 = """
    SELECT Status, COUNT(*) AS total_claims
    FROM Claims GROUP BY Status;
    """
    claim_status_df = pd.read_sql(query2, conn)
    st.bar_chart(claim_status_df, x='status', y='total_claims')

# You can continue to add more charts and tables for the other queries here.
# For example, a table for the number of providers/receivers per city.

st.subheader("Providers & Receivers per City")
query3 = """
SELECT City, COUNT(*) AS Count, 'Provider' AS Type FROM Providers GROUP BY City
UNION ALL
SELECT City, COUNT(*) AS Count, 'Receiver' AS Type FROM Receivers GROUP BY City
ORDER BY City, Type;
"""
city_counts_df = pd.read_sql(query3, conn)
st.dataframe(city_counts_df, use_container_width=True)
