with customers as (

    select * from {{ ref('stg_customers') }}

)

select
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    country,
    signup_date,
    customer_status,
    {{ generate_customer_label('customer_status') }} as customer_segment_label
from customers
