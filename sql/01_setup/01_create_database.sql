/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Create Database
 * 
 * PURPOSE:
 *   Creates or ensures SNOWFLAKE_EXAMPLE database exists for demo objects.
 *   This database is shared across multiple demo projects.
 * 
 * OBJECTS CREATED:
 *   - SNOWFLAKE_EXAMPLE database (if not exists)
 * 
 * Author: SE Community | Expires: 2025-12-31
 ******************************************************************************/

-- Create shared demo database (preserves existing if present)
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
    COMMENT = 'DEMO: Repository for example/demo projects - NOT FOR PRODUCTION | Author: SE Community';

-- Verify creation
SELECT 
    'Database ready' AS status,
    CURRENT_DATABASE() AS current_db;

