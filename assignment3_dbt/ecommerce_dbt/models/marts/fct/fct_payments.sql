{{
    config(
        materialized='incremental',
        unique_key='payment_id'
    )
}}

with payments as (

    select * from {{ ref('stg_payments') }}
    {% if is_incremental() %}
        where payment_date >= (select coalesce(max(payment_date), date '1900-01-01') from {{ this }})
    {% endif %}

),

orders as (

    select * from {{ ref('stg_orders') }}

)

select
    p.payment_id,
    p.order_id,
    o.customer_id,
    p.payment_date,
    p.payment_method,
    p.payment_status,
    p.amount
from payments p
left join orders o
    on p.order_id = o.order_id
