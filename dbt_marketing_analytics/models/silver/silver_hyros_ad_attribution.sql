{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='ad_performance_key',
        on_schema_change='sync_all_columns'
    )
}}

-- =====================================================================
-- SILVER MODEL: HYROS AD ATTRIBUTION
--
-- Grain:
--   One row per:
--       AD_ID + START_DATE + END_DATE + REPORTING_LEVEL
--
-- Responsibilities:
--   - Convert empty strings to NULL
--   - Convert dates and metrics into proper data types
--   - Standardize platform and reporting level
--   - Deduplicate repeated ad-period records
--   - Keep the most recently updated version
--   - Preserve source metadata
--
-- ROI, ROAS, CTR and CVR are retained as source metrics here.
-- Aggregated KPI ratios will be recalculated in Gold.
-- =====================================================================

with source_data as (

    select
        *

    from {{ source('bronze', 'hyros_ad_attribution_raw') }}

    {% if is_incremental() %}

        where load_timestamp >= (

            select coalesce(
                dateadd(day, -2, max(load_timestamp)),
                '1900-01-01'::timestamp_tz
            )
            from {{ this }}

        )

    {% endif %}

),

cleaned as (

    select
        -- -------------------------------------------------------------
        -- Advertisement identity and reporting period
        -- -------------------------------------------------------------

        nullif(trim(ad_id), '') as ad_id,
        nullif(trim(ad_name), '') as ad_name,
        nullif(trim(adset_name), '') as adset_name,

        upper(nullif(trim(platform), ''))
            as platform,

        upper(nullif(trim(level), ''))
            as reporting_level,

        try_to_date(start_date) as start_date,
        try_to_date(end_date) as end_date,

        -- -------------------------------------------------------------
        -- First-touch metrics
        -- -------------------------------------------------------------

        nullif(trim(first_source_click_id), '')
            as first_source_click_id,

        nullif(trim(first_source_click_name), '')
            as first_source_click_name,

        try_to_number(first_source_leads)
            as first_source_leads,

        try_to_number(first_source_new_leads)
            as first_source_new_leads,

        try_to_number(first_source_calls)
            as first_source_calls,

        try_to_number(first_source_qualified_calls)
            as first_source_qualified_calls,

        try_to_number(first_source_sales)
            as first_source_sales,

        try_to_decimal(first_source_revenue, 18, 2)
            as first_source_revenue,

        try_to_decimal(first_source_recurring_revenue, 18, 2)
            as first_source_recurring_revenue,

        try_to_decimal(first_source_total_revenue, 18, 2)
            as first_source_total_revenue,

        try_to_decimal(first_source_profit, 18, 2)
            as first_source_profit,

        try_to_decimal(first_source_cost, 18, 2)
            as first_source_cost,

        try_to_decimal(first_source_roi, 18, 6)
            as first_source_roi,

        try_to_decimal(first_source_roas, 18, 6)
            as first_source_roas,

        try_to_number(first_source_clicks)
            as first_source_clicks,

        try_to_number(first_source_impressions)
            as first_source_impressions,

        try_to_decimal(first_source_ctr, 18, 6)
            as first_source_ctr,

        try_to_decimal(first_source_cpm, 18, 6)
            as first_source_cpm,

        try_to_decimal(first_source_cvr, 18, 6)
            as first_source_cvr,

        try_to_decimal(first_source_cost_per_lead, 18, 6)
            as first_source_cost_per_lead,

        try_to_decimal(first_source_cost_per_click, 18, 6)
            as first_source_cost_per_click,

        try_to_decimal(first_source_cost_per_call, 18, 6)
            as first_source_cost_per_call,

        -- -------------------------------------------------------------
        -- Last-touch metrics
        -- -------------------------------------------------------------

        nullif(trim(last_source_click_id), '')
            as last_source_click_id,

        nullif(trim(last_source_click_name), '')
            as last_source_click_name,

        try_to_number(last_source_leads)
            as last_source_leads,

        try_to_number(last_source_new_leads)
            as last_source_new_leads,

        try_to_number(last_source_calls)
            as last_source_calls,

        try_to_number(last_source_qualified_calls)
            as last_source_qualified_calls,

        try_to_number(last_source_sales)
            as last_source_sales,

        try_to_decimal(last_source_revenue, 18, 2)
            as last_source_revenue,

        try_to_decimal(last_source_recurring_revenue, 18, 2)
            as last_source_recurring_revenue,

        try_to_decimal(last_source_total_revenue, 18, 2)
            as last_source_total_revenue,

        try_to_decimal(last_source_profit, 18, 2)
            as last_source_profit,

        try_to_decimal(last_source_cost, 18, 2)
            as last_source_cost,

        try_to_decimal(last_source_roi, 18, 6)
            as last_source_roi,

        try_to_decimal(last_source_roas, 18, 6)
            as last_source_roas,

        try_to_number(last_source_clicks)
            as last_source_clicks,

        try_to_number(last_source_impressions)
            as last_source_impressions,

        try_to_decimal(last_source_ctr, 18, 6)
            as last_source_ctr,

        try_to_decimal(last_source_cpm, 18, 6)
            as last_source_cpm,

        try_to_decimal(last_source_cvr, 18, 6)
            as last_source_cvr,

        try_to_decimal(last_source_cost_per_lead, 18, 6)
            as last_source_cost_per_lead,

        try_to_decimal(last_source_cost_per_click, 18, 6)
            as last_source_cost_per_click,

        try_to_decimal(last_source_cost_per_call, 18, 6)
            as last_source_cost_per_call,

        -- -------------------------------------------------------------
        -- Scientific attribution metrics
        -- -------------------------------------------------------------

        nullif(trim(scientific_source_click_id), '')
            as scientific_source_click_id,

        nullif(trim(scientific_source_click_name), '')
            as scientific_source_click_name,

        try_to_number(scientific_source_leads)
            as scientific_source_leads,

        try_to_number(scientific_source_new_leads)
            as scientific_source_new_leads,

        try_to_number(scientific_source_calls)
            as scientific_source_calls,

        try_to_number(scientific_source_qualified_calls)
            as scientific_source_qualified_calls,

        try_to_number(scientific_source_sales)
            as scientific_source_sales,

        try_to_decimal(scientific_source_revenue, 18, 2)
            as scientific_source_revenue,

        try_to_decimal(scientific_source_recurring_revenue, 18, 2)
            as scientific_source_recurring_revenue,

        try_to_decimal(scientific_source_total_revenue, 18, 2)
            as scientific_source_total_revenue,

        try_to_decimal(scientific_source_profit, 18, 2)
            as scientific_source_profit,

        try_to_decimal(scientific_source_cost, 18, 2)
            as scientific_source_cost,

        try_to_decimal(scientific_source_roi, 18, 6)
            as scientific_source_roi,

        try_to_decimal(scientific_source_roas, 18, 6)
            as scientific_source_roas,

        try_to_number(scientific_source_clicks)
            as scientific_source_clicks,

        try_to_number(scientific_source_impressions)
            as scientific_source_impressions,

        try_to_decimal(scientific_source_ctr, 18, 6)
            as scientific_source_ctr,

        try_to_decimal(scientific_source_cpm, 18, 6)
            as scientific_source_cpm,

        try_to_decimal(scientific_source_cvr, 18, 6)
            as scientific_source_cvr,

        try_to_decimal(scientific_source_cost_per_lead, 18, 6)
            as scientific_source_cost_per_lead,

        try_to_decimal(scientific_source_cost_per_click, 18, 6)
            as scientific_source_cost_per_click,

        try_to_decimal(scientific_source_cost_per_call, 18, 6)
            as scientific_source_cost_per_call,

        -- -------------------------------------------------------------
        -- Source audit fields
        -- -------------------------------------------------------------

        nullif(trim(md5_hash), '')
            as md5_hash,

        try_to_timestamp_ntz(insert_date)
            as source_insert_at,

        try_to_timestamp_ntz(update_date)
            as source_update_at,

        source_file_name,
        source_file_row_number,
        source_file_last_modified,
        load_timestamp

    from source_data

),

