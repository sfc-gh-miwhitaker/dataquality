# Network Flow - Data Quality Metrics Demo

Author: SE Community
Last Updated: 2026-01-06
Expires: 2026-02-05 (30 days from creation)
Status: Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

**Reference Implementation:** This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment. Not for production use.

## Overview

This diagram shows the network architecture and connectivity between external systems (GitHub, users) and Snowflake components including Git integration, compute layer, storage, and applications.

## Diagram

```mermaid
graph TB
    subgraph External["External Systems"]
        GH[Git Repository (Public)]
        User[End Users<br/>via Browser]
    end

    subgraph Snowflake["Snowflake Platform"]
        subgraph Integration["Integration Layer"]
            API[SFE_DATAQUALITY_GIT_API_INTEGRATION<br/>API_PROVIDER: git_https_api]
            GIT[(Git Repository Object<br/>DATAQUALITY_REPO)]
        end

        subgraph Compute["Compute Layer"]
            WH[SFE_DATAQUALITY_WH<br/>XSMALL Warehouse]
        end

        subgraph Storage["Storage - SNOWFLAKE_EXAMPLE"]
            DB[(SNOWFLAKE_EXAMPLE<br/>Database)]
            PRJ[DATAQUALITY_METRICS<br/>Schema]
        end

        subgraph Apps["Application Layer"]
            SIS[Streamlit in Snowflake<br/>DATA_QUALITY_DASHBOARD]
        end
    end

    GH -->|HTTPS :443| API
    API --> GIT
    GIT -->|EXECUTE IMMEDIATE FROM| WH
    WH --> DB
    DB --> PRJ
    User -->|HTTPS :443| SIS
    SIS --> WH
    WH --> PRJ
```

## Component Descriptions

### GitHub Repository
- **Purpose:** Source code repository for SQL scripts, Streamlit app, and documentation
- **Technology:** GitHub public repository
- **Dependencies:** None

### End Users
- **Purpose:** Data analysts and business users accessing the dashboard
- **Technology:** Web browser
- **Location:** External network
- **Dependencies:** Snowflake account access

### SFE_DATAQUALITY_GIT_API_INTEGRATION
- **Purpose:** Secure connection between Snowflake and GitHub
- **Technology:** Snowflake API Integration (git_https_api)
- **Location:** Account-level object
- **Dependencies:** GitHub repository access

### Git Repository Object (DATAQUALITY_REPO)
- **Purpose:** Snowflake representation of the GitHub repository
- **Technology:** Snowflake Git Repository
- **Location:** `SNOWFLAKE_EXAMPLE.GIT_REPOS`
- **Dependencies:** API Integration

### SFE_DATAQUALITY_WH
- **Purpose:** Dedicated compute for demo workloads
- **Technology:** Snowflake Virtual Warehouse (XSMALL)
- **Location:** Account-level object
- **Dependencies:** None

### SNOWFLAKE_EXAMPLE Database
- **Purpose:** Container for all demo schemas and objects
- **Technology:** Snowflake Database
- **Location:** Account-level object
- **Dependencies:** None

### Streamlit Dashboard
- **Purpose:** Interactive data quality monitoring UI
- **Technology:** Streamlit in Snowflake
- **Location:** `SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS`
- **Dependencies:** Warehouse, Analytics views

## Network Protocols

| Connection | Protocol | Port | Authentication |
|------------|----------|------|----------------|
| GitHub to Snowflake | HTTPS | 443 | API Integration |
| User to Snowsight | HTTPS | 443 | Snowflake Auth |
| User to Streamlit | HTTPS | 443 | Snowflake Auth |

## Change History

See repository history for version changes.
