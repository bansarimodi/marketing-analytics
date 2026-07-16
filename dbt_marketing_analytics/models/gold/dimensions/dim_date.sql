{{
    config(
        materialized='table'
    )
}}

-- =====================================================================
-- DIMENSION: DATE
--
-- Grain:
--   One row per calendar date.
-- =====================================================================

with source_dates as (

    select start_date as date_value
    from {{ ref('silver_hyros_ad_attribution') }}

    union all

    select end_date
    from {{ ref('silver_hyros_ad_attribution') }}

    union all

    select cast(created_at as date)
    from {{ ref('silver_hyros_leads') }}

    union all

    select cast(activity_log_at as date)
    from {{ ref('silver_marketing_inbound_campaign') }}

),

date_boundaries as (

    select
        min(date_value) as minimum_date,
        max(date_value) as maximum_date

    from source_dates

    where date_value is not null

),

generated_dates as (

    select
        dateadd(
            day,
            seq4(),
            minimum_date
        )::date as date_day,

        maximum_date

    from date_boundaries,
         table(generator(rowcount => 10000))

),

final_dates as (

    select date_day
    from generated_dates
    where date_day <= maximum_date

)

select
    date_day,

    to_number(to_char(date_day, 'YYYYMMDD'))
        as date_key,

    year(date_day) as year_number,
    quarter(date_day) as quarter_number,
    month(date_day) as month_number,
    monthname(date_day) as month_name,

    weekofyear(date_day) as week_number,
    day(date_day) as day_of_month,
    dayofweekiso(date_day) as day_of_week_number,
    dayname(date_day) as day_name,

    date_trunc('week', date_day)::date as week_start_date,
    date_trunc('month', date_day)::date as month_start_date,
    last_day(date_day, 'month') as month_end_date,

    case
        when dayofweekiso(date_day) in (6, 7)
        then true
        else false
    end as is_weekend

from final_dates