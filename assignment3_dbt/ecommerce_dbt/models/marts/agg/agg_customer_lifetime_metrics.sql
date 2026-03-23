with customer_orders as (

    select * from {{ ref('fct_orders') }}

),

ranked_orders as (

    select
        customer_id,
        order_id,
        order_date,
        paid_amount,
        row_number() over (
            partition by customer_id
            order by order_date desc, order_id desc
        ) as latest_order_rank
    from customer_orders

),

customer_metrics as (

    select
        customer_id,
        count(order_id) as orders_count,
        sum(paid_amount) as lifetime_revenue,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from customer_orders
    group by customer_id

)

select
    cm.customer_id,
    cm.orders_count,
    cm.lifetime_revenue,
    cm.first_order_date,
    cm.last_order_date,
    ro.order_id as latest_order_id
from customer_metrics cm
left join ranked_orders ro
    on cm.customer_id = ro.customer_id
   and ro.latest_order_rank = 1
