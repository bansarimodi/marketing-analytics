{{ config(
    materialized = 'table'
) }}

with first_touch as (

    select
        md5(
            concat_ws(
                '|',
                lead_id,
                'FIRST_TOUCH'
            )
        ) as lead_attribution_fact_key,

        lead_id,
        'FIRST_TOUCH' as attribution_type,

        to_number(to_char(created_at::date, 'YYYYMMDD')) as date_key,

        md5(upper(trim(first_source_platform_name)))
            as platform_key,

        md5(
            concat_ws(
                '|',
                coalesce(
                    upper(trim(first_source_platform_name)),
                    'UNKNOWN'
                ),
                coalesce(trim(first_source_campaign_id), 'UNKNOWN'),
                coalesce(trim(first_source_campaign_name), 'UNKNOWN')
            )
        ) as campaign_key,

        md5(
            concat_ws(
                '|',
                coalesce(
                    upper(trim(first_source_platform_name)),
                    'UNKNOWN'
                ),
                coalesce(trim(first_source_ad_id), 'UNKNOWN'),
                coalesce(trim(first_source_ad_name), 'UNKNOWN'),
                coalesce(trim(first_source_adset_name), 'UNKNOWN')
            )
        ) as ad_key,

        created_at,
        first_source_click_at as click_at,

        first_source_platform_name as platform_name,
        first_source_campaign_id as campaign_id,
        first_source_campaign_name as campaign_name,

        first_source_adset_id as adset_id,
        first_source_adset_name as adset_name,

        first_source_ad_id as ad_id,
        first_source_ad_name as ad_name,

        first_source_traffic_id as traffic_id,
        first_source_traffic_name as traffic_name

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
        ) as lead_attribution_fact_key,

        lead_id,
        'LAST_TOUCH' as attribution_type,

        to_number(to_char(created_at::date, 'YYYYMMDD')) as date_key,

        md5(upper(trim(last_source_platform_name)))
            as platform_key,

        md5(
            concat_ws(
                '|',
                coalesce(
                    upper(trim(last_source_platform_name)),
                    'UNKNOWN'
                ),
                coalesce(trim(last_source_campaign_id), 'UNKNOWN'),
                coalesce(trim(last_source_campaign_name), 'UNKNOWN')
            )
        ) as campaign_key,

        md5(
            concat_ws(
                '|',
                coalesce(
                    upper(trim(last_source_platform_name)),
                    'UNKNOWN'
                ),
                coalesce(trim(last_source_ad_id), 'UNKNOWN'),
                coalesce(trim(last_source_ad_name), 'UNKNOWN'),
                coalesce(trim(last_source_adset_name), 'UNKNOWN')
            )
        ) as ad_key,

        created_at,
        last_source_click_at as click_at,

        last_source_platform_name as platform_name,
        last_source_campaign_id as campaign_id,
        last_source_campaign_name as campaign_name,

        last_source_adset_id as adset_id,
        last_source_adset_name as adset_name,

        last_source_ad_id as ad_id,
        last_source_ad_name as ad_name,

        last_source_traffic_id as traffic_id,
        last_source_traffic_name as traffic_name

    from {{ ref('silver_hyros_leads') }}

)

select * from first_touch

union all

select * from last_touch