with source as (

    select * from {{ ref('src_orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        cast(order_date as date) as order_date,
        lower(trim(order_status)) as order_status,
        trim(shipping_city) as shipping_city,
        trim(shipping_country) as shipping_country
    from source

)

select * from renamed
