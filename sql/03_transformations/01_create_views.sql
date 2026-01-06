/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Create Views
 *
 * PURPOSE:
 *   Creates views for data quality dashboard and reporting:
 *   - Quality dashboard view with aggregated metrics
 *   - Cleaned property listings view
 *   - Market summary view
 *
 * OBJECTS CREATED:
 *   - DATAQUALITY_METRICS.V_QUALITY_DASHBOARD
 *   - DATAQUALITY_METRICS.V_PROPERTY_QUALITY_SCORES
 *   - DATAQUALITY_METRICS.V_MARKET_SUMMARY
 *
 * Author: SE Community | Expires: 2026-02-05
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA DATAQUALITY_METRICS;

-- ============================================================================
-- Quality Dashboard View
-- Main view powering the Streamlit dashboard
-- ============================================================================

CREATE OR REPLACE VIEW V_QUALITY_DASHBOARD
COMMENT = 'DEMO: Aggregated quality metrics for dashboard | Author: SE Community | Expires: 2026-02-05'
AS
WITH quality_metrics AS (
    SELECT
        -- Total counts
        COUNT(*) AS total_records,

        -- NULL counts by column
        SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price_count,
        SUM(CASE WHEN address IS NULL THEN 1 ELSE 0 END) AS null_address_count,
        SUM(CASE WHEN market_area IS NULL THEN 1 ELSE 0 END) AS null_market_area_count,

        -- Blank counts by column
        SUM(CASE WHEN TRIM(COALESCE(property_type, '')) = '' THEN 1 ELSE 0 END) AS blank_property_type_count,
        SUM(CASE WHEN TRIM(COALESCE(listing_status, '')) = '' THEN 1 ELSE 0 END) AS blank_listing_status_count,

        -- Duplicate count (records with non-unique listing_id)
        COUNT(*) - COUNT(DISTINCT listing_id) AS duplicate_id_count,

        -- Invalid email count
        SUM(CASE WHEN agent_email NOT LIKE '%@%.%' THEN 1 ELSE 0 END) AS invalid_email_count

    FROM RAW_PROPERTY_LISTINGS
)
SELECT
    total_records,

    -- NULL metrics
    null_price_count,
    ROUND(100.0 * null_price_count / NULLIF(total_records, 0), 2) AS null_price_pct,
    null_address_count,
    ROUND(100.0 * null_address_count / NULLIF(total_records, 0), 2) AS null_address_pct,
    null_market_area_count,
    ROUND(100.0 * null_market_area_count / NULLIF(total_records, 0), 2) AS null_market_area_pct,

    -- Blank metrics
    blank_property_type_count,
    ROUND(100.0 * blank_property_type_count / NULLIF(total_records, 0), 2) AS blank_property_type_pct,
    blank_listing_status_count,
    ROUND(100.0 * blank_listing_status_count / NULLIF(total_records, 0), 2) AS blank_listing_status_pct,

    -- Duplicate metrics
    duplicate_id_count,
    ROUND(100.0 * duplicate_id_count / NULLIF(total_records, 0), 2) AS duplicate_id_pct,

    -- Invalid format metrics
    invalid_email_count,
    ROUND(100.0 * invalid_email_count / NULLIF(total_records, 0), 2) AS invalid_email_pct,

    -- Overall quality score (percentage of records without any issues)
    ROUND(100.0 - (
        (null_price_count + null_address_count + null_market_area_count +
         blank_property_type_count + blank_listing_status_count +
         duplicate_id_count + invalid_email_count) * 100.0 /
        NULLIF(total_records * 7, 0)  -- 7 quality checks
    ), 2) AS overall_quality_score,

    -- Total issues
    (null_price_count + null_address_count + null_market_area_count +
     blank_property_type_count + blank_listing_status_count +
     duplicate_id_count + invalid_email_count) AS total_issues,

    CURRENT_TIMESTAMP() AS calculated_at

FROM quality_metrics;

-- ============================================================================
-- Property Quality Scores by Market Area
-- ============================================================================

CREATE OR REPLACE VIEW V_PROPERTY_QUALITY_SCORES
COMMENT = 'DEMO: Quality scores by market area | Author: SE Community | Expires: 2026-02-05'
AS
SELECT
    COALESCE(market_area, 'Unknown') AS market_area,
    COUNT(*) AS total_listings,

    -- Quality issue counts
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_prices,
    SUM(CASE WHEN address IS NULL THEN 1 ELSE 0 END) AS null_addresses,
    SUM(CASE WHEN TRIM(COALESCE(property_type, '')) = '' THEN 1 ELSE 0 END) AS blank_types,

    -- Quality score per market
    ROUND(100.0 * (
        COUNT(*) -
        SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) -
        SUM(CASE WHEN address IS NULL THEN 1 ELSE 0 END) -
        SUM(CASE WHEN TRIM(COALESCE(property_type, '')) = '' THEN 1 ELSE 0 END)
    ) / NULLIF(COUNT(*), 0), 2) AS quality_score,

    -- Average price (excluding nulls)
    ROUND(AVG(price), 0) AS avg_price,

    -- Listing status distribution
    SUM(CASE WHEN listing_status = 'Active' THEN 1 ELSE 0 END) AS active_count,
    SUM(CASE WHEN listing_status = 'Pending' THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN listing_status = 'Sold' THEN 1 ELSE 0 END) AS sold_count

FROM RAW_PROPERTY_LISTINGS
GROUP BY COALESCE(market_area, 'Unknown')
ORDER BY quality_score ASC;

-- ============================================================================
-- Market Summary View
-- ============================================================================

CREATE OR REPLACE VIEW V_MARKET_SUMMARY
COMMENT = 'DEMO: Monthly market metrics summary | Author: SE Community | Expires: 2026-02-05'
AS
SELECT
    COALESCE(market_area, 'Unknown') AS market_area,
    DATE_TRUNC('month', listing_date) AS listing_month,
    COUNT(*) AS listing_count,
    ROUND(AVG(price), 0) AS avg_price,
    ROUND(MEDIAN(price), 0) AS median_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    ROUND(AVG(sqft), 0) AS avg_sqft,
    ROUND(AVG(price / NULLIF(sqft, 0)), 2) AS price_per_sqft
FROM RAW_PROPERTY_LISTINGS
WHERE price IS NOT NULL
  AND sqft IS NOT NULL
  AND listing_date IS NOT NULL
GROUP BY
    COALESCE(market_area, 'Unknown'),
    DATE_TRUNC('month', listing_date)
ORDER BY listing_month DESC, market_area;

-- Verify view creation
-- Note: SHOW VIEWS doesn't work in EXECUTE IMMEDIATE context
-- To verify manually: SHOW VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS;

SELECT
    TABLE_NAME AS view_name,
    CREATED
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'DATAQUALITY_METRICS'
ORDER BY CREATED DESC;
