{{ config(
    materialized = 'table'
) }}

select
    activity_date,

    count(*) as total_activity_records,
    count(distinct lead_id) as total_distinct_leads,

    sum(triage_call_booked_flag)
        as triage_calls_booked,

    sum(triage_call_taken_flag)
        as triage_calls_taken,

    sum(strategy_call_scheduled_flag)
        as strategy_calls_scheduled,

    sum(strategy_call_taken_flag)
        as strategy_calls_taken,

    sum(sale_flag) as total_sales,

    sum(contracted_value) as total_contracted_value,

    case
        when sum(triage_call_booked_flag) = 0 then null
        else
            sum(triage_call_taken_flag)
            / sum(triage_call_booked_flag)
    end as triage_attendance_rate,

    case
        when sum(triage_call_taken_flag) = 0 then null
        else
            sum(strategy_call_scheduled_flag)
            / sum(triage_call_taken_flag)
    end as triage_to_strategy_rate,

    case
        when sum(strategy_call_scheduled_flag) = 0 then null
        else
            sum(strategy_call_taken_flag)
            / sum(strategy_call_scheduled_flag)
    end as strategy_attendance_rate,

    case
        when sum(strategy_call_taken_flag) = 0 then null
        else
            sum(sale_flag)
            / sum(strategy_call_taken_flag)
    end as strategy_to_sale_rate

from {{ ref('fact_sales_funnel') }}

group by activity_date