/*******************************************************************************
 * DEMO METADATA (Machine-readable - Do not modify format)
 * PROJECT_NAME: Data Quality Metrics Demo
 * AUTHOR: SE Community
 * CREATED: 2025-12-01
 * EXPIRES: 2025-12-31
 * GITHUB_REPO: https://github.com/sfc-gh-miwhitaker/dataquality
 * PURPOSE: Data quality monitoring, validation, and reporting for real estate analytics
 * 
 * DEPLOYMENT INSTRUCTIONS:
 * 1. Open Snowsight (https://app.snowflake.com)
 * 2. Copy this ENTIRE script
 * 3. Paste into a new SQL worksheet
 * 4. Click "Run All" (or press Cmd/Ctrl + Shift + Enter)
 * 5. Monitor output for any errors
 * 
 * This script creates all necessary Snowflake objects by pulling SQL files
 * from the GitHub repository using native Git integration.
 * 
 * To extend expiration: Run cursor command "extendexpiration 30"
 ******************************************************************************/

-- ============================================================================
-- SECTION 0: Expiration Check
-- Last Updated: 2025-12-01
-- ============================================================================

EXECUTE IMMEDIATE
$$
DECLARE
    v_expiration_date DATE := '2025-12-31';
    v_days_remaining INT;
    demo_expired EXCEPTION (-20001, 'DEMO EXPIRED: This project expired on 2025-12-31. Features and syntax may be outdated. Contact your Snowflake SE for current demos.');
BEGIN
    v_days_remaining := DATEDIFF('day', CURRENT_DATE(), v_expiration_date);
    
    IF (CURRENT_DATE() > v_expiration_date) THEN
        RAISE demo_expired;
    END IF;
    
    RETURN 'Demo is current. Expires: ' || v_expiration_date || ' (' || v_days_remaining || ' days remaining)';
END;
$$;

-- ============================================================================
-- SECTION 1: Git Integration Setup
-- ============================================================================

-- Create API Integration for GitHub access (public repos, no authentication)
CREATE OR REPLACE API INTEGRATION SFE_DATAQUALITY_GIT_API_INTEGRATION
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-miwhitaker/')
    ENABLED = TRUE
    COMMENT = 'DEMO: Data Quality Metrics Demo - Git integration for public repo access | Author: SE Community | Expires: 2025-12-31';

-- ============================================================================
-- SECTION 2: Database and Schema Setup
-- ============================================================================

-- Create database (shared across demos)
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
    COMMENT = 'DEMO: Repository for example/demo projects - NOT FOR PRODUCTION | Author: SE Community';

-- Create schema for Git repository
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS
    COMMENT = 'DEMO: Data Quality Metrics Demo - Git repositories and deployment objects | Author: SE Community | Expires: 2025-12-31';

-- Create Git Repository stage
CREATE OR REPLACE GIT REPOSITORY SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo
    API_INTEGRATION = SFE_DATAQUALITY_GIT_API_INTEGRATION
    ORIGIN = 'https://github.com/sfc-gh-miwhitaker/dataquality'
    COMMENT = 'DEMO: Data Quality Metrics Demo - Source repository for deployment scripts | Author: SE Community | Expires: 2025-12-31';

-- Fetch latest from repository
ALTER GIT REPOSITORY SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo FETCH;

-- Verify Git repository is accessible
SHOW GIT BRANCHES IN SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo;

-- ============================================================================
-- SECTION 3: Warehouse Setup
-- ============================================================================

-- Create dedicated warehouse (must exist BEFORE executing scripts)
CREATE WAREHOUSE IF NOT EXISTS SFE_DATAQUALITY_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'DEMO: Data Quality Metrics Demo - Dedicated compute for demo workloads | Author: SE Community | Expires: 2025-12-31';

-- Set warehouse context for all subsequent operations
USE WAREHOUSE SFE_DATAQUALITY_WH;

-- ============================================================================
-- SECTION 4: Execute Deployment Scripts from Git
-- 
-- Pattern: EXECUTE IMMEDIATE FROM @database.schema.git_repo/branches/main/path/to/file.sql
-- ============================================================================

-- 4.1 Setup Scripts
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/01_setup/01_create_database.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/01_setup/02_create_schemas.sql;

-- 4.2 Data Scripts
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/02_data/01_create_tables.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/02_data/02_load_sample_data.sql;

-- 4.3 Transformation Scripts
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/03_transformations/01_create_views.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/03_transformations/02_create_dynamic_tables.sql;

-- 4.4 Data Quality Scripts
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/04_data_quality/01_associate_dmfs.sql;

-- 4.5 Streamlit Deployment
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/05_streamlit/01_create_dashboard.sql;

-- ============================================================================
-- DEPLOYMENT COMPLETE
-- ============================================================================

SELECT 
    '✅ Deployment Complete!' AS status,
    'Demo: Data Quality Metrics Demo' AS project,
    'Expires: 2025-12-31' AS expiration,
    'Next: Open Streamlit Apps > SFE_DATA_QUALITY_DASHBOARD' AS next_steps;

-- Show created objects for verification
SHOW DATABASES LIKE 'SNOWFLAKE_EXAMPLE';
SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE LIKE 'SFE_%';
SHOW TABLES IN DATABASE SNOWFLAKE_EXAMPLE;
SHOW DYNAMIC TABLES IN DATABASE SNOWFLAKE_EXAMPLE;
SHOW STREAMLITS IN DATABASE SNOWFLAKE_EXAMPLE;

/*******************************************************************************
 * TROUBLESHOOTING
 ******************************************************************************/

-- If you encounter errors:
-- 1. Check that you have ACCOUNTADMIN role or appropriate grants
-- 2. Verify the GitHub repository is accessible: https://github.com/sfc-gh-miwhitaker/dataquality
-- 3. Review error messages in the output pane
-- 4. Check README.md for additional troubleshooting steps
--
-- To clean up all objects created by this demo:
-- EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/99_cleanup/teardown_all.sql;

