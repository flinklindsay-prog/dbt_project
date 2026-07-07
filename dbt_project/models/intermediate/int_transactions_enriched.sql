with transactions as (

    select * from {{ ref('stg_bakehouse__transactions') }}

),
franchises as (

    select * from {{ ref('stg_bakehouse__franchises') }}

),
suppliers as (

    select * from {{ ref('stg_bakehouse__suppliers') }}

)

select
    t.transaction_id,
    t.transaction_timestamp,
    t.customer_id,
    t.product,
    t.total_price,
    f.franchise_id,
    f.city as franchise_city,
    f.supplier_id,
    s.name as supplier_name
from transactions t
left join franchises f on t.franchise_id = f.franchise_id
left join suppliers s on f.supplier_id = s.supplier_id