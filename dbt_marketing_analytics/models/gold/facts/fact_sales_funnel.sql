{{
    config(
        materialized='table'
    )
}}

-- =====================================================================
-- FACT: SALES FUNNEL
--
-- Grain:
--   One row per inbound activity.
--
-- Important:
--   This table is not joined to HYROS leads because the current masked
--   LEAD_ID formats do not match.
-- =====================================================================

select
    inbound_activity_key,
    lead_id,

    activity_log_at,
    cast(activity_log_at as date) as activity_date,

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

    1 as activity_count,

    case
        when status = 'TRIAGE_CALLS_BOOKED'
          or triage_call_date is not null
        then 1
        else 0
    end as triage_booked_count,

    case
        when taken_status = 'TRIAGE_CALLS_TAKEN'
        then 1
        else 0
    end as triage_taken_count,

    case
        when strategy_call_status like '%STRATEGY CALL SCHEDULED%'
         and strategy_call_status not like '%NO STRATEGY%'
        then 1
        else 0
    end as strategy_call_booked_count,

    case
        when strategy_call_taken_status like '%STRATEGY CALL TAKEN%'
         and strategy_call_taken_status not like '%NO STRATEGY%'
        then 1
        else 0
    end as strategy_call_taken_count,

    case
        when sale_status is not null
         and sale_status <> 'NO_SALE'
         and coalesce(contracted_value, 0) > 0
        then 1
        else 0
    end as sale_count,

    coalesce(contracted_value, 0)
        as contracted_revenue

from {{ ref('silver_marketing_inbound_campaign') }}