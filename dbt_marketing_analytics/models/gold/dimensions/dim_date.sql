{{ config(
    materialized = 'table'
) }}

with source_dates as (

    select start_date as full_date
    from {{ ref('silver_hyros_ad_attribution') }}
    where start_date is not null

    union

    select end_date as full_date
    from {{ ref('silver_hyros_ad_attribution') }}
    where end_date is not null

    union

    select created_at::date as full_date
    from {{ ref('silver_hyros_leads') }}
    where created_at is not null

    union

    select first_source_click_at::date as full_date
    from {{ ref('silver_hyros_leads') }}
    where first_source_click_at is not null

    union

    select last_source_click_at::date as full_date
    from {{ ref('silver_hyros_leads') }}
    where last_source_click_at is not null

    union

    select activity_log_at::date as full_date
    from {{ ref('silver_marketing_inbound_campaign') }}
    where activity_log_at is not null

    union

    select triage_call_date as full_date
    from {{ ref('silver_marketing_inbound_campaign') }}
    where triage_call_date is not null

)

select
    to_number(to_char(full_date, 'YYYYMMDD')) as date_key,
    full_date,

    year(full_date) as year_number,
    quarter(full_date) as quarter_number,
    month(full_date) as month_number,
    monthname(full_date) as month_name,

    weekofyear(full_date) as week_number,
    dayofmonth(full_date) as day_of_month,
    dayofweekiso(full_date) as day_of_week_number,
    dayname(full_date) as day_name,

    case
        when dayofweekiso(full_date) in (6, 7) then true
        else false
    end as is_weekend

from source_dates