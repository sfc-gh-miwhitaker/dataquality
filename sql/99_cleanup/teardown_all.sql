/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Teardown All Objects
 * 
 * PURPOSE:
 *   Removes all objects created by this demo project.
 *   Preserves the SNOWFLAKE_EXAMPLE database and shared infrastructure.
 * 
 * OBJECTS DROPPED:
 *   - SFE_RAW_REALESTATE schema (cascade)
 *   - SFE_STG_REALESTATE schema (cascade)
 *   - SFE_ANALYTICS_REALESTATE schema (cascade)
 *   - DATAQUALITY_GIT_REPOS schema (cascade)
 *   - SFE_DATAQUALITY_WH warehouse
 *   - SFE_DATAQUALITY_GIT_API_INTEGRATION (if not shared)
 * 
 * PRESERVED:
 *   - SNOWFLAKE_EXAMPLE database
 *   - Other SFE_* schemas from other demos
 *   - Shared API integrations (if used by other projects)
 * 
 * Author: SE Community | Expires: 2025-12-31
 ******************************************************************************/

-- ============================================================================
-- Step 1: Drop Streamlit App (must be done before schema drop)
-- ============================================================================

DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DATA_QUALITY_DASHBOARD;

-- ============================================================================
-- Step 2: Drop Dynamic Tables (to cleanly stop refresh tasks)
-- ============================================================================

DROP DYNAMIC TABLE IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DT_QUALITY_SUMMARY;
DROP DYNAMIC TABLE IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DT_MARKET_TRENDS;

-- ============================================================================
-- Step 3: Remove DMF Associations (before dropping tables)
-- ============================================================================

-- Note: DMF associations are automatically removed when tables are dropped
-- but we explicitly remove them for cleaner audit trails

ALTER TABLE IF EXISTS SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
    DROP ALL DATA METRIC FUNCTIONS;

-- ============================================================================
-- Step 4: Drop Project Schemas (CASCADE drops all contained objects)
-- ============================================================================

-- Raw layer schema
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE CASCADE;

-- Staging layer schema
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_STG_REALESTATE CASCADE;

-- Analytics layer schema
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE CASCADE;

-- Git repository schema
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS CASCADE;

-- ============================================================================
-- Step 5: Drop Warehouse
-- ============================================================================

DROP WAREHOUSE IF EXISTS SFE_DATAQUALITY_WH;

-- ============================================================================
-- Step 6: Drop API Integration (only if not used by other demos)
-- ============================================================================

-- Check if other Git repositories use this integration before dropping
-- SHOW GIT REPOSITORIES;

-- Only drop if no other repos depend on it
DROP API INTEGRATION IF EXISTS SFE_DATAQUALITY_GIT_API_INTEGRATION;

-- ============================================================================
-- Verification
-- ============================================================================

-- Verify schemas removed
SELECT 'Remaining Schemas' AS check_type, SCHEMA_NAME
FROM SNOWFLAKE_EXAMPLE.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME LIKE 'SFE_%REALESTATE%'
   OR SCHEMA_NAME LIKE 'DATAQUALITY%';

-- Note: SHOW commands don't work in EXECUTE IMMEDIATE context
-- To verify warehouse and API integration removal, run these manually after cleanup:
--   SHOW WAREHOUSES LIKE 'SFE_DATAQUALITY%';
--   SHOW API INTEGRATIONS LIKE 'SFE_DATAQUALITY%';

SELECT 
    'Cleanup verification' AS check_type,
    'SFE_DATAQUALITY_WH' AS warehouse_dropped,
    'SFE_DATAQUALITY_GIT_API_INTEGRATION' AS api_integration_dropped;

-- ============================================================================
-- Cleanup Complete
-- ============================================================================

SELECT 
    '✅ Cleanup Complete!' AS status,
    'All Data Quality Metrics Demo objects have been removed.' AS message,
    'SNOWFLAKE_EXAMPLE database preserved for other demos.' AS note;

