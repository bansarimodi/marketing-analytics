{{ config(
    materialized = 'table'
) }}

select
    start_date,
    platform_name,
    ad_id,
    ad_name,
    adset_name,
    reporting_level,
    attribution_type,

    sum(leads) as total_leads,
    sum(sales) as total_sales,

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
    end as cost_per_click

from {{ ref('fact_ad_performance') }}

group by
    start_date,
    platform_name,
    ad_id,
    ad_name,
    adset_name,
    reporting_level,
    attribution_type