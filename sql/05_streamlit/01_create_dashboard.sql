/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Create Streamlit Dashboard
 * 
 * PURPOSE:
 *   Deploys the Streamlit data quality dashboard using Git integration.
 *   The dashboard provides interactive quality monitoring and remediation tools.
 * 
 * OBJECTS CREATED:
 *   - SFE_ANALYTICS_REALESTATE.SFE_DATA_QUALITY_DASHBOARD (Streamlit app)
 * 
 * FEATURES:
 *   - Quality score overview with KPIs
 *   - Issue breakdown by category (NULL, Blank, Duplicates)
 *   - Market area quality comparison
 *   - Quick remediation actions
 *   - DMF execution history
 * 
 * Author: SE Community | Expires: 2025-12-31
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SFE_ANALYTICS_REALESTATE;

-- ============================================================================
-- Create Streamlit Application from Git Repository
-- ============================================================================

CREATE OR REPLACE STREAMLIT SFE_DATA_QUALITY_DASHBOARD
    ROOT_LOCATION = '@SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/streamlit'
    MAIN_FILE = 'streamlit_app.py'
    QUERY_WAREHOUSE = SFE_DATAQUALITY_WH
    TITLE = 'Data Quality Dashboard'
    COMMENT = 'DEMO: Interactive data quality monitoring dashboard with DMF integration | Author: SE Community | Expires: 2025-12-31';

-- ============================================================================
-- Verify Streamlit Deployment
-- ============================================================================

SHOW STREAMLITS IN SCHEMA SFE_ANALYTICS_REALESTATE;

-- Display access information
SELECT 
    'Streamlit App Deployed!' AS status,
    'SFE_DATA_QUALITY_DASHBOARD' AS app_name,
    'Navigate to: Apps > Streamlit > SFE_DATA_QUALITY_DASHBOARD' AS access_instructions;

