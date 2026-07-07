with

source as (

    select * from {{ source('bakehouse','transactions') }}

)

select * from source