with_business_key as (

    select
        md5(
            concat_ws(
                '|',
                coalesce(ad_id, ''),
                coalesce(to_varchar(start_date), ''),
                coalesce(to_varchar(end_date), ''),
                coalesce(reporting_level, '')
            )
        ) as ad_performance_key,

        *

    from cleaned

    where ad_id is not null
      and start_date is not null
      and end_date is not null
      and reporting_level is not null

),

deduplicated as (

    select
        *,

        row_number() over (
            partition by ad_performance_key
            order by
                source_update_at desc nulls last,
                source_insert_at desc nulls last,
                load_timestamp desc,
                source_file_row_number desc
        ) as row_num

    from with_business_key

)

select
    ad_performance_key,

    ad_id,
    ad_name,
    adset_name,
    platform,
    reporting_level,
    start_date,
    end_date,

    first_source_click_id,
    first_source_click_name,
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
    first_source_roi,
    first_source_roas,
    first_source_clicks,
    first_source_impressions,
    first_source_ctr,
    first_source_cpm,
    first_source_cvr,
    first_source_cost_per_lead,
    first_source_cost_per_click,
    first_source_cost_per_call,

    last_source_click_id,
    last_source_click_name,
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
    last_source_roi,
    last_source_roas,
    last_source_clicks,
    last_source_impressions,
    last_source_ctr,
    last_source_cpm,
    last_source_cvr,
    last_source_cost_per_lead,
    last_source_cost_per_click,
    last_source_cost_per_call,

    scientific_source_click_id,
    scientific_source_click_name,
    scientific_source_leads,
    scientific_source_new_leads,
    scientific_source_calls,
    scientific_source_qualified_calls,
    scientific_source_sales,
    scientific_source_revenue,
    scientific_source_recurring_revenue,
    scientific_source_total_revenue,
    scientific_source_profit,
    scientific_source_cost,
    scientific_source_roi,
    scientific_source_roas,
    scientific_source_clicks,
    scientific_source_impressions,
    scientific_source_ctr,
    scientific_source_cpm,
    scientific_source_cvr,
    scientific_source_cost_per_lead,
    scientific_source_cost_per_click,
    scientific_source_cost_per_call,

    md5_hash,
    source_insert_at,
    source_update_at,

    source_file_name,
    source_file_row_number,
    source_file_last_modified,
    load_timestamp

from deduplicated

where row_num = 1