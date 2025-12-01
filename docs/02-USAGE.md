# Usage Guide - Data Quality Metrics Demo

Author: SE Community  
Last Updated: 2025-12-01  
Expires: 2025-12-31 (30 days from creation)

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

## Overview

This guide explains how to use the Data Quality Metrics demo to monitor data quality, identify issues, and remediate problems.

---

## Accessing the Dashboard

### Via Snowsight

1. Open Snowsight (https://app.snowflake.com)
2. Navigate to **Apps** > **Streamlit**
3. Click **SFE_DATA_QUALITY_DASHBOARD**

### Direct URL

The dashboard URL follows this pattern:
```
https://<account>.snowflakecomputing.com/streamlit-apps/<database>.<schema>.<app_name>
```

---

## Dashboard Features

### Quality Score Overview

The main dashboard displays:
- **Overall Quality Score** - Percentage of records passing all checks
- **Trend Indicator** - Arrow showing improvement or degradation
- **Last Updated** - Timestamp of most recent DMF execution

### Issue Breakdown

View quality issues by category:
- **NULL Values** - Missing data in required fields
- **Blank Values** - Empty strings in text fields
- **Duplicates** - Repeated records by listing_id

### Drill-Down Views

Click any category to see:
- Affected columns
- Record counts
- Sample failing records

---

## Working with Data Metric Functions

### View DMF Results

Query the results table directly:

```sql
SELECT 
    table_name,
    column_name,
    metric_name,
    metric_value,
    execution_time
FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DQ_METRIC_RESULTS
ORDER BY execution_time DESC
LIMIT 100;
```

### Get Failing Records

Use SYSTEM$DATA_METRIC_SCAN to retrieve actual failing records:

```sql
-- Get records with NULL prices
SELECT * FROM TABLE(SYSTEM$DATA_METRIC_SCAN(
    REF_ENTITY_NAME => 'SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS',
    METRIC_NAME => 'SNOWFLAKE.CORE.NULL_COUNT',
    ARGUMENT_NAME => 'PRICE'
));

-- Get records with blank property types
SELECT * FROM TABLE(SYSTEM$DATA_METRIC_SCAN(
    REF_ENTITY_NAME => 'SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS',
    METRIC_NAME => 'SNOWFLAKE.CORE.BLANK_COUNT',
    ARGUMENT_NAME => 'PROPERTY_TYPE'
));

-- Get duplicate listing IDs
SELECT * FROM TABLE(SYSTEM$DATA_METRIC_SCAN(
    REF_ENTITY_NAME => 'SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS',
    METRIC_NAME => 'SNOWFLAKE.CORE.DUPLICATE_COUNT',
    ARGUMENT_NAME => 'LISTING_ID'
));
```

### Manual DMF Execution

Trigger DMF evaluation manually:

```sql
-- Run NULL_COUNT on price column
SELECT SNOWFLAKE.CORE.NULL_COUNT(
    SELECT PRICE FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
);

-- Run BLANK_COUNT on property_type column
SELECT SNOWFLAKE.CORE.BLANK_COUNT(
    SELECT PROPERTY_TYPE FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
);

-- Run DUPLICATE_COUNT on listing_id column
SELECT SNOWFLAKE.CORE.DUPLICATE_COUNT(
    SELECT LISTING_ID FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
);
```

---

## Remediation Workflows

### Fix NULL Values

Update records with NULL prices using median value:

```sql
-- Calculate median price by market area
WITH median_prices AS (
    SELECT 
        market_area,
        MEDIAN(price) AS median_price
    FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
    WHERE price IS NOT NULL
    GROUP BY market_area
)
UPDATE SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS t
SET price = m.median_price
FROM median_prices m
WHERE t.market_area = m.market_area
  AND t.price IS NULL;

-- Log the remediation action
INSERT INTO SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DQ_REMEDIATION_LOG
(action_taken, records_affected, remediated_by, remediated_at)
VALUES ('Fixed NULL prices with median by market_area', 
        (SELECT COUNT(*) FROM TABLE(SYSTEM$DATA_METRIC_SCAN(...))),
        CURRENT_USER(),
        CURRENT_TIMESTAMP());
```

### Fix Blank Values

Replace blank property types with 'Unknown':

```sql
UPDATE SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
SET property_type = 'Unknown'
WHERE property_type IS NULL OR TRIM(property_type) = '';
```

### Remove Duplicates

Keep only the most recent version of duplicate records:

```sql
DELETE FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
WHERE listing_id IN (
    SELECT listing_id 
    FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
    QUALIFY ROW_NUMBER() OVER (PARTITION BY listing_id ORDER BY updated_at DESC) > 1
);
```

---

## Dynamic Tables

### Monitor Refresh Status

Check Dynamic Table refresh status:

```sql
SELECT 
    name,
    refresh_mode,
    target_lag,
    last_completed_refresh_time,
    next_scheduled_refresh_time
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY(
    NAME_PREFIX => 'SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DT_'
))
ORDER BY last_completed_refresh_time DESC;
```

### Force Refresh

Manually trigger a refresh:

```sql
ALTER DYNAMIC TABLE SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DT_QUALITY_SUMMARY REFRESH;
ALTER DYNAMIC TABLE SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DT_MARKET_TRENDS REFRESH;
```

---

## Sample Queries

### Quality Trends Over Time

```sql
SELECT 
    DATE_TRUNC('hour', execution_time) AS hour,
    metric_name,
    AVG(metric_value) AS avg_issues
FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DQ_METRIC_RESULTS
GROUP BY 1, 2
ORDER BY 1 DESC;
```

### Market Area Quality Comparison

```sql
SELECT 
    market_area,
    COUNT(*) AS total_listings,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_prices,
    SUM(CASE WHEN TRIM(property_type) = '' THEN 1 ELSE 0 END) AS blank_types,
    ROUND(100.0 - (SUM(CASE WHEN price IS NULL OR TRIM(property_type) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS quality_score
FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS
GROUP BY market_area
ORDER BY quality_score ASC;
```

### Remediation History

```sql
SELECT 
    action_taken,
    records_affected,
    remediated_by,
    remediated_at
FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DQ_REMEDIATION_LOG
ORDER BY remediated_at DESC;
```

---

## Next Steps

- **Deploy to Production** - Adapt patterns for your data
- **Add Custom DMFs** - Create organization-specific quality checks
- **Schedule Remediation** - Use Tasks for automated fixes
- **Clean Up Demo** - See `docs/03-CLEANUP.md`

---

*Generated by builddemo | SE Community | 2025-12-01*

