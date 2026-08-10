<<<<<<< HEAD
{{
    config(
        materialized='table'
    )
}}

-- =====================================================================
-- FACT: AD PERFORMANCE
--
-- Grain:
--   One ad-performance source record per attribution type.
--
-- Attribution types:
--   FIRST_TOUCH
--   LAST_TOUCH
--   SCIENTIFIC
-- =====================================================================

with first_touch as (

    select
        md5(
            concat_ws(
                '|',
                ad_id,
                start_date,
                end_date,
                reporting_level,
                'FIRST_TOUCH'
            )
        ) as ad_attribution_fact_key,

        ad_id,
        ad_name,
        adset_name,
        platform,
        reporting_level,
        start_date,
        end_date,

        'FIRST_TOUCH' as attribution_type,

        first_source_click_id as source_click_id,
        first_source_click_name as source_click_name,

        coalesce(first_source_leads, 0) as leads,
        coalesce(first_source_new_leads, 0) as new_leads,
        coalesce(first_source_calls, 0) as calls,
        coalesce(first_source_qualified_calls, 0)
            as qualified_calls,
        coalesce(first_source_sales, 0) as sales,

        coalesce(first_source_revenue, 0)
            as revenue,

        coalesce(first_source_recurring_revenue, 0)
            as recurring_revenue,

        coalesce(first_source_total_revenue, 0)
            as total_revenue,

        coalesce(first_source_cost, 0)
            as marketing_cost,

        coalesce(first_source_clicks, 0)
            as clicks,

        coalesce(first_source_impressions, 0)
            as impressions

    from {{ ref('silver_hyros_ad_attribution') }}

),

last_touch as (

    select
        md5(
            concat_ws(
                '|',
                ad_id,
                start_date,
                end_date,
                reporting_level,
                'LAST_TOUCH'
            )
        ) as ad_attribution_fact_key,

        ad_id,
        ad_name,
        adset_name,
        platform,
        reporting_level,
        start_date,
        end_date,

        'LAST_TOUCH' as attribution_type,

        last_source_click_id as source_click_id,
        last_source_click_name as source_click_name,

        coalesce(last_source_leads, 0) as leads,
        coalesce(last_source_new_leads, 0) as new_leads,
        coalesce(last_source_calls, 0) as calls,
        coalesce(last_source_qualified_calls, 0)
            as qualified_calls,
        coalesce(last_source_sales, 0) as sales,

        coalesce(last_source_revenue, 0)
            as revenue,

        coalesce(last_source_recurring_revenue, 0)
            as recurring_revenue,

        coalesce(last_source_total_revenue, 0)
            as total_revenue,

        coalesce(last_source_cost, 0)
            as marketing_cost,

        coalesce(last_source_clicks, 0)
            as clicks,

        coalesce(last_source_impressions, 0)
            as impressions

    from {{ ref('silver_hyros_ad_attribution') }}

),

scientific_touch as (

    select
        md5(
            concat_ws(
                '|',
                ad_id,
                start_date,
                end_date,
                reporting_level,
                'SCIENTIFIC'
            )
        ) as ad_attribution_fact_key,

        ad_id,
        ad_name,
        adset_name,
        platform,
        reporting_level,
        start_date,
        end_date,

        'SCIENTIFIC' as attribution_type,

        scientific_source_click_id as source_click_id,
        scientific_source_click_name as source_click_name,

        coalesce(scientific_source_leads, 0) as leads,
        coalesce(scientific_source_new_leads, 0)
            as new_leads,
        coalesce(scientific_source_calls, 0) as calls,
        coalesce(scientific_source_qualified_calls, 0)
            as qualified_calls,
        coalesce(scientific_source_sales, 0) as sales,

        coalesce(scientific_source_revenue, 0)
            as revenue,

        coalesce(scientific_source_recurring_revenue, 0)
            as recurring_revenue,

        coalesce(scientific_source_total_revenue, 0)
            as total_revenue,

        coalesce(scientific_source_cost, 0)
            as marketing_cost,

        coalesce(scientific_source_clicks, 0)
            as clicks,

        coalesce(scientific_source_impressions, 0)
            as impressions

    from {{ ref('silver_hyros_ad_attribution') }}

),

combined as (

    select * from first_touch

    union all

    select * from last_touch

    union all

    select * from scientific_touch

)

select
    ad_attribution_fact_key,

    ad_id,
    ad_name,
    adset_name,
    platform,
    reporting_level,
    start_date,
    end_date,
    attribution_type,

    source_click_id,
    source_click_name,

    leads,
    new_leads,
    calls,
    qualified_calls,
    sales,

    revenue,
    recurring_revenue,
    total_revenue,
    marketing_cost,

    total_revenue - marketing_cost
        as calculated_profit,

    clicks,
    impressions,

    case
        when marketing_cost = 0 then null
        else
            (
                total_revenue - marketing_cost
            ) / marketing_cost
    end as calculated_roi,

    case
        when marketing_cost = 0 then null
        else total_revenue / marketing_cost
    end as calculated_roas,

    case
        when impressions = 0 then null
        else clicks * 1.0 / impressions
    end as calculated_ctr,

    case
        when clicks = 0 then null
        else leads * 1.0 / clicks
    end as calculated_cvr,

    case
        when impressions = 0 then null
        else marketing_cost * 1000.0 / impressions
    end as calculated_cpm,

    case
        when clicks = 0 then null
        else marketing_cost * 1.0 / clicks
    end as calculated_cost_per_click,

    case
        when leads = 0 then null
        else marketing_cost * 1.0 / leads
    end as calculated_cost_per_lead,

    case
        when calls = 0 then null
        else marketing_cost * 1.0 / calls
    end as calculated_cost_per_call

from combined
=======
{{ config(
    materialized = 'table',
    schema = 'gold'
) }}

select
    ad_performance_key,

    md5(
        concat_ws(
            '|',
            platform,
            ad_id
        )
    ) as ad_key,

    md5(platform) as platform_key,

    to_number(
        to_char(start_date, 'YYYYMMDD')
    ) as start_date_key,

    to_number(
        to_char(end_date, 'YYYYMMDD')
    ) as end_date_key,

    ad_id,
    reporting_level,

    /* First-Touch measures */

    first_source_leads,
    first_source_new_leads,
    first_source_calls,
    first_source_qualified_calls,
    first_source_sales,

    first_source_revenue,
    first_source_recurring_revenue,
    first_source_total_revenue,
    first_source_profit,
    first_source_cost,

    first_source_clicks,
    first_source_impressions,

    first_source_roi,
    first_source_roas,
    first_source_ctr,
    first_source_cpm,
    first_source_cvr,
    first_source_cost_per_lead,
    first_source_cost_per_click,
    first_source_cost_per_call,

    /* Last-Touch measures */

    last_source_leads,
    last_source_new_leads,
    last_source_calls,
    last_source_qualified_calls,
    last_source_sales,

    last_source_revenue,
    last_source_recurring_revenue,
    last_source_total_revenue,
    last_source_profit,
    last_source_cost,

    last_source_clicks,
    last_source_impressions,

    last_source_roi,
    last_source_roas,
    last_source_ctr,
    last_source_cpm,
    last_source_cvr,
    last_source_cost_per_lead,
    last_source_cost_per_click,
    last_source_cost_per_call,

    source_file_name,
    source_update_at,
    load_timestamp

from {{ ref('silver_hyros_ad_attribution') }}
>>>>>>> ff66700 (final)
