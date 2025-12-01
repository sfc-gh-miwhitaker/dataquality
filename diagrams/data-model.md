# Data Model - Data Quality Metrics Demo

Author: SE Community  
Last Updated: 2025-12-01  
Expires: 2025-12-31 (30 days from creation)  
Status: Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

**Reference Implementation:** This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

## Overview

This diagram shows the database schema and table relationships for the Data Quality Metrics demo. The model includes raw property data landing tables, staged/cleaned data, quality metric results storage, and remediation tracking.

## Diagram

```mermaid
erDiagram
    SFE_RAW_PROPERTY_LISTINGS ||--o{ SFE_STG_PROPERTY_LISTINGS : transforms
    SFE_STG_PROPERTY_LISTINGS ||--o{ SFE_STG_MARKET_METRICS : aggregates
    SFE_STG_PROPERTY_LISTINGS ||--o{ SFE_DQ_METRIC_RESULTS : monitors
    SFE_DQ_METRIC_RESULTS ||--o{ SFE_DQ_REMEDIATION_LOG : tracks
    
    SFE_RAW_PROPERTY_LISTINGS {
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
    
    SFE_STG_PROPERTY_LISTINGS {
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
    
    SFE_STG_MARKET_METRICS {
        string market_area PK
        string metric_month PK
        decimal avg_price
        decimal median_price
        int total_listings
        int new_listings
        decimal price_per_sqft
        timestamp calculated_at
    }
    
    SFE_DQ_METRIC_RESULTS {
        int result_id PK
        string table_name
        string column_name
        string metric_name
        int metric_value
        timestamp scheduled_time
        timestamp execution_time
    }
    
    SFE_DQ_REMEDIATION_LOG {
        int log_id PK
        int result_id FK
        string action_taken
        int records_affected
        string remediated_by
        timestamp remediated_at
    }
```

## Component Descriptions

### SFE_RAW_PROPERTY_LISTINGS
- **Purpose:** Raw data landing table for property listings with intentional quality issues for demo purposes
- **Technology:** Snowflake standard table
- **Location:** `SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE`
- **Dependencies:** Sample data generator

### SFE_STG_PROPERTY_LISTINGS
- **Purpose:** Cleaned and validated property data after transformation
- **Technology:** Snowflake standard table
- **Location:** `SNOWFLAKE_EXAMPLE.SFE_STG_REALESTATE`
- **Dependencies:** SFE_RAW_PROPERTY_LISTINGS

### SFE_STG_MARKET_METRICS
- **Purpose:** Monthly aggregated market statistics by area
- **Technology:** Snowflake standard table
- **Location:** `SNOWFLAKE_EXAMPLE.SFE_STG_REALESTATE`
- **Dependencies:** SFE_STG_PROPERTY_LISTINGS

### SFE_DQ_METRIC_RESULTS
- **Purpose:** Storage for DMF execution results and quality scores
- **Technology:** Snowflake standard table
- **Location:** `SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE`
- **Dependencies:** DMF associations on SFE_RAW_PROPERTY_LISTINGS

### SFE_DQ_REMEDIATION_LOG
- **Purpose:** Audit trail for remediation actions taken on quality issues
- **Technology:** Snowflake standard table
- **Location:** `SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE`
- **Dependencies:** SFE_DQ_METRIC_RESULTS

## Change History

See `.cursor/DIAGRAM_CHANGELOG.md` for version history.

