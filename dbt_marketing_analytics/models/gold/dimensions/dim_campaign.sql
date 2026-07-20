{{ config(
    materialized = 'table'
) }}

with campaigns as (

    select
        upper(trim(first_source_platform_name)) as platform_name,
        trim(first_source_campaign_id) as campaign_id,
        trim(first_source_campaign_name) as campaign_name,
        source_update_at,
        load_timestamp

    from {{ ref('silver_hyros_leads') }}

    where first_source_campaign_id is not null
       or first_source_campaign_name is not null

    union all

    select
        upper(trim(last_source_platform_name)) as platform_name,
        trim(last_source_campaign_id) as campaign_id,
        trim(last_source_campaign_name) as campaign_name,
        source_update_at,
        load_timestamp

    from {{ ref('silver_hyros_leads') }}

    where last_source_campaign_id is not null
       or last_source_campaign_name is not null

),

keyed as (

    select
        md5(
            concat_ws(
                '|',
                coalesce(platform_name, 'UNKNOWN'),
                coalesce(campaign_id, 'UNKNOWN'),
                coalesce(campaign_name, 'UNKNOWN')
            )
        ) as campaign_key,

        *

    from campaigns

),

ranked as (

    select
        *,
        row_number() over (
            partition by campaign_key
            order by
                source_update_at desc nulls last,
                load_timestamp desc
        ) as row_num

    from keyed

)

select
    campaign_key,
    platform_name,
    campaign_id,
    campaign_name

from ranked

where row_num = 1