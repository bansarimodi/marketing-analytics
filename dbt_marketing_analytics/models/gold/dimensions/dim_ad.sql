<<<<<<< HEAD
{{
    config(
        materialized='table'
    )
}}

-- =====================================================================
-- DIMENSION: AD
--
-- Grain:
--   One row per AD_ID.
--
-- Purpose:
--   Provides the latest descriptive attributes for each advertisement.
-- =====================================================================

with ranked_ads as (

    select
        ad_id,
        ad_name,
        adset_name,
        platform,
        reporting_level,

        source_update_at,
        load_timestamp,

        row_number() over (
            partition by ad_id
            order by
                source_update_at desc nulls last,
                load_timestamp desc
        ) as row_num
=======
{{ config(
    materialized = 'table',
    schema = 'gold'
) }}

with advertisements as (

    select
        platform as platform_name,
        ad_id,
        ad_name,
        adset_name,
        source_update_at
>>>>>>> ff66700 (final)

    from {{ ref('silver_hyros_ad_attribution') }}

    where ad_id is not null

<<<<<<< HEAD
)

select
    ad_id,
    ad_name,
    adset_name,
    platform,
    reporting_level,

    case
        when adset_name is null then 'UNKNOWN'
        else adset_name
    end as adset_name_reporting,

    source_update_at,
    load_timestamp

from ranked_ads
=======
    union all

    select
        first_source_platform_name as platform_name,
        first_source_ad_id as ad_id,
        first_source_ad_name as ad_name,
        first_source_adset_name as adset_name,
        source_update_at

    from {{ ref('silver_hyros_leads') }}

    where first_source_ad_id is not null
       or first_source_ad_name is not null

    union all

    select
        last_source_platform_name as platform_name,
        last_source_ad_id as ad_id,
        last_source_ad_name as ad_name,
        last_source_adset_name as adset_name,
        source_update_at

    from {{ ref('silver_hyros_leads') }}

    where last_source_ad_id is not null
       or last_source_ad_name is not null

),

cleaned as (

    select
        upper(
            coalesce(
                nullif(trim(platform_name), ''),
                'UNKNOWN'
            )
        ) as platform_name,

        nullif(trim(ad_id), '') as ad_id,
        nullif(trim(ad_name), '') as ad_name,
        nullif(trim(adset_name), '') as adset_name,
        source_update_at

    from advertisements

),

keyed as (

    select
        md5(
            concat_ws(
                '|',
                platform_name,
                coalesce(ad_id, ad_name)
            )
        ) as ad_key,

        md5(platform_name) as platform_key,

        platform_name,
        ad_id,
        ad_name,
        adset_name,
        source_update_at

    from cleaned

    where coalesce(ad_id, ad_name) is not null

),

ranked as (

    select
        *,

        row_number() over (
            partition by ad_key
            order by
                source_update_at desc nulls last,
                ad_name desc nulls last
        ) as row_num

    from keyed

)

select
    ad_key,
    platform_key,
    platform_name,
    ad_id,
    ad_name,
    adset_name

from ranked
>>>>>>> ff66700 (final)

where row_num = 1