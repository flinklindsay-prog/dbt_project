with

source as (

    select 
    franchiseID as franchise_id
    ,name
    ,city
    ,district
    ,zipcode
    ,country
    ,size
    ,longitude
    ,latitude
    ,supplierID as supplier_id
    from {{ source('bakehouse','franchises') }}

)

select * from source