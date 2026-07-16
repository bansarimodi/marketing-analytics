{{
    config(
        materialized='table'
    )
}}

select
    lead_created_date,
    attribution_type,

    coalesce(platform, 'UNKNOWN')
        as platform,

    coalesce(campaign_id, 'UNKNOWN')
        as campaign_id,

    coalesce(campaign_name, 'UNKNOWN')
        as campaign_name,

    count(distinct lead_id)
        as unique_leads,

    sum(lead_count)
        as attributed_leads,

    avg(seconds_from_click_to_lead)
        as average_seconds_from_click_to_lead,

    avg(seconds_from_click_to_lead) / 3600.0
        as average_hours_from_click_to_lead

from {{ ref('fact_lead_attribution') }}

group by
    lead_created_date,
    attribution_type,
    platform,
    campaign_id,
    campaign_name