/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Create Dynamic Tables
 * 
 * PURPOSE:
 *   Creates Dynamic Tables for real-time quality monitoring:
 *   - Quality summary with 1-minute TARGET_LAG
 *   - Market trends with 5-minute TARGET_LAG
 * 
 * OBJECTS CREATED:
 *   - SFE_ANALYTICS_REALESTATE.SFE_DT_QUALITY_SUMMARY
 *   - SFE_ANALYTICS_REALESTATE.SFE_DT_MARKET_TRENDS
 * 
 * Author: SE Community | Expires: 2025-12-31
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE WAREHOUSE SFE_DATAQUALITY_WH;

-- ============================================================================
-- Quality Summary Dynamic Table
-- Real-time aggregation of quality metrics
-- ============================================================================

CREATE OR REPLACE DYNAMIC TABLE SFE_ANALYTICS_REALESTATE.SFE_DT_QUALITY_SUMMARY
    TARGET_LAG = '1 minute'
    WAREHOUSE = SFE_DATAQUALITY_WH
    REFRESH_MODE = AUTO
    INITIALIZE = ON_CREATE
    COMMENT = 'DEMO: Real-time quality metrics with 1-minute lag | Author: SE Community | Expires: 2025-12-31'
AS
SELECT
    -- Timestamp for tracking
    CURRENT_TIMESTAMP() AS snapshot_time,
    
    -- Record counts
    COUNT(*) AS total_records,
    
    -- NULL metrics
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price_count,
    SUM(CASE WHEN address IS NULL THEN 1 ELSE 0 END) AS null_address_count,
    SUM(CASE WHEN market_area IS NULL THEN 1 ELSE 0 END) AS null_market_area_count,
    
    -- Blank metrics  
    SUM(CASE WHEN TRIM(COALESCE(property_type, '')) = '' THEN 1 ELSE 0 END) AS blank_property_type_count,
    SUM(CASE WHEN TRIM(COALESCE(listing_status, '')) = '' THEN 1 ELSE 0 END) AS blank_listing_status_count,
    
    -- Duplicate count
    COUNT(*) - COUNT(DISTINCT listing_id) AS duplicate_id_count,
    
    -- Calculate overall quality score
    ROUND(100.0 * (
        1.0 - (
            (SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) +
             SUM(CASE WHEN address IS NULL THEN 1 ELSE 0 END) +
             SUM(CASE WHEN market_area IS NULL THEN 1 ELSE 0 END) +
             SUM(CASE WHEN TRIM(COALESCE(property_type, '')) = '' THEN 1 ELSE 0 END) +
             SUM(CASE WHEN TRIM(COALESCE(listing_status, '')) = '' THEN 1 ELSE 0 END) +
             (COUNT(*) - COUNT(DISTINCT listing_id))
            ) / NULLIF(COUNT(*) * 6.0, 0)
        )
    ), 2) AS quality_score,
    
    -- Total issues
    (SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) +
     SUM(CASE WHEN address IS NULL THEN 1 ELSE 0 END) +
     SUM(CASE WHEN market_area IS NULL THEN 1 ELSE 0 END) +
     SUM(CASE WHEN TRIM(COALESCE(property_type, '')) = '' THEN 1 ELSE 0 END) +
     SUM(CASE WHEN TRIM(COALESCE(listing_status, '')) = '' THEN 1 ELSE 0 END) +
     (COUNT(*) - COUNT(DISTINCT listing_id))
    ) AS total_issues
    
FROM SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS;

-- ============================================================================
-- Market Trends Dynamic Table
-- Real-time market analytics by area
-- ============================================================================

CREATE OR REPLACE DYNAMIC TABLE SFE_ANALYTICS_REALESTATE.SFE_DT_MARKET_TRENDS
    TARGET_LAG = '5 minutes'
    WAREHOUSE = SFE_DATAQUALITY_WH
    REFRESH_MODE = AUTO
    INITIALIZE = ON_CREATE
    COMMENT = 'DEMO: Real-time market trends with 5-minute lag | Author: SE Community | Expires: 2025-12-31'
AS
SELECT
    COALESCE(market_area, 'Unknown') AS market_area,
    
    -- Volume metrics
    COUNT(*) AS total_listings,
    SUM(CASE WHEN listing_status = 'Active' THEN 1 ELSE 0 END) AS active_listings,
    SUM(CASE WHEN listing_status = 'Pending' THEN 1 ELSE 0 END) AS pending_listings,
    SUM(CASE WHEN listing_status = 'Sold' THEN 1 ELSE 0 END) AS sold_listings,
    
    -- Price metrics (excluding NULLs)
    ROUND(AVG(price), 0) AS avg_price,
    ROUND(MEDIAN(price), 0) AS median_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    
    -- Property metrics
    ROUND(AVG(sqft), 0) AS avg_sqft,
    ROUND(AVG(bedrooms), 1) AS avg_bedrooms,
    ROUND(AVG(bathrooms), 1) AS avg_bathrooms,
    ROUND(AVG(price / NULLIF(sqft, 0)), 2) AS price_per_sqft,
    
    -- Quality metrics per market
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_prices,
    SUM(CASE WHEN TRIM(COALESCE(property_type, '')) = '' THEN 1 ELSE 0 END) AS blank_types,
    ROUND(100.0 * (
        COUNT(*) - 
        SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) -
        SUM(CASE WHEN TRIM(COALESCE(property_type, '')) = '' THEN 1 ELSE 0 END)
    ) / NULLIF(COUNT(*), 0), 2) AS market_quality_score,
    
    -- Timestamp
    CURRENT_TIMESTAMP() AS calculated_at
    
FROM SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
WHERE market_area IS NOT NULL
GROUP BY COALESCE(market_area, 'Unknown');

-- ============================================================================
-- Verify Dynamic Tables
-- ============================================================================

SHOW DYNAMIC TABLES IN SCHEMA SFE_ANALYTICS_REALESTATE;

-- Check refresh status
SELECT 
    name,
    target_lag,
    refresh_mode,
    scheduling_state
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLES())
WHERE SCHEMA_NAME = 'SFE_ANALYTICS_REALESTATE';

