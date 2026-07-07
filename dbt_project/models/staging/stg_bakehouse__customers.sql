with

source as (

    select * from {{ source('bakehouse','customers') }}

)

select * from source