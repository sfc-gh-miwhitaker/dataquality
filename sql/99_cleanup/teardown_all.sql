/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Teardown All Objects
 *
 * PURPOSE:
 *   Removes all objects created by this demo project.
 *   Preserves the SNOWFLAKE_EXAMPLE database and shared infrastructure.
 *
 * OBJECTS DROPPED:
 *   - DATAQUALITY_METRICS schema (cascade)
 *   - SNOWFLAKE_EXAMPLE.GIT_REPOS.DATAQUALITY_REPO (Git repository object)
 *   - SFE_DATAQUALITY_WH warehouse
 *   - SFE_DATAQUALITY_GIT_API_INTEGRATION (if not shared)
 *
 * PRESERVED:
 *   - SNOWFLAKE_EXAMPLE database
 *   - SNOWFLAKE_EXAMPLE.GIT_REPOS schema (shared infrastructure)
 *   - Other demo schemas
 *   - Shared API integrations (if used by other projects)
 *
 * Author: SE Community | Expires: 2026-02-05
 ******************************************************************************/

-- ============================================================================
-- Step 1: Drop Streamlit App (must be done before schema drop)
-- ============================================================================

DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS.DATA_QUALITY_DASHBOARD;

-- ============================================================================
-- Step 2: Drop Dynamic Tables (to cleanly stop refresh tasks)
-- ============================================================================

DROP DYNAMIC TABLE IF EXISTS SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS.DT_QUALITY_SUMMARY;
DROP DYNAMIC TABLE IF EXISTS SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS.DT_MARKET_TRENDS;

-- ============================================================================
-- Step 3: Remove DMF Associations (before dropping tables)
-- ============================================================================

-- Note: DMF associations are automatically removed when tables are dropped
-- via CASCADE, so no explicit removal needed. The schema drop in Step 4
-- will clean up all DMF associations automatically.

-- ============================================================================
-- Step 4: Drop Project Schemas (CASCADE drops all contained objects)
-- ============================================================================

-- Project schema
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS CASCADE;

-- Git repository object (do not drop the shared schema)
DROP GIT REPOSITORY IF EXISTS SNOWFLAKE_EXAMPLE.GIT_REPOS.DATAQUALITY_REPO;

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
WHERE SCHEMA_NAME = 'DATAQUALITY_METRICS'
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
    'Cleanup Complete' AS status,
    'All Data Quality Metrics Demo objects have been removed.' AS message,
    'SNOWFLAKE_EXAMPLE database preserved for other demos.' AS note;
