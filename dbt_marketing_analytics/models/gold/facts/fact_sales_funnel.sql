{{ config(
    materialized = 'table'
) }}

select
    inbound_activity_key as sales_funnel_fact_key,

    to_number(
        to_char(activity_log_at::date, 'YYYYMMDD')
    ) as date_key,

    lead_id,
    activity_log_at,
    activity_log_at::date as activity_date,

    first_source_calendly_campaign,
    first_source,
    last_source_calendly_campaign,
    last_source,

    status,
    triage_call_date,
    triage_year_week,

    setter_closer_name,
    closer_name,

    taken_status,
    strategy_call_status,
    strategy_call_taken_status,
    sale_status,

    contracted_value,

    case
        when status = 'TRIAGE_CALLS_BOOKED'
          or triage_call_date is not null
        then 1
        else 0
    end as triage_call_booked_flag,

    case
        when taken_status = 'TRIAGE_CALLS_TAKEN'
        then 1
        else 0
    end as triage_call_taken_flag,

    case
        when strategy_call_status is not null
         and strategy_call_status <> 'NO_STRATEGY_CALL_BOOKED'
        then 1
        else 0
    end as strategy_call_scheduled_flag,

    case
        when strategy_call_taken_status is not null
         and strategy_call_taken_status <> 'NO_STRATEGY_CALL_TAKEN'
        then 1
        else 0
    end as strategy_call_taken_flag,

    case
        when sale_status is not null
         and sale_status <> 'NO_SALE'
        then 1
        else 0
    end as sale_flag

from {{ ref('silver_marketing_inbound_campaign') }}