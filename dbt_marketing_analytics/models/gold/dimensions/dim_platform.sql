{{ config(
    materialized = 'table'
) }}

with platforms as (

    select upper(trim(platform)) as platform_name
    from {{ ref('silver_hyros_ad_attribution') }}
    where platform is not null

    union

    select upper(trim(first_source_platform_name)) as platform_name
    from {{ ref('silver_hyros_leads') }}
    where first_source_platform_name is not null

    union

    select upper(trim(last_source_platform_name)) as platform_name
    from {{ ref('silver_hyros_leads') }}
    where last_source_platform_name is not null

)

select
    md5(platform_name) as platform_key,
    platform_name

from platforms

where platform_name is not null
  and platform_name <> ''