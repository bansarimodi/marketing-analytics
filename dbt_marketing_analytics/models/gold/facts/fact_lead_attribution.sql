<<<<<<< HEAD
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
=======
{{ config(
    materialized = 'table',
    schema = 'gold'
) }}

select
    lead_id as lead_attribution_fact_key,
    lead_id,

    case
        when created_at is not null
        then to_number(
            to_char(created_at::date, 'YYYYMMDD')
        )
    end as created_date_key,

    case
        when first_source_click_at is not null
        then to_number(
            to_char(first_source_click_at::date, 'YYYYMMDD')
        )
    end as first_click_date_key,

    case
        when last_source_click_at is not null
        then to_number(
            to_char(last_source_click_at::date, 'YYYYMMDD')
        )
    end as last_click_date_key,

    /* First-Touch dimension keys */

    case
        when first_source_platform_name is not null
        then md5(first_source_platform_name)
    end as first_platform_key,

    case
        when coalesce(
            first_source_campaign_id,
            first_source_campaign_name
        ) is not null
        then md5(
            concat_ws(
                '|',
                coalesce(
                    first_source_platform_name,
                    'UNKNOWN'
                ),
                coalesce(
                    first_source_campaign_id,
                    first_source_campaign_name
                )
            )
        )
    end as first_campaign_key,

    case
        when coalesce(
            first_source_ad_id,
            first_source_ad_name
        ) is not null
        then md5(
            concat_ws(
                '|',
                coalesce(
                    first_source_platform_name,
                    'UNKNOWN'
                ),
                coalesce(
                    first_source_ad_id,
                    first_source_ad_name
                )
            )
        )
    end as first_ad_key,

    first_source_traffic_id,
    first_source_traffic_name,
    first_source_ad_account_id,
    first_source_adset_id,
    first_source_adset_name,

    /* Last-Touch dimension keys */

    case
        when last_source_platform_name is not null
        then md5(last_source_platform_name)
    end as last_platform_key,

    case
        when coalesce(
            last_source_campaign_id,
            last_source_campaign_name
        ) is not null
        then md5(
            concat_ws(
                '|',
                coalesce(
                    last_source_platform_name,
                    'UNKNOWN'
                ),
                coalesce(
                    last_source_campaign_id,
                    last_source_campaign_name
                )
            )
        )
    end as last_campaign_key,

    case
        when coalesce(
            last_source_ad_id,
            last_source_ad_name
        ) is not null
        then md5(
            concat_ws(
                '|',
                coalesce(
                    last_source_platform_name,
                    'UNKNOWN'
                ),
                coalesce(
                    last_source_ad_id,
                    last_source_ad_name
                )
            )
        )
    end as last_ad_key,

    last_source_traffic_id,
    last_source_traffic_name,
    last_source_ad_account_id,
    last_source_adset_id,
    last_source_adset_name,

    source_insert_at,
    source_update_at,
    load_timestamp

from {{ ref('silver_hyros_leads') }}
>>>>>>> ff66700 (final)
