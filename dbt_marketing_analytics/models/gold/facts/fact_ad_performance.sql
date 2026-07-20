{{ config(
    materialized = 'table'
) }}

with first_touch as (

    select
        md5(
            concat_ws(
                '|',
                ad_performance_key,
                'FIRST_TOUCH'
            )
        ) as ad_performance_fact_key,

        ad_performance_key,
        'FIRST_TOUCH' as attribution_type,

        to_number(to_char(start_date, 'YYYYMMDD')) as date_key,

        md5(upper(trim(platform))) as platform_key,

        md5(
            concat_ws(
                '|',
                coalesce(upper(trim(platform)), 'UNKNOWN'),
                coalesce(trim(ad_id), 'UNKNOWN'),
                coalesce(trim(ad_name), 'UNKNOWN'),
                coalesce(trim(adset_name), 'UNKNOWN')
            )
        ) as ad_key,

        ad_id,
        ad_name,
        adset_name,
        platform as platform_name,
        reporting_level,
        start_date,
        end_date,

        first_source_click_id as attribution_click_id,
        first_source_click_name as attribution_click_name,

        first_source_leads as leads,
        first_source_new_leads as new_leads,
        first_source_calls as calls,
        first_source_qualified_calls as qualified_calls,
        first_source_sales as sales,

        first_source_revenue as revenue,
        first_source_recurring_revenue as recurring_revenue,
        first_source_total_revenue as total_revenue,
        first_source_cost as marketing_cost,
        first_source_profit as profit,

        first_source_clicks as clicks,
        first_source_impressions as impressions,

        first_source_roi as source_roi,
        first_source_roas as source_roas,
        first_source_ctr as source_ctr,
        first_source_cpm as source_cpm,
        first_source_cvr as source_cvr,
        first_source_cost_per_lead as source_cost_per_lead,
        first_source_cost_per_click as source_cost_per_click,
        first_source_cost_per_call as source_cost_per_call

    from {{ ref('silver_hyros_ad_attribution') }}

),

last_touch as (

    select
        md5(
            concat_ws(
                '|',
                ad_performance_key,
                'LAST_TOUCH'
            )
        ) as ad_performance_fact_key,

        ad_performance_key,
        'LAST_TOUCH' as attribution_type,

        to_number(to_char(start_date, 'YYYYMMDD')) as date_key,

        md5(upper(trim(platform))) as platform_key,

        md5(
            concat_ws(
                '|',
                coalesce(upper(trim(platform)), 'UNKNOWN'),
                coalesce(trim(ad_id), 'UNKNOWN'),
                coalesce(trim(ad_name), 'UNKNOWN'),
                coalesce(trim(adset_name), 'UNKNOWN')
            )
        ) as ad_key,

        ad_id,
        ad_name,
        adset_name,
        platform as platform_name,
        reporting_level,
        start_date,
        end_date,

        last_source_click_id as attribution_click_id,
        last_source_click_name as attribution_click_name,

        last_source_leads as leads,
        last_source_new_leads as new_leads,
        last_source_calls as calls,
        last_source_qualified_calls as qualified_calls,
        last_source_sales as sales,

        last_source_revenue as revenue,
        last_source_recurring_revenue as recurring_revenue,
        last_source_total_revenue as total_revenue,
        last_source_cost as marketing_cost,
        last_source_profit as profit,

        last_source_clicks as clicks,
        last_source_impressions as impressions,

        last_source_roi as source_roi,
        last_source_roas as source_roas,
        last_source_ctr as source_ctr,
        last_source_cpm as source_cpm,
        last_source_cvr as source_cvr,
        last_source_cost_per_lead as source_cost_per_lead,
        last_source_cost_per_click as source_cost_per_click,
        last_source_cost_per_call as source_cost_per_call

    from {{ ref('silver_hyros_ad_attribution') }}

),

scientific as (

    select
        md5(
            concat_ws(
                '|',
                ad_performance_key,
                'SCIENTIFIC'
            )
        ) as ad_performance_fact_key,

        ad_performance_key,
        'SCIENTIFIC' as attribution_type,

        to_number(to_char(start_date, 'YYYYMMDD')) as date_key,

        md5(upper(trim(platform))) as platform_key,

        md5(
            concat_ws(
                '|',
                coalesce(upper(trim(platform)), 'UNKNOWN'),
                coalesce(trim(ad_id), 'UNKNOWN'),
                coalesce(trim(ad_name), 'UNKNOWN'),
                coalesce(trim(adset_name), 'UNKNOWN')
            )
        ) as ad_key,

        ad_id,
        ad_name,
        adset_name,
        platform as platform_name,
        reporting_level,
        start_date,
        end_date,

        scientific_source_click_id as attribution_click_id,
        scientific_source_click_name as attribution_click_name,

        scientific_source_leads as leads,
        scientific_source_new_leads as new_leads,
        scientific_source_calls as calls,
        scientific_source_qualified_calls as qualified_calls,
        scientific_source_sales as sales,

        scientific_source_revenue as revenue,
        scientific_source_recurring_revenue as recurring_revenue,
        scientific_source_total_revenue as total_revenue,
        scientific_source_cost as marketing_cost,
        scientific_source_profit as profit,

        scientific_source_clicks as clicks,
        scientific_source_impressions as impressions,

        scientific_source_roi as source_roi,
        scientific_source_roas as source_roas,
        scientific_source_ctr as source_ctr,
        scientific_source_cpm as source_cpm,
        scientific_source_cvr as source_cvr,
        scientific_source_cost_per_lead as source_cost_per_lead,
        scientific_source_cost_per_click as source_cost_per_click,
        scientific_source_cost_per_call as source_cost_per_call

    from {{ ref('silver_hyros_ad_attribution') }}

)

select * from first_touch

union all

select * from last_touch

union all

select * from scientific