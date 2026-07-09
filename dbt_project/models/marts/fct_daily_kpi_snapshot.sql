{{
    config(
        materialized='incremental',
        unique_key=['metric_date', 'metric_name', 'dimension', 'dimension_value']
    )
}}

with base as (
    select
        *,
        date_trunc('day', transaction_timestamp) as transaction_date
    from {{ ref('int_transactions_enriched') }}
    {% if is_incremental() %}
    where date_trunc('day', transaction_timestamp) >= (select max(metric_date) from {{ this }})
    {% endif %}
),

revenue_by_franchise as (
    select
        transaction_date as metric_date,
        'revenue' as metric_name,
        'franchise' as dimension,
        cast(franchise_id as string) as dimension_value,
        sum(total_price) as metric_value
    from base
    group by 1, 4
),

aov_by_franchise as (
    select
        transaction_date as metric_date,
        'avg_order_value' as metric_name,
        'franchise' as dimension,
        cast(franchise_id as string) as dimension_value,
        avg(total_price) as metric_value
    from base
    group by 1, 4
),

revenue_by_supplier as (
    select
        transaction_date as metric_date,
        'revenue' as metric_name,
        'supplier' as dimension,
        supplier_name as dimension_value,
        sum(total_price) as metric_value
    from base
    group by 1, 4
),

revenue_by_customer as (
    select
        transaction_date as metric_date,
        'revenue' as metric_name,
        'customer' as dimension,
        cast(customer_id as string) as dimension_value,
        sum(total_price) as metric_value
    from base
    group by 1, 4
),

revenue_total as (
    select
        transaction_date as metric_date,
        'revenue' as metric_name,
        'company' as dimension,
        'all' as dimension_value,
        sum(total_price) as metric_value
    from base
    group by 1
)

select * from revenue_by_franchise
union all
select * from aov_by_franchise
union all
select * from revenue_by_supplier
union all
select * from revenue_by_customer
union all
select * from revenue_total