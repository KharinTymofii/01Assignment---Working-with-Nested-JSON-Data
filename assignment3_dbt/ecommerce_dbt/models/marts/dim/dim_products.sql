with products as (

    select * from {{ ref('stg_products') }}

),

categories as (

    select * from {{ ref('stg_categories') }}

)

select
    p.product_id,
    p.product_name,
    p.brand,
    c.category_id,
    c.category_name,
    p.price,
    p.is_active,
    p.created_at
from products p
left join categories c
    on p.category_id = c.category_id
