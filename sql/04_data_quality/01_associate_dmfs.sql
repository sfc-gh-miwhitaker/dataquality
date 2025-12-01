/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Associate Data Metric Functions
 * 
 * PURPOSE:
 *   Associates Snowflake system DMFs with the raw property listings table
 *   to enable automated data quality monitoring:
 *   - NULL_COUNT on price, address, market_area columns
 *   - BLANK_COUNT on property_type, listing_status columns
 *   - DUPLICATE_COUNT on listing_id column
 * 
 * DMFs ASSOCIATED:
 *   - SNOWFLAKE.CORE.NULL_COUNT
 *   - SNOWFLAKE.CORE.BLANK_COUNT
 *   - SNOWFLAKE.CORE.DUPLICATE_COUNT
 * 
 * Author: SE Community | Expires: 2025-12-31
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

-- ============================================================================
-- Grant Required Privileges for DMF Usage
-- ============================================================================

-- Note: SNOWFLAKE.DATA_METRIC_USER database role provides USAGE on system DMFs
-- This is typically granted at account setup, but we ensure it here

-- ============================================================================
-- Associate NULL_COUNT DMFs
-- Monitors for missing values in critical columns
-- ============================================================================

-- NULL_COUNT on PRICE column
ALTER TABLE SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    ON (price);

-- NULL_COUNT on ADDRESS column
ALTER TABLE SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    ON (address);

-- NULL_COUNT on MARKET_AREA column
ALTER TABLE SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    ON (market_area);

-- ============================================================================
-- Associate BLANK_COUNT DMFs
-- Monitors for empty strings in text columns
-- ============================================================================

-- BLANK_COUNT on PROPERTY_TYPE column
ALTER TABLE SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.BLANK_COUNT
    ON (property_type);

-- BLANK_COUNT on LISTING_STATUS column
ALTER TABLE SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.BLANK_COUNT
    ON (listing_status);

-- ============================================================================
-- Associate DUPLICATE_COUNT DMF
-- Monitors for duplicate values in ID column
-- ============================================================================

-- DUPLICATE_COUNT on LISTING_ID column
ALTER TABLE SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
    ON (listing_id);

-- ============================================================================
-- Set DMF Schedule (Optional - runs on schedule when set)
-- For demo purposes, we'll run manually or on-demand
-- ============================================================================

-- To schedule DMFs to run every hour:
-- ALTER TABLE SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
--     SET DATA_METRIC_SCHEDULE = 'USING CRON 0 * * * * UTC';

-- ============================================================================
-- Verify DMF Associations
-- ============================================================================

-- Show all DMF associations on the table
SELECT 
    metric_database,
    metric_schema,
    metric_name,
    ref_entity_database,
    ref_entity_schema,
    ref_entity_name,
    ref_entity_domain,
    arguments,
    schedule,
    schedule_status
FROM TABLE(INFORMATION_SCHEMA.DATA_METRIC_FUNCTION_REFERENCES(
    REF_ENTITY_NAME => 'SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS',
    REF_ENTITY_DOMAIN => 'TABLE'
));

-- ============================================================================
-- Execute DMFs Manually (for immediate results)
-- ============================================================================

-- Run NULL_COUNT on price
SELECT 'NULL_COUNT(price)' AS metric, 
       SNOWFLAKE.CORE.NULL_COUNT(SELECT price FROM SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS) AS value;

-- Run NULL_COUNT on address
SELECT 'NULL_COUNT(address)' AS metric,
       SNOWFLAKE.CORE.NULL_COUNT(SELECT address FROM SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS) AS value;

-- Run BLANK_COUNT on property_type
SELECT 'BLANK_COUNT(property_type)' AS metric,
       SNOWFLAKE.CORE.BLANK_COUNT(SELECT property_type FROM SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS) AS value;

-- Run DUPLICATE_COUNT on listing_id
SELECT 'DUPLICATE_COUNT(listing_id)' AS metric,
       SNOWFLAKE.CORE.DUPLICATE_COUNT(SELECT listing_id FROM SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS) AS value;

-- ============================================================================
-- Store Initial Results in Metrics Table
-- ============================================================================

INSERT INTO SFE_ANALYTICS_REALESTATE.SFE_DQ_METRIC_RESULTS 
    (table_name, column_name, metric_name, metric_value, execution_time)
SELECT 
    'SFE_RAW_PROPERTY_LISTINGS',
    'price',
    'NULL_COUNT',
    SNOWFLAKE.CORE.NULL_COUNT(SELECT price FROM SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS),
    CURRENT_TIMESTAMP();

INSERT INTO SFE_ANALYTICS_REALESTATE.SFE_DQ_METRIC_RESULTS 
    (table_name, column_name, metric_name, metric_value, execution_time)
SELECT 
    'SFE_RAW_PROPERTY_LISTINGS',
    'address',
    'NULL_COUNT',
    SNOWFLAKE.CORE.NULL_COUNT(SELECT address FROM SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS),
    CURRENT_TIMESTAMP();

INSERT INTO SFE_ANALYTICS_REALESTATE.SFE_DQ_METRIC_RESULTS 
    (table_name, column_name, metric_name, metric_value, execution_time)
SELECT 
    'SFE_RAW_PROPERTY_LISTINGS',
    'property_type',
    'BLANK_COUNT',
    SNOWFLAKE.CORE.BLANK_COUNT(SELECT property_type FROM SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS),
    CURRENT_TIMESTAMP();

INSERT INTO SFE_ANALYTICS_REALESTATE.SFE_DQ_METRIC_RESULTS 
    (table_name, column_name, metric_name, metric_value, execution_time)
SELECT 
    'SFE_RAW_PROPERTY_LISTINGS',
    'listing_id',
    'DUPLICATE_COUNT',
    SNOWFLAKE.CORE.DUPLICATE_COUNT(SELECT listing_id FROM SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS),
    CURRENT_TIMESTAMP();

-- Verify stored results
SELECT table_name, column_name, metric_name, metric_value, execution_time
FROM SFE_ANALYTICS_REALESTATE.SFE_DQ_METRIC_RESULTS
ORDER BY execution_time DESC;

