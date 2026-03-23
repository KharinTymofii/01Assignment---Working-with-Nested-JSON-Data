with source as (

    select * from {{ ref('src_reviews') }}

),

renamed as (

    select
        review_id,
        customer_id,
        product_id,
        cast(review_date as date) as review_date,
        cast(rating as integer) as rating,
        trim(review_text) as review_text
    from source

)

select * from renamed
