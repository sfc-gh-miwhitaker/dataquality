# Data Model - Data Quality Metrics Demo

Author: SE Community
Last Updated: 2026-01-06
Expires: 2026-02-05 (30 days from creation)
Status: Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

**Reference Implementation:** This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment. Not for production use.

## Overview

This diagram shows the database schema and table relationships for the Data Quality Metrics demo. The model includes raw property data landing tables, staged/cleaned data, quality metric results storage, and remediation tracking.

## Diagram

```mermaid
erDiagram
    RAW_PROPERTY_LISTINGS ||--o{ STG_PROPERTY_LISTINGS : transforms
    STG_PROPERTY_LISTINGS ||--o{ STG_MARKET_METRICS : aggregates
    RAW_PROPERTY_LISTINGS ||--o{ DQ_METRIC_RESULTS : monitored_by
    DQ_METRIC_RESULTS ||--o{ DQ_REMEDIATION_LOG : tracks

    RAW_PROPERTY_LISTINGS {
        int listing_id PK
        string address
        string city
        string state
        string zip_code
        string property_type
        decimal price
        int bedrooms
        int bathrooms
        int sqft
        string market_area
        string listing_status
        timestamp created_at
        timestamp updated_at
    }

    STG_PROPERTY_LISTINGS {
        int listing_id PK
        string address_clean
        string city
        string state
        string zip_code
        string property_type
        decimal price_validated
        int bedrooms
        int bathrooms
        int sqft
        string market_area
        string listing_status
        boolean is_valid
        timestamp processed_at
    }

    STG_MARKET_METRICS {
        string market_area PK
        string metric_month PK
        decimal avg_price
        decimal median_price
        int total_listings
        int new_listings
        decimal price_per_sqft
        timestamp calculated_at
    }

    DQ_METRIC_RESULTS {
        int result_id PK
        string table_name
        string column_name
        string metric_name
        int metric_value
        timestamp scheduled_time
        timestamp execution_time
    }

    DQ_REMEDIATION_LOG {
        int log_id PK
        int result_id FK
        string action_taken
        int records_affected
        string remediated_by
        timestamp remediated_at
    }
```

## Component Descriptions

### RAW_PROPERTY_LISTINGS
- **Purpose:** Raw data landing table for property listings with intentional quality issues for demo purposes
- **Technology:** Snowflake standard table
- **Location:** `SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS`
- **Dependencies:** Sample data generator

### STG_PROPERTY_LISTINGS
- **Purpose:** Cleaned and validated property data after transformation
- **Technology:** Snowflake standard table
- **Location:** `SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS`
- **Dependencies:** RAW_PROPERTY_LISTINGS

### STG_MARKET_METRICS
- **Purpose:** Monthly aggregated market statistics by area
- **Technology:** Snowflake standard table
- **Location:** `SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS`
- **Dependencies:** STG_PROPERTY_LISTINGS

### DQ_METRIC_RESULTS
- **Purpose:** Storage for DMF execution results and quality scores
- **Technology:** Snowflake standard table
- **Location:** `SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS`
- **Dependencies:** DMF associations on RAW_PROPERTY_LISTINGS

### DQ_REMEDIATION_LOG
- **Purpose:** Audit trail for remediation actions taken on quality issues
- **Technology:** Snowflake standard table
- **Location:** `SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS`
- **Dependencies:** DQ_METRIC_RESULTS

## Change History

See repository history for version changes.
