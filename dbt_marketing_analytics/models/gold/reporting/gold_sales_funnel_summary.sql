{{
    config(
        materialized='table'
    )
}}

-- =====================================================================
-- REPORTING TABLE: SALES FUNNEL SUMMARY
--
-- Grain:
--   Activity date + source + setter + closer.
-- =====================================================================

select
    activity_date,

    coalesce(first_source, 'UNKNOWN')
        as first_source,

    coalesce(last_source, 'UNKNOWN')
        as last_source,

    coalesce(setter_closer_name, 'UNASSIGNED')
        as setter_closer_name,

    coalesce(closer_name, 'UNASSIGNED')
        as closer_name,

    count(distinct lead_id)
        as unique_leads,

    sum(triage_booked_count)
        as triage_calls_booked,

    sum(triage_taken_count)
        as triage_calls_taken,

    sum(strategy_call_booked_count)
        as strategy_calls_booked,

    sum(strategy_call_taken_count)
        as strategy_calls_taken,

    sum(sale_count)
        as sales,

    sum(contracted_revenue)
        as contracted_revenue,

    case
        when count(distinct lead_id) = 0 then null
        else
            sum(triage_booked_count) * 1.0 /
            count(distinct lead_id)
    end as lead_to_triage_rate,

    case
        when sum(triage_taken_count) = 0 then null
        else
            sum(strategy_call_booked_count) * 1.0 /
            sum(triage_taken_count)
    end as triage_to_strategy_rate,

    case
        when sum(strategy_call_taken_count) = 0 then null
        else
            sum(sale_count) * 1.0 /
            sum(strategy_call_taken_count)
    end as strategy_to_sale_rate,

    case
        when count(distinct lead_id) = 0 then null
        else
            sum(sale_count) * 1.0 /
            count(distinct lead_id)
    end as lead_to_sale_rate,

    case
        when sum(sale_count) = 0 then null
        else
            sum(contracted_revenue) * 1.0 /
            sum(sale_count)
    end as average_deal_value

from {{ ref('fact_sales_funnel') }}

group by
    activity_date,
    first_source,
    last_source,
    setter_closer_name,
    closer_name