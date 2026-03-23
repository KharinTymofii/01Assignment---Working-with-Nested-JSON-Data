{{
    config(
        materialized='incremental',
        unique_key='review_id'
    )
}}

with reviews as (

    select * from {{ ref('stg_reviews') }}
    {% if is_incremental() %}
        where review_date >= (select coalesce(max(review_date), date '1900-01-01') from {{ this }})
    {% endif %}

),

products as (

    select * from {{ ref('stg_products') }}

)

select
    r.review_id,
    r.customer_id,
    r.product_id,
    p.category_id,
    r.review_date,
    r.rating,
    r.review_text
from reviews r
left join products p
    on r.product_id = p.product_id
