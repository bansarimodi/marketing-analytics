{{ config(
    materialized = 'table',
    schema = 'gold'
) }}

with platforms as (

    select platform as platform_name
    from {{ ref('silver_hyros_ad_attribution') }}
    where nullif(trim(platform), '') is not null

    union

    select first_source_platform_name
    from {{ ref('silver_hyros_leads') }}
    where nullif(trim(first_source_platform_name), '') is not null

    union

    select last_source_platform_name
    from {{ ref('silver_hyros_leads') }}
    where nullif(trim(last_source_platform_name), '') is not null

    union

    select 'UNKNOWN' as platform_name

),

cleaned as (

    select distinct
        upper(trim(platform_name)) as platform_name

    from platforms

)

select
    md5(platform_name) as platform_key,
    platform_name

from cleaned