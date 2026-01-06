# Cleanup Guide - Data Quality Metrics Demo

Author: SE Community
Last Updated: 2026-01-06
Expires: 2026-02-05 (30 days from creation)

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

## Overview

This guide explains how to remove all objects created by the Data Quality Metrics demo.

**Estimated Time:** 2 minutes

---

## Quick Cleanup (Recommended)

### Option 1: Execute Cleanup Script from Git

```sql
USE WAREHOUSE SFE_DATAQUALITY_WH;

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.DATAQUALITY_REPO/branches/main/sql/99_cleanup/teardown_all.sql;
```

### Option 2: Run Individual Cleanup Commands

```sql
-- Step 1: Drop project schemas (preserves SNOWFLAKE_EXAMPLE database)
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS CASCADE;

-- Step 1b: Drop Git repository object (do not drop SNOWFLAKE_EXAMPLE.GIT_REPOS schema)
DROP GIT REPOSITORY IF EXISTS SNOWFLAKE_EXAMPLE.GIT_REPOS.DATAQUALITY_REPO;

-- Step 2: Drop warehouse
DROP WAREHOUSE IF EXISTS SFE_DATAQUALITY_WH;

-- Step 3: Drop API integration (only if not used by other demos)
-- Check first: SHOW API INTEGRATIONS LIKE 'SFE_%';
DROP API INTEGRATION IF EXISTS SFE_DATAQUALITY_GIT_API_INTEGRATION;
```

---

## What Gets Removed

### Schemas Dropped

| Schema | Objects Removed |
|--------|-----------------|
| DATAQUALITY_METRICS | All demo tables, views, dynamic tables, Streamlit app |
| GIT_REPOS | Git repository object reference (DATAQUALITY_REPO only) |

### Account-Level Objects Dropped

| Object Type | Name |
|-------------|------|
| Warehouse | SFE_DATAQUALITY_WH |
| API Integration | SFE_DATAQUALITY_GIT_API_INTEGRATION |

### What Is Preserved

| Object | Reason |
|--------|--------|
| SNOWFLAKE_EXAMPLE database | Shared across demos |
| SNOWFLAKE_EXAMPLE.GIT_REPOS schema | Shared infrastructure across demos |
| Other demo schemas | May belong to other demos |
| Other SFE_* API integrations | May be used by other projects |

---

## Verification

After cleanup, verify objects are removed:

```sql
-- Check schemas are gone
SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE LIKE 'DATAQUALITY_%';
-- Expected: No results

-- Check warehouse is gone
SHOW WAREHOUSES LIKE 'SFE_DATAQUALITY%';
-- Expected: No results

-- Check API integration is gone
SHOW API INTEGRATIONS LIKE 'SFE_DATAQUALITY%';
-- Expected: No results
```

---

## Partial Cleanup Options

### Remove Only Data (Keep Structure)

```sql
-- Truncate tables but keep schema
TRUNCATE TABLE SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS.RAW_PROPERTY_LISTINGS;
TRUNCATE TABLE SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS.STG_PROPERTY_LISTINGS;
TRUNCATE TABLE SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS.STG_MARKET_METRICS;
TRUNCATE TABLE SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS.DQ_METRIC_RESULTS;
TRUNCATE TABLE SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS.DQ_REMEDIATION_LOG;
```

### Suspend Warehouse Only

```sql
-- Suspend to stop charges but keep configuration
ALTER WAREHOUSE SFE_DATAQUALITY_WH SUSPEND;
```

### Remove Streamlit Only

```sql
DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.DATAQUALITY_METRICS.DATA_QUALITY_DASHBOARD;
```

---

## Troubleshooting

### Error: "Object does not exist"

The object may have already been removed or never created.

**Solution:** Ignore the error and continue with remaining cleanup.

### Error: "Insufficient privileges"

Your role lacks DROP permissions.

**Solution:** Use ACCOUNTADMIN:
```sql
USE ROLE ACCOUNTADMIN;
-- Then retry cleanup
```

### API Integration Still Needed

Other demos may use the same integration.

**Solution:** Check usage before dropping:
```sql
-- List all Git repos using this integration
SHOW GIT REPOSITORIES;
-- If others exist, skip dropping the integration
```

---

## Re-Deploying After Cleanup

To redeploy after cleanup:

1. Follow `docs/01-DEPLOYMENT.md`
2. Or simply re-run `deploy_all.sql`

All objects will be recreated with fresh sample data.

---
