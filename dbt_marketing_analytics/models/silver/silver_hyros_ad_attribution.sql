{{ config(
    materialized = 'incremental',
    unique_key = 'ad_performance_key',
    incremental_strategy = 'merge',
    on_schema_change = 'sync_all_columns'
) }}

with source_data as (

    select
        nullif(trim(ad_id), '') as ad_id,
        nullif(trim(ad_name), '') as ad_name,
        nullif(trim(adset_name), '') as adset_name,

        upper(nullif(trim(platform), '')) as platform,
        upper(nullif(trim(level), '')) as reporting_level,

        try_to_date(start_date) as start_date,
        try_to_date(end_date) as end_date,

        nullif(trim(first_source_click_id), '')
            as first_source_click_id,

        nullif(trim(first_source_click_name), '')
            as first_source_click_name,

        coalesce(try_to_number(first_source_leads), 0)
            as first_source_leads,

        coalesce(try_to_number(first_source_new_leads), 0)
            as first_source_new_leads,

        coalesce(try_to_number(first_source_calls), 0)
            as first_source_calls,

        coalesce(try_to_number(first_source_qualified_calls), 0)
            as first_source_qualified_calls,

        coalesce(try_to_number(first_source_sales), 0)
            as first_source_sales,

        coalesce(try_to_decimal(first_source_revenue, 18, 2), 0)
            as first_source_revenue,

        coalesce(
            try_to_decimal(first_source_recurring_revenue, 18, 2),
            0
        ) as first_source_recurring_revenue,

        coalesce(
            try_to_decimal(first_source_total_revenue, 18, 2),
            0
        ) as first_source_total_revenue,

        coalesce(try_to_decimal(first_source_profit, 18, 2), 0)
            as first_source_profit,

        coalesce(try_to_decimal(first_source_cost, 18, 2), 0)
            as first_source_cost,

        coalesce(try_to_decimal(first_source_roi, 18, 6), 0)
            as first_source_roi,

        coalesce(try_to_decimal(first_source_roas, 18, 6), 0)
            as first_source_roas,

        coalesce(try_to_number(first_source_clicks), 0)
            as first_source_clicks,

        coalesce(try_to_number(first_source_impressions), 0)
            as first_source_impressions,

        coalesce(try_to_decimal(first_source_ctr, 18, 6), 0)
            as first_source_ctr,

        coalesce(try_to_decimal(first_source_cpm, 18, 6), 0)
            as first_source_cpm,

        coalesce(try_to_decimal(first_source_cvr, 18, 6), 0)
            as first_source_cvr,

        coalesce(
            try_to_decimal(first_source_cost_per_lead, 18, 6),
            0
        ) as first_source_cost_per_lead,

        coalesce(
            try_to_decimal(first_source_cost_per_click, 18, 6),
            0
        ) as first_source_cost_per_click,

        coalesce(
            try_to_decimal(first_source_cost_per_call, 18, 6),
            0
        ) as first_source_cost_per_call,

        nullif(trim(last_source_click_id), '')
            as last_source_click_id,

        nullif(trim(last_source_click_name), '')
            as last_source_click_name,

        coalesce(try_to_number(last_source_leads), 0)
            as last_source_leads,

        coalesce(try_to_number(last_source_new_leads), 0)
            as last_source_new_leads,

        coalesce(try_to_number(last_source_calls), 0)
            as last_source_calls,

        coalesce(try_to_number(last_source_qualified_calls), 0)
            as last_source_qualified_calls,

        coalesce(try_to_number(last_source_sales), 0)
            as last_source_sales,

        coalesce(try_to_decimal(last_source_revenue, 18, 2), 0)
            as last_source_revenue,

        coalesce(
            try_to_decimal(last_source_recurring_revenue, 18, 2),
            0
        ) as last_source_recurring_revenue,

        coalesce(
            try_to_decimal(last_source_total_revenue, 18, 2),
            0
        ) as last_source_total_revenue,

        coalesce(try_to_decimal(last_source_profit, 18, 2), 0)
            as last_source_profit,

        coalesce(try_to_decimal(last_source_cost, 18, 2), 0)
            as last_source_cost,

        coalesce(try_to_decimal(last_source_roi, 18, 6), 0)
            as last_source_roi,

        coalesce(try_to_decimal(last_source_roas, 18, 6), 0)
            as last_source_roas,

        coalesce(try_to_number(last_source_clicks), 0)
            as last_source_clicks,

        coalesce(try_to_number(last_source_impressions), 0)
            as last_source_impressions,

        coalesce(try_to_decimal(last_source_ctr, 18, 6), 0)
            as last_source_ctr,

        coalesce(try_to_decimal(last_source_cpm, 18, 6), 0)
            as last_source_cpm,

        coalesce(try_to_decimal(last_source_cvr, 18, 6), 0)
            as last_source_cvr,

        coalesce(
            try_to_decimal(last_source_cost_per_lead, 18, 6),
            0
        ) as last_source_cost_per_lead,

        coalesce(
            try_to_decimal(last_source_cost_per_click, 18, 6),
            0
        ) as last_source_cost_per_click,

        coalesce(
            try_to_decimal(last_source_cost_per_call, 18, 6),
            0
        ) as last_source_cost_per_call,

        nullif(trim(scientific_source_click_id), '')
            as scientific_source_click_id,

        nullif(trim(scientific_source_click_name), '')
            as scientific_source_click_name,

        coalesce(try_to_number(scientific_source_leads), 0)
            as scientific_source_leads,

        coalesce(try_to_number(scientific_source_new_leads), 0)
            as scientific_source_new_leads,

        coalesce(try_to_number(scientific_source_calls), 0)
            as scientific_source_calls,

        coalesce(try_to_number(scientific_source_qualified_calls), 0)
            as scientific_source_qualified_calls,

        coalesce(try_to_number(scientific_source_sales), 0)
            as scientific_source_sales,

        coalesce(
            try_to_decimal(scientific_source_revenue, 18, 2),
            0
        ) as scientific_source_revenue,

        coalesce(
            try_to_decimal(scientific_source_recurring_revenue, 18, 2),
            0
        ) as scientific_source_recurring_revenue,

        coalesce(
            try_to_decimal(scientific_source_total_revenue, 18, 2),
            0
        ) as scientific_source_total_revenue,

        coalesce(
            try_to_decimal(scientific_source_profit, 18, 2),
            0
        ) as scientific_source_profit,

        coalesce(
            try_to_decimal(scientific_source_cost, 18, 2),
            0
        ) as scientific_source_cost,

        coalesce(
            try_to_decimal(scientific_source_roi, 18, 6),
            0
        ) as scientific_source_roi,

        coalesce(
            try_to_decimal(scientific_source_roas, 18, 6),
            0
        ) as scientific_source_roas,

        coalesce(try_to_number(scientific_source_clicks), 0)
            as scientific_source_clicks,

        coalesce(try_to_number(scientific_source_impressions), 0)
            as scientific_source_impressions,

        coalesce(
            try_to_decimal(scientific_source_ctr, 18, 6),
            0
        ) as scientific_source_ctr,

        coalesce(
            try_to_decimal(scientific_source_cpm, 18, 6),
            0
        ) as scientific_source_cpm,

        coalesce(
            try_to_decimal(scientific_source_cvr, 18, 6),
            0
        ) as scientific_source_cvr,

        coalesce(
            try_to_decimal(scientific_source_cost_per_lead, 18, 6),
            0
        ) as scientific_source_cost_per_lead,

        coalesce(
            try_to_decimal(scientific_source_cost_per_click, 18, 6),
            0
        ) as scientific_source_cost_per_click,

        coalesce(
            try_to_decimal(scientific_source_cost_per_call, 18, 6),
            0
        ) as scientific_source_cost_per_call,

        nullif(trim(md5_hash), '') as md5_hash,

        try_to_timestamp_ntz(insert_date) as source_insert_at,
        try_to_timestamp_ntz(update_date) as source_update_at,

        source_file_name,
        source_file_row_number,
        source_file_last_modified,
        load_timestamp

    from {{ source('bronze', 'hyros_ad_attribution_raw') }}

    {% if is_incremental() %}

        where load_timestamp >= (
            select dateadd(
                day,
                -2,
                coalesce(max(load_timestamp), '1900-01-01'::timestamp_tz)
            )
            from {{ this }}
        )

    {% endif %}

),

keyed as (

    select
        md5(
            concat_ws(
                '|',
                coalesce(ad_id, ''),
                coalesce(start_date::varchar, ''),
                coalesce(end_date::varchar, ''),
                coalesce(reporting_level, '')
            )
        ) as ad_performance_key,

        *

    from source_data

),

ranked as (

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

    from keyed

    where ad_id is not null
      and start_date is not null

)

select
    * exclude row_num

from ranked

where row_num = 1