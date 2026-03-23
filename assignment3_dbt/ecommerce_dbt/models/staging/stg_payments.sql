with source as (

    select * from {{ ref('src_payments') }}

),

renamed as (

    select
        payment_id,
        order_id,
        cast(payment_date as date) as payment_date,
        lower(trim(payment_method)) as payment_method,
        lower(trim(payment_status)) as payment_status,
        cast(amount as decimal(10, 2)) as amount
    from source

)

select * from renamed
