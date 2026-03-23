with source as (

    select * from {{ ref('src_products') }}

),

renamed as (

    select
        product_id,
        category_id,
        trim(product_name) as product_name,
        trim(brand) as brand,
        cast(price as decimal(10, 2)) as price,
        cast(is_active as boolean) as is_active,
        cast(created_at as date) as created_at
    from source

)

select * from renamed
