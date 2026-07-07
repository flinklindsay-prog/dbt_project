with

source as (

    select  
    transactionID as transaction_id
    ,customerID as customer_id
    ,franchiseID as franchise_id
    ,dateTime as transaction_timestamp
    ,product
    ,quantity
    ,unitPrice as unit_price
    ,totalPrice as total_price
    ,paymentMethod as payment_method
    ,cardNumber as card_number
    from {{ source('bakehouse','transactions') }}

)

select * from source