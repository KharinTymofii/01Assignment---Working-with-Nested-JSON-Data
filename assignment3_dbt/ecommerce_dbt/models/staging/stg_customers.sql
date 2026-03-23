with source as (

    select * from {{ ref('src_customers') }}

),

renamed as (

    select
        customer_id,
        trim(first_name) as first_name,
        trim(last_name) as last_name,
        lower(trim(email)) as email,
        trim(phone) as phone,
        trim(city) as city,
        trim(country) as country,
        cast(signup_date as date) as signup_date,
        lower(trim(customer_status)) as customer_status
    from source

)

select * from renamed
