{{
    config(
        materialized='incremental',
        unique_key='order_item_id'
    )
}}

with order_items as (

    select * from {{ ref('stg_order_items') }}
    {% if is_incremental() %}
        where order_item_id > (select coalesce(max(order_item_id), 0) from {{ this }})
    {% endif %}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

products as (

    select * from {{ ref('stg_products') }}

)

select
    oi.order_item_id,
    oi.order_id,
    o.customer_id,
    o.order_date,
    oi.product_id,
    p.category_id,
    oi.quantity,
    oi.unit_price,
    oi.line_amount
from order_items oi
left join orders o
    on oi.order_id = o.order_id
left join products p
    on oi.product_id = p.product_id
