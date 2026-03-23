with source as (

    select * from {{ ref('src_shipments') }}

),

renamed as (

    select
        shipment_id,
        order_id,
        cast(shipment_date as date) as shipment_date,
        cast(delivery_date as date) as delivery_date,
        lower(trim(shipment_status)) as shipment_status,
        trim(carrier) as carrier
    from source

)

select * from renamed
