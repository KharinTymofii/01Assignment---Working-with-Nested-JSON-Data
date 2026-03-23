{{
    config(
        materialized='incremental',
        unique_key='shipment_id'
    )
}}

with shipments as (

    select * from {{ ref('stg_shipments') }}
    {% if is_incremental() %}
        where shipment_date >= (select coalesce(max(shipment_date), date '1900-01-01') from {{ this }})
    {% endif %}

),

orders as (

    select * from {{ ref('stg_orders') }}

)

select
    s.shipment_id,
    s.order_id,
    o.customer_id,
    o.order_date,
    s.shipment_date,
    s.delivery_date,
    s.shipment_status,
    s.carrier,
    datediff('day', s.shipment_date, coalesce(s.delivery_date, current_date)) as shipping_duration_days
from shipments s
left join orders o
    on s.order_id = o.order_id
