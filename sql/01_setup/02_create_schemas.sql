/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Create Schemas
 *
 * PURPOSE:
 *   Creates the project schema for the data quality demo. Table naming encodes
 *   the layered architecture:
 *   - RAW_*: landing zone for raw data with quality issues
 *   - STG_*: cleaned/validated tables
 *   - DQ_* / V_* / DT_*: metrics, views, and dynamic tables for reporting
 *
 * OBJECTS CREATED:
 *   - SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS schema
 *
 * Author: SE Community | Expires: 2026-02-05
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE SCHEMA IF NOT EXISTS DATAQUALITY_METRICS
    COMMENT = 'DEMO: Data Quality Metrics - Project schema (RAW_*, STG_*, DQ_*, V_*, DT_*) | Author: SE Community | Expires: 2026-02-05';

-- Verify creation
SELECT
    SCHEMA_NAME,
    CREATED,
    COMMENT
FROM INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'DATAQUALITY_METRICS';
