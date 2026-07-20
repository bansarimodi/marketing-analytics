{{ config(
    materialized = 'table'
) }}

with ad_records as (

    select
        upper(trim(platform)) as platform_name,
        trim(ad_id) as ad_id,
        trim(ad_name) as ad_name,
        trim(adset_name) as adset_name,
        reporting_level,
        source_update_at,
        load_timestamp

    from {{ ref('silver_hyros_ad_attribution') }}

    where ad_id is not null
       or ad_name is not null

    union all

    select
        upper(trim(first_source_platform_name)) as platform_name,
        trim(first_source_ad_id) as ad_id,
        trim(first_source_ad_name) as ad_name,
        trim(first_source_adset_name) as adset_name,
        null as reporting_level,
        source_update_at,
        load_timestamp

    from {{ ref('silver_hyros_leads') }}

    where first_source_ad_id is not null
       or first_source_ad_name is not null

    union all

    select
        upper(trim(last_source_platform_name)) as platform_name,
        trim(last_source_ad_id) as ad_id,
        trim(last_source_ad_name) as ad_name,
        trim(last_source_adset_name) as adset_name,
        null as reporting_level,
        source_update_at,
        load_timestamp

    from {{ ref('silver_hyros_leads') }}

    where last_source_ad_id is not null
       or last_source_ad_name is not null

),

keyed as (

    select
        md5(
            concat_ws(
                '|',
                coalesce(platform_name, 'UNKNOWN'),
                coalesce(ad_id, 'UNKNOWN'),
                coalesce(ad_name, 'UNKNOWN'),
                coalesce(adset_name, 'UNKNOWN')
            )
        ) as ad_key,

        *

    from ad_records

),

ranked as (

    select
        *,
        row_number() over (
            partition by ad_key
            order by
                source_update_at desc nulls last,
                load_timestamp desc
        ) as row_num

    from keyed

)

select
    ad_key,
    platform_name,
    ad_id,
    ad_name,
    adset_name,
    reporting_level

from ranked

where row_num = 1