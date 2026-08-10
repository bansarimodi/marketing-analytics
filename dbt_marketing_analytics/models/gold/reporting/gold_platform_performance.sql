{{
    config(
        materialized='table'
    )
}}

with aggregated as (

    select
        start_date,
        end_date,
        platform,
        attribution_type,

        sum(leads) as total_leads,
        sum(new_leads) as total_new_leads,
        sum(calls) as total_calls,
        sum(qualified_calls) as total_qualified_calls,
        sum(sales) as total_sales,

        sum(total_revenue) as total_revenue,
        sum(marketing_cost) as marketing_cost,

        sum(clicks) as total_clicks,
        sum(impressions) as total_impressions

    from {{ ref('fact_ad_performance') }}

    group by
        start_date,
        end_date,
        platform,
        attribution_type

)

select
    *,

    total_revenue - marketing_cost as profit,

    case
        when marketing_cost = 0 then null
        else
            (
                total_revenue - marketing_cost
            ) / marketing_cost
    end as roi,

    case
        when marketing_cost = 0 then null
        else total_revenue / marketing_cost
    end as roas,

    case
        when total_impressions = 0 then null
        else total_clicks * 1.0 / total_impressions
    end as ctr,

    case
        when total_clicks = 0 then null
        else total_leads * 1.0 / total_clicks
    end as cvr,

    case
        when total_leads = 0 then null
        else marketing_cost * 1.0 / total_leads
    end as cost_per_lead

from aggregated