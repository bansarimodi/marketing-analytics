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

    from {{ ref('silver_hyros_ad_attribution') }}

    where ad_id is not null

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

where row_num = 1