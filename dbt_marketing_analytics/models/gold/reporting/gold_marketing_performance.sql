{{
    config(
        materialized='table'
    )
}}

-- =====================================================================
-- GOLD REPORTING MODEL: MARKETING PERFORMANCE
--
-- Grain:
--   One row per:
--     START_DATE
--     END_DATE
--     PLATFORM
--     REPORTING_LEVEL
--     ATTRIBUTION_TYPE
--     AD_ID
--     AD_NAME
--     ADSET_NAME
--
-- Purpose:
--   Provides report-ready marketing performance metrics for:
--     - Executive dashboard
--     - Platform performance
--     - Advertisement performance
--     - Attribution comparison
--     - Revenue and profitability reporting
--
-- Source:
--   FACT_AD_PERFORMANCE
--
-- Important:
--   Ratio KPIs are recalculated from aggregated totals.
--   Source-level ratio fields are not averaged.
-- =====================================================================

with aggregated as (

    select
        start_date,
        end_date,

        coalesce(platform, 'UNKNOWN') as platform,
        coalesce(reporting_level, 'UNKNOWN') as reporting_level,
        attribution_type,

        ad_id,
        coalesce(ad_name, 'UNKNOWN') as ad_name,
        coalesce(adset_name, 'UNKNOWN') as adset_name,

        sum(coalesce(leads, 0)) as total_leads,
        sum(coalesce(new_leads, 0)) as total_new_leads,
        sum(coalesce(calls, 0)) as total_calls,
        sum(coalesce(qualified_calls, 0)) as total_qualified_calls,
        sum(coalesce(sales, 0)) as total_sales,

        sum(coalesce(revenue, 0)) as revenue,
        sum(coalesce(recurring_revenue, 0)) as recurring_revenue,
        sum(coalesce(total_revenue, 0)) as total_revenue,
        sum(coalesce(marketing_cost, 0)) as marketing_cost,

        sum(coalesce(clicks, 0)) as total_clicks,
        sum(coalesce(impressions, 0)) as total_impressions

    from {{ ref('fact_ad_performance') }}

    group by
        start_date,
        end_date,
        platform,
        reporting_level,
        attribution_type,
        ad_id,
        ad_name,
        adset_name

),

final as (

    select
        start_date,
        end_date,

        platform,
        reporting_level,
        attribution_type,

        ad_id,
        ad_name,
        adset_name,

        total_leads,
        total_new_leads,
        total_calls,
        total_qualified_calls,
        total_sales,

        revenue,
        recurring_revenue,
        total_revenue,
        marketing_cost,

        total_revenue - marketing_cost as profit,

        total_clicks,
        total_impressions,

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
            when total_impressions = 0 then null
            else marketing_cost * 1000.0 / total_impressions
        end as cpm,

        case
            when total_clicks = 0 then null
            else marketing_cost * 1.0 / total_clicks
        end as cost_per_click,

        case
            when total_leads = 0 then null
            else marketing_cost * 1.0 / total_leads
        end as cost_per_lead,

        case
            when total_calls = 0 then null
            else marketing_cost * 1.0 / total_calls
        end as cost_per_call,

        case
            when total_sales = 0 then null
            else total_revenue * 1.0 / total_sales
        end as revenue_per_sale,

        case
            when total_leads = 0 then null
            else total_revenue * 1.0 / total_leads
        end as revenue_per_lead,

        case
            when total_leads = 0 then null
            else total_sales * 1.0 / total_leads
        end as lead_to_sale_rate,

        case
            when total_calls = 0 then null
            else total_qualified_calls * 1.0 / total_calls
        end as call_qualification_rate

    from aggregated

)

select
    start_date,
    end_date,

    platform,
    reporting_level,
    attribution_type,

    ad_id,
    ad_name,
    adset_name,

    total_leads,
    total_new_leads,
    total_calls,
    total_qualified_calls,
    total_sales,

    revenue,
    recurring_revenue,
    total_revenue,
    marketing_cost,
    profit,

    total_clicks,
    total_impressions,

    roi,
    roas,
    ctr,
    cvr,
    cpm,
    cost_per_click,
    cost_per_lead,
    cost_per_call,
    revenue_per_sale,
    revenue_per_lead,
    lead_to_sale_rate,
    call_qualification_rate

from final