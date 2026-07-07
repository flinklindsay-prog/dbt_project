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
    t.transactionID,
    t.dateTime as transaction_timestamp,
    t.customerID,
    t.product,
    t.totalPrice,
    f.franchiseID,
    f.city as franchise_city,
    f.supplierID,
    s.name as supplier_name
from transactions t
left join franchises f on t.franchiseID = f.franchiseID
left join suppliers s on f.supplierID = s.supplierID