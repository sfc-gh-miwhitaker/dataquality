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
 * Author: SE Community | Expires: 2026-02-05
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA DATAQUALITY_METRICS;

-- ============================================================================
-- Set DMF Schedule (REQUIRED before adding DMFs)
-- ============================================================================

-- Set the schedule FIRST - this is required before associating any DMFs
-- Using 60 minutes for demo purposes (minimum is 5 minutes)
ALTER TABLE RAW_PROPERTY_LISTINGS
    SET DATA_METRIC_SCHEDULE = '60 MINUTE';

-- ============================================================================
-- Associate NULL_COUNT DMFs
-- Monitors for missing values in critical columns
-- ============================================================================

-- NULL_COUNT on PRICE column
ALTER TABLE RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    ON (price);

-- NULL_COUNT on ADDRESS column
ALTER TABLE RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    ON (address);

-- NULL_COUNT on MARKET_AREA column
ALTER TABLE RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    ON (market_area);

-- ============================================================================
-- Associate BLANK_COUNT DMFs
-- Monitors for empty strings in text columns
-- ============================================================================

-- BLANK_COUNT on PROPERTY_TYPE column
ALTER TABLE RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.BLANK_COUNT
    ON (property_type);

-- BLANK_COUNT on LISTING_STATUS column
ALTER TABLE RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.BLANK_COUNT
    ON (listing_status);

-- ============================================================================
-- Associate DUPLICATE_COUNT DMF
-- Monitors for duplicate values in ID column
-- ============================================================================

-- DUPLICATE_COUNT on LISTING_ID column
ALTER TABLE RAW_PROPERTY_LISTINGS
    ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
    ON (listing_id);

-- ============================================================================
-- Verify DMF Associations
-- ============================================================================

-- Show all DMF associations on the table
SELECT
    metric_database_name,
    metric_schema_name,
    metric_name,
    argument_signature,
    data_type,
    ref_database_name,
    ref_schema_name,
    ref_entity_name,
    ref_entity_domain,
    ref_arguments,
    ref_id
FROM TABLE(INFORMATION_SCHEMA.DATA_METRIC_FUNCTION_REFERENCES(
    REF_ENTITY_NAME => 'SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS.RAW_PROPERTY_LISTINGS',
    REF_ENTITY_DOMAIN => 'TABLE'
));

-- ============================================================================
-- Execute DMFs Manually (for immediate results)
-- ============================================================================

-- Run NULL_COUNT on price
SELECT 'NULL_COUNT(price)' AS metric,
       SNOWFLAKE.CORE.NULL_COUNT(SELECT price FROM RAW_PROPERTY_LISTINGS) AS value;

-- Run NULL_COUNT on address
SELECT 'NULL_COUNT(address)' AS metric,
       SNOWFLAKE.CORE.NULL_COUNT(SELECT address FROM RAW_PROPERTY_LISTINGS) AS value;

-- Run BLANK_COUNT on property_type
SELECT 'BLANK_COUNT(property_type)' AS metric,
       SNOWFLAKE.CORE.BLANK_COUNT(SELECT property_type FROM RAW_PROPERTY_LISTINGS) AS value;

-- Run DUPLICATE_COUNT on listing_id
SELECT 'DUPLICATE_COUNT(listing_id)' AS metric,
       SNOWFLAKE.CORE.DUPLICATE_COUNT(SELECT listing_id FROM RAW_PROPERTY_LISTINGS) AS value;

-- ============================================================================
-- Store Initial Results in Metrics Table
-- ============================================================================

INSERT INTO DQ_METRIC_RESULTS
    (table_name, column_name, metric_name, metric_value, execution_time)
SELECT
    'RAW_PROPERTY_LISTINGS',
    'price',
    'NULL_COUNT',
    SNOWFLAKE.CORE.NULL_COUNT(SELECT price FROM RAW_PROPERTY_LISTINGS),
    CURRENT_TIMESTAMP();

INSERT INTO DQ_METRIC_RESULTS
    (table_name, column_name, metric_name, metric_value, execution_time)
SELECT
    'RAW_PROPERTY_LISTINGS',
    'address',
    'NULL_COUNT',
    SNOWFLAKE.CORE.NULL_COUNT(SELECT address FROM RAW_PROPERTY_LISTINGS),
    CURRENT_TIMESTAMP();

INSERT INTO DQ_METRIC_RESULTS
    (table_name, column_name, metric_name, metric_value, execution_time)
SELECT
    'RAW_PROPERTY_LISTINGS',
    'property_type',
    'BLANK_COUNT',
    SNOWFLAKE.CORE.BLANK_COUNT(SELECT property_type FROM RAW_PROPERTY_LISTINGS),
    CURRENT_TIMESTAMP();

INSERT INTO DQ_METRIC_RESULTS
    (table_name, column_name, metric_name, metric_value, execution_time)
SELECT
    'RAW_PROPERTY_LISTINGS',
    'listing_id',
    'DUPLICATE_COUNT',
    SNOWFLAKE.CORE.DUPLICATE_COUNT(SELECT listing_id FROM RAW_PROPERTY_LISTINGS),
    CURRENT_TIMESTAMP();

-- Verify stored results
SELECT table_name, column_name, metric_name, metric_value, execution_time
FROM DQ_METRIC_RESULTS
ORDER BY execution_time DESC;
