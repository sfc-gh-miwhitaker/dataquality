# Data Flow - Data Quality Metrics Demo

Author: SE Community
Last Updated: 2026-01-06
Expires: 2026-02-05 (30 days from creation)
Status: Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

**Reference Implementation:** This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment. Not for production use.

## Overview

This diagram shows how data flows through the system from source ingestion through quality monitoring, transformation, and analytics to final consumption via the Streamlit dashboard.

## Diagram

```mermaid
graph TB
    subgraph Sources["Source Systems"]
        S1[Property Listings API]
        S2[Market Data Feed]
        S3[Sample Data Generator]
    end

    subgraph Ingestion["Ingestion Layer - DATAQUALITY_METRICS"]
        I1[(RAW_PROPERTY_LISTINGS)]
    end

    subgraph Quality["Quality Layer"]
        Q1{DMF: NULL_COUNT}
        Q2{DMF: BLANK_COUNT}
        Q3{DMF: DUPLICATE_COUNT}
        Q4[(DQ_METRIC_RESULTS)]
    end

    subgraph Staging["Staging Layer - DATAQUALITY_METRICS"]
        T1[Data Cleaning]
        T2[Type Validation]
        T3[(STG_PROPERTY_LISTINGS)]
        T4[(STG_MARKET_METRICS)]
    end

    subgraph Analytics["Analytics Layer - DATAQUALITY_METRICS"]
        DT1[/DT_QUALITY_SUMMARY\]
        DT2[/DT_MARKET_TRENDS\]
        V1[V_QUALITY_DASHBOARD]
    end

    subgraph Consumption["Consumption Layer"]
        ST[DATA_QUALITY_DASHBOARD]
        REM[Remediation Workflows]
    end

    S1 -->|Raw JSON| I1
    S2 -->|CSV| I1
    S3 -->|Synthetic Data| I1

    I1 --> Q1
    I1 --> Q2
    I1 --> Q3
    Q1 --> Q4
    Q2 --> Q4
    Q3 --> Q4

    I1 --> T1
    T1 --> T2
    T2 --> T3
    T3 --> T4

    T3 --> DT1
    T4 --> DT2
    Q4 --> DT1
    DT1 --> V1
    DT2 --> V1

    V1 --> ST
    Q4 --> REM
```

## Component Descriptions

### Source Systems
- **Purpose:** External data sources that provide property listings and market data
- **Technology:** APIs, CSV feeds, synthetic data generators
- **Location:** External to Snowflake
- **Dependencies:** None

### Ingestion Layer (DATAQUALITY_METRICS)
- **Purpose:** Raw data landing zone preserving original data format
- **Technology:** Snowflake standard tables
- **Location:** `SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS`
- **Dependencies:** Source systems

### Quality Layer
- **Purpose:** Automated data quality monitoring using system DMFs
- **Technology:** Snowflake Data Metric Functions
- **Location:** Associated with RAW_PROPERTY_LISTINGS
- **Dependencies:** Raw tables

### Staging Layer (DATAQUALITY_METRICS)
- **Purpose:** Data cleaning, validation, and transformation
- **Technology:** Snowflake standard tables
- **Location:** `SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS`
- **Dependencies:** Raw tables

### Analytics Layer (DATAQUALITY_METRICS)
- **Purpose:** Real-time analytics via Dynamic Tables and Views
- **Technology:** Dynamic Tables with TARGET_LAG
- **Location:** `SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS`
- **Dependencies:** Staging tables, DQ results

### Consumption Layer
- **Purpose:** User-facing Streamlit dashboard and remediation workflows
- **Technology:** Streamlit in Snowflake
- **Location:** `SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS`
- **Dependencies:** Analytics views

## Data Transformations

| Stage | Input | Transformation | Output |
|-------|-------|----------------|--------|
| Ingest | Source APIs | Raw capture | RAW_PROPERTY_LISTINGS |
| Monitor | Raw tables | DMF evaluation | DQ_METRIC_RESULTS |
| Clean | Raw data | Null handling, type casting | STG_PROPERTY_LISTINGS |
| Aggregate | Staged data | Monthly grouping | STG_MARKET_METRICS |
| Analyze | All layers | Dynamic aggregation | DT_QUALITY_SUMMARY |
| Present | Analytics | View composition | V_QUALITY_DASHBOARD |

## Change History

See repository history for version changes.
