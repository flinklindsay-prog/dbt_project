with

source as (

    select 
    customerID as customer_id
    ,first_name
    ,last_name
    ,email_address
    ,phone_number
    ,address
    ,city
    ,state
    ,country
    ,continent
    ,postal_zip_code
    ,gender 
    from {{ source('bakehouse','customers') }}

)

select * from source