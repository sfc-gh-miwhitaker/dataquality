# Deployment Guide - Data Quality Metrics Demo

Author: SE Community  
Last Updated: 2025-12-01  
Expires: 2025-12-31 (30 days from creation)

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

## Overview

This guide covers deploying the Data Quality Metrics demo to your Snowflake account.

**Estimated Time:** 10 minutes

---

## Prerequisites

### Required Privileges

You need one of the following:
- ACCOUNTADMIN role, OR
- A custom role with these grants:
  - CREATE DATABASE
  - CREATE WAREHOUSE
  - CREATE API INTEGRATION
  - EXECUTE TASK (for scheduled DMFs)

### Snowflake Edition

This demo works with all Snowflake editions:
- **Standard:** Full functionality
- **Enterprise:** Additional governance features available
- **Business Critical:** Enhanced security options

---

## Deployment Method 1: One-Click Deploy (Recommended)

### Step 1: Open Snowsight

Navigate to https://app.snowflake.com and sign in to your account.

### Step 2: Create New Worksheet

Click **+ Worksheet** or use keyboard shortcut.

### Step 3: Copy Deploy Script

Open `deploy_all.sql` from this repository and copy the entire contents.

### Step 4: Paste and Run

Paste the script into your worksheet and click **Run All** (or Ctrl/Cmd + Shift + Enter).

### Step 5: Monitor Progress

Watch the output pane for:
- ✅ Git repository created
- ✅ Database and schemas created
- ✅ Tables created and populated
- ✅ DMF associations configured
- ✅ Dynamic tables created
- ✅ Streamlit dashboard deployed

### Step 6: Access Dashboard

Navigate to **Apps** > **Streamlit** > **SFE_DATA_QUALITY_DASHBOARD**

---

## Deployment Method 2: Manual Step-by-Step

If you prefer granular control:

### Step 1: Create API Integration

```sql
CREATE OR REPLACE API INTEGRATION SFE_DATAQUALITY_GIT_API_INTEGRATION
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-miwhitaker/')
  ENABLED = TRUE;
```

### Step 2: Create Database and Git Repository

```sql
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS;

CREATE OR REPLACE GIT REPOSITORY SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo
  API_INTEGRATION = SFE_DATAQUALITY_GIT_API_INTEGRATION
  ORIGIN = 'https://github.com/sfc-gh-miwhitaker/dataquality';
```

### Step 3: Create Warehouse

```sql
CREATE WAREHOUSE IF NOT EXISTS SFE_DATAQUALITY_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

USE WAREHOUSE SFE_DATAQUALITY_WH;
```

### Step 4: Execute Setup Scripts

```sql
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/01_setup/01_create_database.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/01_setup/02_create_schemas.sql;
```

### Step 5: Execute Data Scripts

```sql
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/02_data/01_create_tables.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/02_data/02_load_sample_data.sql;
```

### Step 6: Execute Transformation Scripts

```sql
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/03_transformations/01_create_views.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/03_transformations/02_create_dynamic_tables.sql;
```

### Step 7: Configure DMFs

```sql
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/04_data_quality/01_associate_dmfs.sql;
```

### Step 8: Deploy Streamlit

```sql
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.DATAQUALITY_GIT_REPOS.sfe_dataquality_repo/branches/main/sql/05_streamlit/01_create_dashboard.sql;
```

---

## Verification

After deployment, verify the installation:

```sql
-- Check schemas created
SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE;

-- Check tables created
SHOW TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE;
SHOW TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.SFE_STG_REALESTATE;
SHOW TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE;

-- Check dynamic tables
SHOW DYNAMIC TABLES IN DATABASE SNOWFLAKE_EXAMPLE;

-- Check Streamlit app
SHOW STREAMLITS IN DATABASE SNOWFLAKE_EXAMPLE;

-- Verify sample data
SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.SFE_RAW_REALESTATE.SFE_RAW_PROPERTY_LISTINGS;
-- Expected: ~50,000 rows
```

---

## Troubleshooting

### Error: "API Integration already exists"

Another demo may have created an integration with the same name.

**Solution:** Use the existing integration or drop it first:
```sql
DROP API INTEGRATION IF EXISTS SFE_DATAQUALITY_GIT_API_INTEGRATION;
```

### Error: "Insufficient privileges"

Your role lacks required permissions.

**Solution:** Use ACCOUNTADMIN or request grants:
```sql
USE ROLE ACCOUNTADMIN;
-- Then re-run deployment
```

### Error: "Git repository not accessible"

Network connectivity issue or incorrect URL.

**Solution:** Verify the repository is accessible:
1. Open https://github.com/sfc-gh-miwhitaker/dataquality in a browser
2. Check if the repository is public
3. Try again after a few minutes

### Dynamic Tables Not Refreshing

Initial refresh may take a few minutes.

**Solution:** Manually trigger refresh:
```sql
ALTER DYNAMIC TABLE SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_REALESTATE.SFE_DT_QUALITY_SUMMARY REFRESH;
```

---

## Next Steps

After successful deployment:

1. **Explore the Dashboard** - `docs/02-USAGE.md`
2. **Run Data Quality Checks** - `docs/02-USAGE.md`
3. **Clean Up When Done** - `docs/03-CLEANUP.md`

---

*Generated by builddemo | SE Community | 2025-12-01*

