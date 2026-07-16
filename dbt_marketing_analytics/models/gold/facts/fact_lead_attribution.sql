{{
    config(
        materialized='table'
    )
}}

-- =====================================================================
-- FACT: LEAD ATTRIBUTION
--
-- Grain:
--   One row per LEAD_ID and ATTRIBUTION_TYPE.
--
-- Each lead can generate:
--   - One FIRST_TOUCH row
--   - One LAST_TOUCH row
-- =====================================================================

with first_touch as (

    select
        md5(
            concat_ws(
                '|',
                lead_id,
                'FIRST_TOUCH'
            )
        ) as lead_attribution_key,

        lead_id,
        created_at,
        cast(created_at as date) as lead_created_date,

        'FIRST_TOUCH' as attribution_type,

        first_source_click_at as attribution_click_at,
        first_source_platform_name as platform,
        first_source_campaign_id as campaign_id,
        first_source_campaign_name as campaign_name,
        first_source_adset_id as adset_id,
        first_source_adset_name as adset_name,
        first_source_ad_id as ad_id,
        first_source_ad_name as ad_name,
        first_source_traffic_id as traffic_id,
        first_source_traffic_name as traffic_name,

        datediff(
            second,
            first_source_click_at,
            created_at
        ) as seconds_from_click_to_lead,

        1 as lead_count

    from {{ ref('silver_hyros_leads') }}

),

last_touch as (

    select
        md5(
            concat_ws(
                '|',
                lead_id,
                'LAST_TOUCH'
            )
        ) as lead_attribution_key,

        lead_id,
        created_at,
        cast(created_at as date) as lead_created_date,

        'LAST_TOUCH' as attribution_type,

        last_source_click_at as attribution_click_at,
        last_source_platform_name as platform,
        last_source_campaign_id as campaign_id,
        last_source_campaign_name as campaign_name,
        last_source_adset_id as adset_id,
        last_source_adset_name as adset_name,
        last_source_ad_id as ad_id,
        last_source_ad_name as ad_name,
        last_source_traffic_id as traffic_id,
        last_source_traffic_name as traffic_name,

        datediff(
            second,
            last_source_click_at,
            created_at
        ) as seconds_from_click_to_lead,

        1 as lead_count

    from {{ ref('silver_hyros_leads') }}

)

select * from first_touch

union all

select * from last_touch