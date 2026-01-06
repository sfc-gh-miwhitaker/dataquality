/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Create Streamlit Dashboard
 *
 * PURPOSE:
 *   Deploys the Streamlit data quality dashboard using Git integration.
 *   The dashboard provides interactive quality monitoring and remediation tools.
 *
 * OBJECTS CREATED:
 *   - DATAQUALITY_METRICS.DATA_QUALITY_DASHBOARD (Streamlit app)
 *
 * FEATURES:
 *   - Quality score overview with KPIs
 *   - Issue breakdown by category (NULL, Blank, Duplicates)
 *   - Market area quality comparison
 *   - Quick remediation actions
 *   - DMF execution history
 *
 * Author: SE Community | Expires: 2026-02-05
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA DATAQUALITY_METRICS;

-- ============================================================================
-- Create Streamlit Application from Git Repository
-- ============================================================================

CREATE OR REPLACE STREAMLIT DATA_QUALITY_DASHBOARD
    ROOT_LOCATION = '@SNOWFLAKE_EXAMPLE.GIT_REPOS.DATAQUALITY_REPO/branches/main/streamlit'
    MAIN_FILE = 'streamlit_app.py'
    QUERY_WAREHOUSE = SFE_DATAQUALITY_WH
    TITLE = 'Data Quality Dashboard'
    COMMENT = 'DEMO: Interactive data quality monitoring dashboard with DMF integration | Author: SE Community | Expires: 2026-02-05';

-- ============================================================================
-- Verify Streamlit Deployment
-- ============================================================================

-- Note: SHOW STREAMLITS doesn't work in EXECUTE IMMEDIATE context
-- To verify manually: SHOW STREAMLITS IN SCHEMA SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS;

SELECT
    'Streamlit App Deployed' AS status,
    'DATA_QUALITY_DASHBOARD' AS app_name,
    'Navigate to: Apps > Streamlit > DATA_QUALITY_DASHBOARD' AS access_instructions;
