with shipments as (

    select * from {{ ref('fct_shipments') }}

)

select
    carrier,
    shipment_status,
    count(shipment_id) as shipments_count,
    avg(shipping_duration_days) as avg_shipping_duration_days,
    sum(case when shipping_duration_days > 4 then 1 else 0 end) as delayed_shipments_count
from shipments
group by
    carrier,
    shipment_status
