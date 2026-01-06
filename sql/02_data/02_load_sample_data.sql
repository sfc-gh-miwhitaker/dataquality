/*******************************************************************************
 * DEMO: Data Quality Metrics Demo
 * Script: Load Sample Data
 *
 * PURPOSE:
 *   Loads synthetic sample data into the raw property listings table.
 *   Data includes INTENTIONAL QUALITY ISSUES for DMF demonstration:
 *   - NULL values in price, address, market_area columns
 *   - Blank/empty strings in property_type, listing_status
 *   - Duplicate listing_id values
 *   - Invalid email formats
 *
 * DATA VOLUME:
 *   - ~50,000 property listings
 *   - ~5% NULL prices
 *   - ~3% blank property types
 *   - ~2% duplicate IDs
 *
 * Author: SE Community | Expires: 2026-02-05
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA DATAQUALITY_METRICS;

-- Clear existing data for idempotent re-runs
TRUNCATE TABLE IF EXISTS RAW_PROPERTY_LISTINGS;

-- ============================================================================
-- Generate Sample Data with Quality Issues
-- Uses GENERATOR function for synthetic data creation
-- ============================================================================

INSERT INTO RAW_PROPERTY_LISTINGS (
    listing_id,
    address,
    city,
    state,
    zip_code,
    property_type,
    price,
    bedrooms,
    bathrooms,
    sqft,
    market_area,
    listing_status,
    listing_date,
    agent_email,
    agent_phone,
    created_at,
    updated_at
)
WITH
-- Market areas for realistic distribution
market_areas AS (
    SELECT column1 AS market_area, column2 AS state_code, column3 AS base_price
    FROM VALUES
        ('Phoenix Metro', 'AZ', 450000),
        ('Dallas-Fort Worth', 'TX', 380000),
        ('Denver Metro', 'CO', 550000),
        ('Atlanta Metro', 'GA', 420000),
        ('Tampa Bay', 'FL', 390000),
        ('Las Vegas Valley', 'NV', 410000),
        ('Charlotte Metro', 'NC', 365000),
        ('Nashville Metro', 'TN', 485000),
        ('Austin Metro', 'TX', 520000),
        ('Raleigh-Durham', 'NC', 445000)
),
-- Property types
property_types AS (
    SELECT column1 AS property_type
    FROM VALUES
        ('Single Family'),
        ('Condo'),
        ('Townhouse'),
        ('Multi-Family'),
        ('Land'),
        ('Commercial')
),
-- Listing statuses
listing_statuses AS (
    SELECT column1 AS listing_status
    FROM VALUES
        ('Active'),
        ('Pending'),
        ('Sold'),
        ('Withdrawn'),
        ('Expired')
),
-- Base data generation (50,000 records)
base_data AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY SEQ4()) AS row_num,
        SEQ4() AS seq_val,
        UNIFORM(1, 10, RANDOM()) AS market_idx,
        UNIFORM(1, 6, RANDOM()) AS type_idx,
        UNIFORM(1, 5, RANDOM()) AS status_idx,
        UNIFORM(1, 100, RANDOM()) AS quality_roll,
        UNIFORM(1, 5, RANDOM()) AS bedrooms_val,
        UNIFORM(1.0, 4.0, RANDOM())::NUMBER(5,1) AS bathrooms_val,
        UNIFORM(800, 5000, RANDOM()) AS sqft_val,
        UNIFORM(-180, 180, RANDOM()) AS price_variance,
        DATEADD('day', -UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS listing_dt
    FROM TABLE(GENERATOR(ROWCOUNT => 50000))
)
SELECT
    -- listing_id: Include ~2% duplicates for DUPLICATE_COUNT demo
    CASE
        WHEN b.quality_roll <= 2 THEN FLOOR(b.row_num / 2)  -- Create duplicates
        ELSE b.row_num
    END AS listing_id,

    -- address: Include ~3% NULLs for NULL_COUNT demo
    CASE
        WHEN b.quality_roll <= 3 THEN NULL
        ELSE CONCAT(UNIFORM(100, 9999, RANDOM()), ' ',
             ARRAY_CONSTRUCT('Oak', 'Maple', 'Pine', 'Cedar', 'Elm', 'Birch', 'Willow', 'Aspen')[UNIFORM(0, 7, RANDOM())],
             ' ',
             ARRAY_CONSTRUCT('Street', 'Avenue', 'Drive', 'Lane', 'Court', 'Way', 'Boulevard', 'Circle')[UNIFORM(0, 7, RANDOM())])
    END AS address,

    -- city: Based on market area
    CONCAT(m.market_area, ' City ', UNIFORM(1, 20, RANDOM())) AS city,

    -- state
    m.state_code AS state,

    -- zip_code
    LPAD(UNIFORM(10000, 99999, RANDOM())::VARCHAR, 5, '0') AS zip_code,

    -- property_type: Include ~3% blanks for BLANK_COUNT demo
    CASE
        WHEN b.quality_roll BETWEEN 4 AND 6 THEN ''  -- Blank strings
        WHEN b.quality_roll = 7 THEN '   '           -- Whitespace only
        ELSE p.property_type
    END AS property_type,

    -- price: Include ~5% NULLs for NULL_COUNT demo
    CASE
        WHEN b.quality_roll <= 5 THEN NULL
        ELSE ROUND(m.base_price * (1 + (b.price_variance / 100.0)), -3)
    END AS price,

    -- bedrooms
    b.bedrooms_val AS bedrooms,

    -- bathrooms
    b.bathrooms_val AS bathrooms,

    -- sqft
    b.sqft_val AS sqft,

    -- market_area: Include ~2% NULLs
    CASE
        WHEN b.quality_roll <= 2 THEN NULL
        ELSE m.market_area
    END AS market_area,

    -- listing_status: Include ~2% blanks
    CASE
        WHEN b.quality_roll BETWEEN 8 AND 9 THEN ''
        ELSE s.listing_status
    END AS listing_status,

    -- listing_date
    b.listing_dt AS listing_date,

    -- agent_email: Include ~5% invalid formats
    CASE
        WHEN b.quality_roll <= 5 THEN CONCAT('agent', b.row_num)  -- Missing @ domain
        ELSE CONCAT('agent', b.row_num, '@propertycorp.example')
    END AS agent_email,

    -- agent_phone
    CONCAT('(', UNIFORM(200, 999, RANDOM()), ') ',
           UNIFORM(200, 999, RANDOM()), '-',
           LPAD(UNIFORM(0, 9999, RANDOM())::VARCHAR, 4, '0')) AS agent_phone,

    -- timestamps
    DATEADD('hour', -UNIFORM(1, 720, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at

FROM base_data b
JOIN market_areas m ON ((b.market_idx - 1) % 10) + 1 =
    CASE m.market_area
        WHEN 'Phoenix Metro' THEN 1
        WHEN 'Dallas-Fort Worth' THEN 2
        WHEN 'Denver Metro' THEN 3
        WHEN 'Atlanta Metro' THEN 4
        WHEN 'Tampa Bay' THEN 5
        WHEN 'Las Vegas Valley' THEN 6
        WHEN 'Charlotte Metro' THEN 7
        WHEN 'Nashville Metro' THEN 8
        WHEN 'Austin Metro' THEN 9
        WHEN 'Raleigh-Durham' THEN 10
    END
JOIN property_types p ON ((b.type_idx - 1) % 6) + 1 =
    CASE p.property_type
        WHEN 'Single Family' THEN 1
        WHEN 'Condo' THEN 2
        WHEN 'Townhouse' THEN 3
        WHEN 'Multi-Family' THEN 4
        WHEN 'Land' THEN 5
        WHEN 'Commercial' THEN 6
    END
JOIN listing_statuses s ON ((b.status_idx - 1) % 5) + 1 =
    CASE s.listing_status
        WHEN 'Active' THEN 1
        WHEN 'Pending' THEN 2
        WHEN 'Sold' THEN 3
        WHEN 'Withdrawn' THEN 4
        WHEN 'Expired' THEN 5
    END;

-- ============================================================================
-- Verify Data Quality Issues Exist (for demo purposes)
-- ============================================================================

SELECT
    'Data Quality Summary' AS report,
    COUNT(*) AS total_records,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_prices,
    SUM(CASE WHEN address IS NULL THEN 1 ELSE 0 END) AS null_addresses,
    SUM(CASE WHEN market_area IS NULL THEN 1 ELSE 0 END) AS null_market_areas,
    SUM(CASE WHEN TRIM(property_type) = '' OR property_type IS NULL THEN 1 ELSE 0 END) AS blank_property_types,
    SUM(CASE WHEN TRIM(listing_status) = '' THEN 1 ELSE 0 END) AS blank_statuses,
    COUNT(*) - COUNT(DISTINCT listing_id) AS duplicate_ids
FROM RAW_PROPERTY_LISTINGS;

-- Show sample records
SELECT listing_id, address, city, state, property_type, price, market_area, listing_status
FROM RAW_PROPERTY_LISTINGS
LIMIT 20;
