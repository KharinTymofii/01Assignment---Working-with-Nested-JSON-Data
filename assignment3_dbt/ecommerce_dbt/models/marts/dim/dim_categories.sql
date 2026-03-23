with categories as (

    select * from {{ ref('stg_categories') }}

)

select
    category_id,
    category_name
from categories
