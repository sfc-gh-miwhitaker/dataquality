/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Create Schemas
 * 
 * PURPOSE:
 *   Creates the three-layer schema architecture for the data quality demo:
 *   - RAW: Landing zone for raw data with quality issues
 *   - STG: Staging area for cleaned/validated data
 *   - ANALYTICS: Analytics layer with metrics, dashboards, and reporting
 * 
 * OBJECTS CREATED:
 *   - SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE schema
 *   - SNOWFLAKE_EXAMPLE.SFE_STG_REALESTATE schema
 *   - SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE schema
 * 
 * Author: SE Community | Expires: 2025-12-31
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

-- Raw data landing layer
-- Contains data with intentional quality issues for demo purposes
CREATE SCHEMA IF NOT EXISTS SFE_RAW_REALESTATE
    COMMENT = 'DEMO: Data Quality Metrics - Raw data landing zone with quality issues | Author: SE Community | Expires: 2025-12-31';

-- Staging/transformation layer
-- Contains cleaned and validated data
CREATE SCHEMA IF NOT EXISTS SFE_STG_REALESTATE
    COMMENT = 'DEMO: Data Quality Metrics - Staging layer with cleaned data | Author: SE Community | Expires: 2025-12-31';

-- Analytics layer
-- Contains metrics, dashboards, dynamic tables, and Streamlit apps
CREATE SCHEMA IF NOT EXISTS SFE_ANALYTICS_REALESTATE
    COMMENT = 'DEMO: Data Quality Metrics - Analytics layer with quality metrics and dashboards | Author: SE Community | Expires: 2025-12-31';

-- Verify creation
SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE LIKE 'SFE_%REALESTATE%';

