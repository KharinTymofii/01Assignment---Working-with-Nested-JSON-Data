with order_items as (

    select * from {{ ref('fct_order_items') }}

),

orders as (

    select * from {{ ref('fct_orders') }}

),

products as (

    select * from {{ ref('dim_products') }}

),

base as (

    select
        strftime(o.order_date, '%Y-%m') as year_month,
        p.category_id,
        p.category_name,
        sum(oi.line_amount) as monthly_sales
    from order_items oi
    left join orders o
        on oi.order_id = o.order_id
    left join products p
        on oi.product_id = p.product_id
    group by
        strftime(o.order_date, '%Y-%m'),
        p.category_id,
        p.category_name

)

select
    year_month,
    category_id,
    category_name,
    monthly_sales,
    rank() over (
        partition by year_month
        order by monthly_sales desc
    ) as category_sales_rank
from base
