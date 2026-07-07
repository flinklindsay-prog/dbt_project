# Bakehouse Analytics Pipeline

A production-style dbt pipeline built on Databricks against the Bakehouse sample dataset. The goal was to demonstrate how I'd design a KPI reporting layer that scales as new data arrives daily, not just a one-time analysis.

## Architecture

The pipeline follows a standard three-layer dbt structure:

```
staging  →  intermediate  →  marts
```

**Staging (`models/staging/`)**
One model per source table. Each model does light cleanup only: type casting, column renaming, no business logic. This keeps the raw-to-clean boundary explicit and makes every downstream model resilient to source schema drift.

- `stg_bakehouse__sales_transactions`
- `stg_bakehouse__sales_franchises`
- `stg_bakehouse__sales_customers`
- `stg_bakehouse__sales_suppliers`
- `stg_bakehouse__media_customer_reviews`

**Intermediate (`models/intermediate/`)**
`int_transactions_enriched` joins transactions to franchise, supplier, and city context. This is the single denormalized table that every downstream metric pulls from, so join logic lives in one place instead of being repeated across marts.

**Marts (`models/marts/`)**
`fct_daily_kpi_snapshot` is the reporting layer: a long-format, incrementally materialized table that captures KPI values per day.

## Why long format

Instead of one column per metric, the snapshot table is shaped as:

```
metric_date | metric_name | dimension | dimension_value | metric_value
```

This means adding a new KPI is a matter of adding a CTE and a `union all`, not restructuring the table or touching every downstream query. A dashboard or BI tool can filter on `metric_name` and `dimension` without needing schema changes as the KPI list grows. For a company where the data domain spans finance, ops, and customer experience, this keeps one table serving all three audiences instead of maintaining separate marts per team.

## Why incremental

The assessment prompt calls out that more data arrives daily. The snapshot table is built with `is_incremental()` logic that only recomputes dates newer than what's already in the table, using a composite unique key on `(metric_date, metric_name, dimension, dimension_value)` so reruns merge safely instead of duplicating rows. This is the same pattern I'd reach for in production: cheap daily runs, full historical trend without full recomputation, and safe to rerun on failure.

## KPIs included

- **Revenue by franchise** – daily revenue rolled up per franchise
- **Average order value by franchise** – daily AOV per franchise
- **Company-wide revenue** – total daily revenue across all franchises
- **Revenue by supplier** – daily revenue attributed through the franchise-to-supplier relationship, a proxy for supplier concentration risk

These were chosen to span three stakeholder lenses (finance, ops, supply chain) from a single model, which is the kind of cross-domain reporting a lean team needs without dedicating an analyst to each function.

## What I'd add next

- Review sentiment as a trended KPI, joined in from `media_customer_reviews`
- dbt tests on the snapshot grain (`unique`, `not_null` on the composite key) and on source freshness
- A BI dashboard layer reading directly from `fct_daily_kpi_snapshot`
- Documentation (`schema.yml` descriptions) for every model and column

## Running the project

```bash
dbt deps
dbt run
dbt test
```

Connects to a Databricks SQL warehouse via the `dbt-databricks` adapter, reading from `samples.bakehouse`.


## What I would do with more time:
- Set up tests on the models
- Obfuscate credit card numbers
