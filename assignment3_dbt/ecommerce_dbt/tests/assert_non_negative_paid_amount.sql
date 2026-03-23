select *
from {{ ref('fct_orders') }}
where paid_amount < 0
