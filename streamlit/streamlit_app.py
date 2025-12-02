"""
Data Quality Metrics Dashboard

Interactive Streamlit dashboard for monitoring data quality metrics,
identifying issues, and facilitating remediation workflows.

Author: SE Community
Expires: 2025-12-31
"""

from snowflake.snowpark.context import get_active_session
import streamlit as st
import pandas as pd

# Page configuration
st.set_page_config(
    page_title="Data Quality Dashboard",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Get Snowflake session
session = get_active_session()

# Custom CSS for styling
st.markdown("""
<style>
    .metric-card {
        background-color: #f0f2f6;
        border-radius: 10px;
        padding: 20px;
        margin: 10px 0;
    }
    .quality-good { color: #28a745; }
    .quality-warning { color: #ffc107; }
    .quality-bad { color: #dc3545; }
    .stMetric > div > div > div > div {
        font-size: 1.2rem;
    }
</style>
""", unsafe_allow_html=True)

# Header
st.title("📊 Data Quality Metrics Dashboard")
st.markdown("**Demo:** Real Estate Property Listings Quality Monitoring")
st.markdown("---")

# Sidebar
with st.sidebar:
    st.header("⚙️ Dashboard Controls")
    
    # Refresh button
    if st.button("🔄 Refresh Data", use_container_width=True):
        st.cache_data.clear()
        st.experimental_rerun()
    
    st.markdown("---")
    
    # Filter options
    st.subheader("Filters")
    
    # Get market areas for filter
    market_areas_df = session.sql("""
        SELECT DISTINCT COALESCE(market_area, 'Unknown') AS market_area
        FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
        WHERE market_area IS NOT NULL
        ORDER BY market_area
    """).to_pandas()
    
    selected_markets = st.multiselect(
        "Market Areas",
        options=market_areas_df['MARKET_AREA'].tolist(),
        default=[]
    )
    
    st.markdown("---")
    st.caption("Data Quality Metrics Demo")
    st.caption("Author: SE Community")
    st.caption("Expires: 2025-12-31")

# Main content
# Fetch quality summary from Dynamic Table
@st.cache_data(ttl=60)
def get_quality_summary():
    return session.sql("""
        SELECT 
            total_records,
            null_price_count,
            null_address_count,
            null_market_area_count,
            blank_property_type_count,
            blank_listing_status_count,
            duplicate_id_count,
            quality_score,
            total_issues
        FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DT_QUALITY_SUMMARY
    """).to_pandas()

@st.cache_data(ttl=60)
def get_market_quality():
    return session.sql("""
        SELECT 
            market_area,
            total_listings,
            active_listings,
            avg_price,
            median_price,
            null_prices,
            blank_types,
            market_quality_score
        FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DT_MARKET_TRENDS
        ORDER BY market_quality_score ASC
    """).to_pandas()

@st.cache_data(ttl=60)
def get_metric_history():
    return session.sql("""
        SELECT 
            table_name,
            column_name,
            metric_name,
            metric_value,
            execution_time
        FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DQ_METRIC_RESULTS
        ORDER BY execution_time DESC
        LIMIT 100
    """).to_pandas()

# Load data
try:
    quality_df = get_quality_summary()
    market_df = get_market_quality()
    history_df = get_metric_history()
    
    # Quality Score Section
    col1, col2, col3, col4 = st.columns(4)
    
    if not quality_df.empty:
        quality_score = quality_df['QUALITY_SCORE'].iloc[0]
        total_records = quality_df['TOTAL_RECORDS'].iloc[0]
        total_issues = quality_df['TOTAL_ISSUES'].iloc[0]
        
        # Determine score color
        if quality_score >= 90:
            score_delta = "Good"
        elif quality_score >= 75:
            score_delta = "Warning"
        else:
            score_delta = "Needs Attention"
        
        with col1:
            st.metric(
                label="Overall Quality Score",
                value=f"{quality_score:.1f}%",
                delta=score_delta
            )
        
        with col2:
            st.metric(
                label="Total Records",
                value=f"{total_records:,}"
            )
        
        with col3:
            st.metric(
                label="Total Issues",
                value=f"{total_issues:,}",
                delta=f"-{total_issues}" if total_issues > 0 else "Clean"
            )
        
        with col4:
            issue_rate = (total_issues / total_records * 100) if total_records > 0 else 0
            st.metric(
                label="Issue Rate",
                value=f"{issue_rate:.2f}%"
            )
    
    st.markdown("---")
    
    # Issue Breakdown Section
    st.subheader("📋 Issue Breakdown")
    
    if not quality_df.empty:
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("#### NULL Values")
            null_data = {
                'Column': ['Price', 'Address', 'Market Area'],
                'Count': [
                    int(quality_df['NULL_PRICE_COUNT'].iloc[0]),
                    int(quality_df['NULL_ADDRESS_COUNT'].iloc[0]),
                    int(quality_df['NULL_MARKET_AREA_COUNT'].iloc[0])
                ]
            }
            null_df = pd.DataFrame(null_data)
            st.dataframe(null_df, use_container_width=True)
        
        with col2:
            st.markdown("#### Blank/Empty Values")
            blank_data = {
                'Column': ['Property Type', 'Listing Status'],
                'Count': [
                    int(quality_df['BLANK_PROPERTY_TYPE_COUNT'].iloc[0]),
                    int(quality_df['BLANK_LISTING_STATUS_COUNT'].iloc[0])
                ]
            }
            blank_df = pd.DataFrame(blank_data)
            st.dataframe(blank_df, use_container_width=True)
        
        # Duplicates
        st.markdown("#### Duplicate Records")
        dup_count = int(quality_df['DUPLICATE_ID_COUNT'].iloc[0])
        st.info(f"**{dup_count:,}** records have duplicate listing IDs")
    
    st.markdown("---")
    
    # Market Quality Section
    st.subheader("🏘️ Quality by Market Area")
    
    if not market_df.empty:
        # Bar chart of quality scores by market
        st.bar_chart(
            market_df.set_index('MARKET_AREA')['MARKET_QUALITY_SCORE'],
            use_container_width=True
        )
        
        # Detailed market table
        st.dataframe(
            market_df[[
                'MARKET_AREA', 
                'TOTAL_LISTINGS', 
                'MARKET_QUALITY_SCORE',
                'AVG_PRICE',
                'NULL_PRICES',
                'BLANK_TYPES'
            ]].rename(columns={
                'MARKET_AREA': 'Market',
                'TOTAL_LISTINGS': 'Listings',
                'MARKET_QUALITY_SCORE': 'Quality %',
                'AVG_PRICE': 'Avg Price',
                'NULL_PRICES': 'Null Prices',
                'BLANK_TYPES': 'Blank Types'
            }),
            use_container_width=True
        )
    
    st.markdown("---")
    
    # Remediation Section
    st.subheader("🔧 Quick Remediation Actions")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.markdown("##### View NULL Records")
        if st.button("Get Records with NULL Prices", key="null_prices"):
            null_records = session.sql("""
                SELECT listing_id, address, city, market_area, price
                FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
                WHERE price IS NULL
                LIMIT 100
            """).to_pandas()
            st.dataframe(null_records, use_container_width=True)
    
    with col2:
        st.markdown("##### View Blank Records")
        if st.button("Get Records with Blank Types", key="blank_types"):
            blank_records = session.sql("""
                SELECT listing_id, address, property_type, listing_status
                FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
                WHERE TRIM(COALESCE(property_type, '')) = ''
                LIMIT 100
            """).to_pandas()
            st.dataframe(blank_records, use_container_width=True)
    
    with col3:
        st.markdown("##### View Duplicates")
        if st.button("Get Duplicate Listing IDs", key="duplicates"):
            dup_records = session.sql("""
                SELECT listing_id, COUNT(*) as occurrence_count
                FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
                GROUP BY listing_id
                HAVING COUNT(*) > 1
                ORDER BY occurrence_count DESC
                LIMIT 50
            """).to_pandas()
            st.dataframe(dup_records, use_container_width=True)
    
    st.markdown("---")
    
    # Metric History Section
    st.subheader("📈 Recent DMF Executions")
    
    if not history_df.empty:
        st.dataframe(
            history_df.rename(columns={
                'TABLE_NAME': 'Table',
                'COLUMN_NAME': 'Column',
                'METRIC_NAME': 'Metric',
                'METRIC_VALUE': 'Value',
                'EXECUTION_TIME': 'Executed At'
            }),
            use_container_width=True
        )
    else:
        st.info("No DMF execution history available yet.")

except Exception as e:
    st.error(f"Error loading data: {str(e)}")
    st.warning("**Troubleshooting Steps:**")
    st.markdown("""
1. **Verify deployment completed:** Run `SHOW DYNAMIC TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE;`
2. **Force refresh if needed:**
   ```sql
   ALTER DYNAMIC TABLE SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DT_QUALITY_SUMMARY REFRESH;
   ALTER DYNAMIC TABLE SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DT_MARKET_TRENDS REFRESH;
   ```
3. **Click the Refresh Data button above** after running the refresh commands.
    """)

# Footer
st.markdown("---")
st.caption("Data Quality Metrics Demo | Powered by Snowflake DMFs & Dynamic Tables")
st.caption("Features: NULL_COUNT, BLANK_COUNT, DUPLICATE_COUNT, SYSTEM$DATA_METRIC_SCAN")

