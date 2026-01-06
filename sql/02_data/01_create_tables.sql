/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Create Tables
 *
 * PURPOSE:
 *   Creates all tables for the data quality demo including:
 *   - Raw property listings (with intentional quality issues)
 *   - Staged/cleaned property listings
 *   - Market metrics aggregations
 *   - Data quality metric results
 *   - Remediation audit log
 *
 * OBJECTS CREATED:
 *   - DATAQUALITY_METRICS.RAW_PROPERTY_LISTINGS
 *   - DATAQUALITY_METRICS.STG_PROPERTY_LISTINGS
 *   - DATAQUALITY_METRICS.STG_MARKET_METRICS
 *   - DATAQUALITY_METRICS.DQ_METRIC_RESULTS
 *   - DATAQUALITY_METRICS.DQ_REMEDIATION_LOG
 *
 * Author: SE Community | Expires: 2026-02-05
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA DATAQUALITY_METRICS;

-- ============================================================================
-- RAW LAYER TABLES
-- ============================================================================

-- Raw property listings table (landing zone with quality issues)
CREATE OR REPLACE TABLE RAW_PROPERTY_LISTINGS (
    listing_id          NUMBER(38,0)        NOT NULL,
    address             VARCHAR(500),
    city                VARCHAR(100),
    state               VARCHAR(50),
    zip_code            VARCHAR(20),
    property_type       VARCHAR(50),
    price               NUMBER(15,2),
    bedrooms            NUMBER(5,0),
    bathrooms           NUMBER(5,1),
    sqft                NUMBER(10,0),
    market_area         VARCHAR(100),
    listing_status      VARCHAR(50),
    listing_date        DATE,
    agent_email         VARCHAR(255),
    agent_phone         VARCHAR(50),
    created_at          TIMESTAMP_NTZ       DEFAULT CURRENT_TIMESTAMP(),
    updated_at          TIMESTAMP_NTZ       DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'DEMO: Raw property listings with intentional quality issues for DMF demonstration | Author: SE Community | Expires: 2026-02-05';

-- ============================================================================
-- STAGING LAYER TABLES
-- ============================================================================

-- Staged/cleaned property listings
CREATE OR REPLACE TABLE STG_PROPERTY_LISTINGS (
    listing_id          NUMBER(38,0)        NOT NULL PRIMARY KEY,
    address_clean       VARCHAR(500)        NOT NULL,
    city                VARCHAR(100)        NOT NULL,
    state               VARCHAR(50)         NOT NULL,
    zip_code            VARCHAR(20),
    property_type       VARCHAR(50)         NOT NULL,
    price_validated     NUMBER(15,2)        NOT NULL,
    bedrooms            NUMBER(5,0),
    bathrooms           NUMBER(5,1),
    sqft                NUMBER(10,0),
    market_area         VARCHAR(100)        NOT NULL,
    listing_status      VARCHAR(50)         NOT NULL,
    listing_date        DATE,
    is_valid            BOOLEAN             DEFAULT TRUE,
    validation_notes    VARCHAR(1000),
    processed_at        TIMESTAMP_NTZ       DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'DEMO: Cleaned and validated property listings | Author: SE Community | Expires: 2026-02-05';

-- Market metrics aggregation table
CREATE OR REPLACE TABLE STG_MARKET_METRICS (
    market_area         VARCHAR(100)        NOT NULL,
    metric_month        DATE                NOT NULL,
    avg_price           NUMBER(15,2),
    median_price        NUMBER(15,2),
    min_price           NUMBER(15,2),
    max_price           NUMBER(15,2),
    total_listings      NUMBER(10,0),
    new_listings        NUMBER(10,0),
    avg_sqft            NUMBER(10,0),
    price_per_sqft      NUMBER(10,2),
    calculated_at       TIMESTAMP_NTZ       DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (market_area, metric_month)
)
COMMENT = 'DEMO: Monthly market metrics by area | Author: SE Community | Expires: 2026-02-05';

-- ============================================================================
-- ANALYTICS LAYER TABLES
-- ============================================================================

-- Data quality metric results storage
CREATE OR REPLACE TABLE DQ_METRIC_RESULTS (
    result_id           NUMBER(38,0)        AUTOINCREMENT PRIMARY KEY,
    table_name          VARCHAR(255)        NOT NULL,
    column_name         VARCHAR(255)        NOT NULL,
    metric_name         VARCHAR(100)        NOT NULL,
    metric_value        NUMBER(38,0),
    metric_percent      NUMBER(10,4),
    threshold_value     NUMBER(38,0),
    is_passing          BOOLEAN,
    scheduled_time      TIMESTAMP_NTZ,
    execution_time      TIMESTAMP_NTZ       DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'DEMO: Storage for DMF execution results | Author: SE Community | Expires: 2026-02-05';

-- Remediation action audit log
CREATE OR REPLACE TABLE DQ_REMEDIATION_LOG (
    log_id              NUMBER(38,0)        AUTOINCREMENT PRIMARY KEY,
    result_id           NUMBER(38,0),
    table_name          VARCHAR(255),
    column_name         VARCHAR(255),
    action_taken        VARCHAR(500)        NOT NULL,
    records_affected    NUMBER(38,0),
    remediated_by       VARCHAR(255)        DEFAULT CURRENT_USER(),
    remediated_at       TIMESTAMP_NTZ       DEFAULT CURRENT_TIMESTAMP(),
    notes               VARCHAR(2000)
)
COMMENT = 'DEMO: Audit trail for data quality remediation actions | Author: SE Community | Expires: 2026-02-05';

-- Verify table creation
SELECT 'Tables' AS layer, COUNT(*) AS table_count
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'DATAQUALITY_METRICS';
