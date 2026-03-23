with calendar as (

    select
        day_date as date_day
    from (
        select
            unnest(generate_series(date '2024-01-01', date '2024-12-31', interval 1 day)) as day_date
    )

)

select
    date_day,
    extract(year from date_day) as calendar_year,
    extract(month from date_day) as calendar_month,
    extract(day from date_day) as calendar_day,
    strftime(date_day, '%Y-%m') as year_month,
    extract(quarter from date_day) as calendar_quarter
from calendar
