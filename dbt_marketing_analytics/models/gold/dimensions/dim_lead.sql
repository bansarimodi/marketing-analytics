{{
    config(
        materialized='table'
    )
}}

-- =====================================================================
-- DIMENSION: LEAD
--
-- Grain:
--   One row per LEAD_ID.
--
-- Purpose:
--   Stores reusable lead and attribution attributes.
-- =====================================================================

select
    lead_id,

    created_at,
    cast(created_at as date) as created_date,

    first_source_click_at,
    first_source_platform_name,
    first_source_campaign_id,
    first_source_campaign_name,
    first_source_adset_id,
    first_source_adset_name,
    first_source_ad_id,
    first_source_ad_name,
    first_source_traffic_id,
    first_source_traffic_name,

    last_source_click_at,
    last_source_platform_name,
    last_source_campaign_id,
    last_source_campaign_name,
    last_source_adset_id,
    last_source_adset_name,
    last_source_ad_id,
    last_source_ad_name,
    last_source_traffic_id,
    last_source_traffic_name,

    case
        when first_source_campaign_id is not null
         and first_source_campaign_id = last_source_campaign_id
        then true
        else false
    end as is_same_first_last_campaign,

    case
        when first_source_ad_id is not null
         and first_source_ad_id = last_source_ad_id
        then true
        else false
    end as is_same_first_last_ad,

    datediff(
        second,
        first_source_click_at,
        created_at
    ) as first_touch_seconds_to_lead,

    datediff(
        second,
        last_source_click_at,
        created_at
    ) as last_touch_seconds_to_lead,

    source_insert_at,
    source_update_at,
    load_timestamp

from {{ ref('silver_hyros_leads') }}