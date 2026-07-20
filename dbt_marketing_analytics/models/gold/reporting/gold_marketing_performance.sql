{{ config(
    materialized = 'table'
) }}

select
    start_date,
    attribution_type,

    sum(leads) as total_leads,
    sum(new_leads) as total_new_leads,
    sum(calls) as total_calls,
    sum(qualified_calls) as total_qualified_calls,
    sum(sales) as total_sales,

    sum(revenue) as revenue,
    sum(recurring_revenue) as recurring_revenue,
    sum(total_revenue) as total_revenue,

    sum(marketing_cost) as marketing_cost,

    sum(total_revenue) - sum(marketing_cost)
        as calculated_profit,

    sum(clicks) as total_clicks,
    sum(impressions) as total_impressions,

    case
        when sum(marketing_cost) = 0 then null
        else
            (
                sum(total_revenue) - sum(marketing_cost)
            ) / sum(marketing_cost)
    end as roi,

    case
        when sum(marketing_cost) = 0 then null
        else sum(total_revenue) / sum(marketing_cost)
    end as roas,

    case
        when sum(impressions) = 0 then null
        else sum(clicks) / sum(impressions)
    end as ctr,

    case
        when sum(clicks) = 0 then null
        else sum(leads) / sum(clicks)
    end as cvr,

    case
        when sum(leads) = 0 then null
        else sum(marketing_cost) / sum(leads)
    end as cost_per_lead,

    case
        when sum(clicks) = 0 then null
        else sum(marketing_cost) / sum(clicks)
    end as cost_per_click,

    case
        when sum(calls) = 0 then null
        else sum(marketing_cost) / sum(calls)
    end as cost_per_call

from {{ ref('fact_ad_performance') }}

group by
    start_date,
    attribution_type