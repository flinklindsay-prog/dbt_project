with

source as (

    select * from {{ source('bakehouse','franchises') }}

)

select * from source