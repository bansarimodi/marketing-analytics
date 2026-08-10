<<<<<<< HEAD
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

=======
{{ config(
    materialized = 'table',
    schema = 'gold'
) }}

with source_dates as (

    select start_date as full_date
    from {{ ref('silver_hyros_ad_attribution') }}
    where start_date is not null

    union

    select end_date
    from {{ ref('silver_hyros_ad_attribution') }}
    where end_date is not null

    union

    select created_at::date
    from {{ ref('silver_hyros_leads') }}
    where created_at is not null

    union

    select first_source_click_at::date
    from {{ ref('silver_hyros_leads') }}
    where first_source_click_at is not null

    union

    select last_source_click_at::date
    from {{ ref('silver_hyros_leads') }}
    where last_source_click_at is not null

    union

    select activity_log_at::date
    from {{ ref('silver_marketing_inbound_campaign') }}
    where activity_log_at is not null

    union

    select triage_call_date
    from {{ ref('silver_marketing_inbound_campaign') }}
    where triage_call_date is not null
),

date_range as (

    select
        min(full_date) as min_date,
        max(full_date) as max_date
    from source_dates

>>>>>>> ff66700 (final)
),

generated_dates as (

    select
        dateadd(
            day,
            seq4(),
<<<<<<< HEAD
            minimum_date
        )::date as date_day,

        maximum_date

    from date_boundaries,
=======
            min_date
        )::date as full_date,
        max_date
    from date_range,
>>>>>>> ff66700 (final)
         table(generator(rowcount => 10000))

),

<<<<<<< HEAD
final_dates as (

    select date_day
    from generated_dates
    where date_day <= maximum_date
=======
date_spine as (

    select full_date
    from generated_dates
    where full_date <= max_date
>>>>>>> ff66700 (final)

)

select
<<<<<<< HEAD
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
=======
    to_number(
        to_char(full_date, 'YYYYMMDD')
    ) as date_key,

    full_date,

    year(full_date) as year,
    quarter(full_date) as quarter_number,
    month(full_date) as month_number,
    monthname(full_date) as month_name,
    weekofyear(full_date) as week_number,
    day(full_date) as day_of_month,
    dayofweekiso(full_date) as day_of_week_number,
    dayname(full_date) as day_name

from date_spine

order by full_date
>>>>>>> ff66700 (final)
