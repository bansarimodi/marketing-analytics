{{ config(
    materialized = 'table',
    schema = 'gold'
) }}

with campaigns as (

    select
        first_source_platform_name as platform_name,
        first_source_campaign_id as campaign_id,
        first_source_campaign_name as campaign_name,
        source_update_at

    from {{ ref('silver_hyros_leads') }}

    where first_source_campaign_id is not null
       or first_source_campaign_name is not null

    union all

    select
        last_source_platform_name as platform_name,
        last_source_campaign_id as campaign_id,
        last_source_campaign_name as campaign_name,
        source_update_at

    from {{ ref('silver_hyros_leads') }}

    where last_source_campaign_id is not null
       or last_source_campaign_name is not null

),

cleaned as (

    select
        upper(
            coalesce(
                nullif(trim(platform_name), ''),
                'UNKNOWN'
            )
        ) as platform_name,

        nullif(trim(campaign_id), '') as campaign_id,
        nullif(trim(campaign_name), '') as campaign_name,
        source_update_at

    from campaigns

),

keyed as (

    select
        md5(
            concat_ws(
                '|',
                platform_name,
                coalesce(campaign_id, campaign_name)
            )
        ) as campaign_key,

        md5(platform_name) as platform_key,

        platform_name,
        campaign_id,
        campaign_name,
        source_update_at

    from cleaned

    where coalesce(campaign_id, campaign_name) is not null

),

ranked as (

    select
        *,

        row_number() over (
            partition by campaign_key
            order by
                source_update_at desc nulls last,
                campaign_name desc nulls last
        ) as row_num

    from keyed

)

select
    campaign_key,
    platform_key,
    platform_name,
    campaign_id,
    campaign_name

from ranked

where row_num = 1