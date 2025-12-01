![Reference Implementation](https://img.shields.io/badge/Reference-Implementation-blue)
![Ready to Run](https://img.shields.io/badge/Ready%20to%20Run-Yes-green)
![Expires](https://img.shields.io/badge/Expires-2025--12--31-orange)
![Status](https://img.shields.io/badge/Status-Active-success)

# Data Quality Metrics Demo

> DEMONSTRATION PROJECT - EXPIRES: 2025-12-31  
> This demo uses Snowflake features current as of December 2025.  
> After expiration, this repository will be archived and made private.

**Author:** SE Community  
**Purpose:** Data quality monitoring, validation, and reporting for real estate analytics  
**Created:** 2025-12-01 | **Expires:** 2025-12-31 (30 days) | **Status:** ACTIVE

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

---

## Reference Implementation Notice

This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

---

## First Time Here?

**Total deployment time: ~10 minutes**

### Quick Start (Recommended)

1. **Open Snowsight** - Navigate to https://app.snowflake.com
2. **Open `deploy_all.sql`** - Copy the entire contents of the file in this repo's root
3. **Create New Worksheet** - Paste the script
4. **Click "Run All"** - Monitor output for completion
5. **Open the Dashboard** - Navigate to Streamlit Apps > SFE_DATA_QUALITY_DASHBOARD

### Manual Step-by-Step

If you prefer to deploy manually:

1. `docs/01-DEPLOYMENT.md` - Prerequisites and detailed setup (5 min)
2. `sql/01_setup/` - Run setup scripts in order
3. `sql/02_data/` - Create tables and load sample data
4. `sql/03_transformations/` - Create views and dynamic tables
5. `sql/04_data_quality/` - Set up DMF associations
6. `sql/05_streamlit/` - Deploy Streamlit dashboard
7. `docs/02-USAGE.md` - Learn how to use the demo

---

## What This Demo Shows

### Data Metric Functions (DMFs)

Automated data quality monitoring using Snowflake's built-in system DMFs:

- **NULL_COUNT** - Detect missing values in critical columns
- **BLANK_COUNT** - Find empty strings in text fields
- **DUPLICATE_COUNT** - Identify duplicate records
- **SYSTEM$DATA_METRIC_SCAN** - Retrieve actual failing records for remediation

### Dynamic Tables

Real-time data refresh with automatic maintenance:

- `SFE_DT_QUALITY_SUMMARY` - Live quality metrics (1-minute lag)
- `SFE_DT_MARKET_TRENDS` - Market analytics aggregations (5-minute lag)

### Streamlit Dashboard

Interactive data quality monitoring interface:

- Quality score KPIs with trend indicators
- Issue breakdown by category
- Drill-down to failing records
- One-click remediation workflows

### Security Features

- **Data Classification** - Automatic tagging of sensitive data
- **Row Access Policies** - Role-based data filtering

---

## Objects Created

### Database Objects (in SNOWFLAKE_EXAMPLE)

| Schema | Object Type | Name | Description |
|--------|-------------|------|-------------|
| SFE_RAW_REALESTATE | Table | SFE_RAW_PROPERTY_LISTINGS | Raw property data with quality issues |
| SFE_STG_REALESTATE | Table | SFE_STG_PROPERTY_LISTINGS | Cleaned property data |
| SFE_STG_REALESTATE | Table | SFE_STG_MARKET_METRICS | Monthly market aggregates |
| SFE_ANALYTICS_REALESTATE | Table | SFE_DQ_METRIC_RESULTS | DMF execution results |
| SFE_ANALYTICS_REALESTATE | Table | SFE_DQ_REMEDIATION_LOG | Remediation tracking |
| SFE_ANALYTICS_REALESTATE | Dynamic Table | SFE_DT_QUALITY_SUMMARY | Real-time quality metrics |
| SFE_ANALYTICS_REALESTATE | Dynamic Table | SFE_DT_MARKET_TRENDS | Market analytics |
| SFE_ANALYTICS_REALESTATE | View | SFE_V_QUALITY_DASHBOARD | Dashboard data view |
| SFE_ANALYTICS_REALESTATE | Streamlit | SFE_DATA_QUALITY_DASHBOARD | Interactive dashboard |

### Account-Level Objects

| Object Type | Name | Description |
|-------------|------|-------------|
| API Integration | SFE_DATAQUALITY_GIT_API_INTEGRATION | GitHub repository access |
| Warehouse | SFE_DATAQUALITY_WH | Dedicated demo compute (XSMALL) |
| Row Access Policy | SFE_RAP_PROPERTY_ACCESS | Role-based data filtering |

---

## Estimated Demo Costs

| Component | Edition | Credits/Hour | Est. Runtime | Est. Cost |
|-----------|---------|--------------|--------------|-----------|
| SFE_DATAQUALITY_WH (XSMALL) | Standard | 1 | 0.5 hours | 0.5 credits |
| Dynamic Table Refresh | Standard | 1 | 0.25 hours | 0.25 credits |
| Streamlit App | Standard | 0.5 | 0.5 hours | 0.25 credits |
| **Total (per demo)** | | | | **~1 credit** |

*Based on Standard Edition pricing ($2/credit). Enterprise/Business Critical pricing may vary.*

---

## Cleanup

To remove all demo objects:

```sql
-- Run cleanup script from Git repository
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/99_cleanup/teardown_all.sql;
```

Or manually:

```sql
-- Drop project schemas (preserves database)
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_STG_REALESTATE CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS CASCADE;

-- Drop warehouse
DROP WAREHOUSE IF EXISTS SFE_DATAQUALITY_WH;

-- Drop API integration (only if not shared)
DROP API INTEGRATION IF EXISTS SFE_DATAQUALITY_GIT_API_INTEGRATION;
```

See `docs/03-CLEANUP.md` for detailed cleanup instructions.

---

## Architecture

See the `diagrams/` directory for:

- `data-model.md` - Database schema and relationships
- `data-flow.md` - Data pipeline and transformations
- `network-flow.md` - Network architecture and connectivity
- `auth-flow.md` - Authentication and authorization flows

---

## Troubleshooting

### Common Issues

**"API Integration already exists"**
- Another demo may be using the same integration name
- Solution: Use the existing integration or drop it first

**"Insufficient privileges"**
- Ensure you have ACCOUNTADMIN role or equivalent grants
- Required: CREATE DATABASE, CREATE WAREHOUSE, CREATE API INTEGRATION

**"Git repository not accessible"**
- Verify the GitHub repository URL is correct and public
- Check network connectivity to github.com

See `docs/03-CLEANUP.md` for additional troubleshooting.

---

## Resources

- [Snowflake Data Quality Documentation](https://docs.snowflake.com/en/user-guide/data-quality)
- [Data Metric Functions Reference](https://docs.snowflake.com/en/sql-reference/functions/data-metric-functions)
- [Dynamic Tables Guide](https://docs.snowflake.com/en/user-guide/dynamic-tables)
- [Streamlit in Snowflake](https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit)

---

*Generated by builddemo | SE Community | 2025-12-01*

