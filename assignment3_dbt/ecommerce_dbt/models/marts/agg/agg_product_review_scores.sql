with reviews as (

    select * from {{ ref('fct_reviews') }}

),

products as (

    select * from {{ ref('dim_products') }}

)

select
    p.product_id,
    p.product_name,
    p.category_name,
    count(r.review_id) as reviews_count,
    avg(r.rating) as avg_rating
from products p
left join reviews r
    on p.product_id = r.product_id
group by
    p.product_id,
    p.product_name,
    p.category_name
