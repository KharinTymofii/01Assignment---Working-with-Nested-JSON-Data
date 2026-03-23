{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}

with orders as (

    select * from {{ ref('stg_orders') }}
    {% if is_incremental() %}
        where order_date >= (select coalesce(max(order_date), date '1900-01-01') from {{ this }})
    {% endif %}

),

order_items as (

    select * from {{ ref('stg_order_items') }}

),

payments as (

    select * from {{ ref('stg_payments') }}

),

shipments as (

    select * from {{ ref('stg_shipments') }}

),

order_item_totals as (

    select
        order_id,
        sum(quantity) as total_items,
        sum(line_amount) as gross_order_amount
    from order_items
    group by order_id

),

payment_totals as (

    select
        order_id,
        sum(case when payment_status = 'paid' then amount else 0 end) as paid_amount,
        sum(case when payment_status = 'refunded' then amount else 0 end) as refunded_amount
    from payments
    group by order_id

),

shipment_flags as (

    select
        order_id,
        min(shipment_date) as shipment_date,
        max(delivery_date) as delivery_date,
        max(shipment_status) as shipment_status
    from shipments
    group by order_id

)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    o.shipping_city,
    o.shipping_country,
    coalesce(oit.total_items, 0) as total_items,
    coalesce(oit.gross_order_amount, 0) as gross_order_amount,
    coalesce(pt.paid_amount, 0) as paid_amount,
    coalesce(pt.refunded_amount, 0) as refunded_amount,
    sf.shipment_date,
    sf.delivery_date,
    sf.shipment_status
from orders o
left join order_item_totals oit
    on o.order_id = oit.order_id
left join payment_totals pt
    on o.order_id = pt.order_id
left join shipment_flags sf
    on o.order_id = sf.order_id
