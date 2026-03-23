with source as (

    select * from {{ ref('src_categories') }}

),

renamed as (

    select
        category_id,
        trim(category_name) as category_name
    from source

)

select * from renamed
