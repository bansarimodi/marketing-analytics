{{ config(
    materialized = 'table'
) }}

select
    created_at::date as created_date,
    attribution_type,
    platform_name,
    campaign_id,
    campaign_name,

    count(distinct lead_id) as total_leads,

    count(
        distinct case
            when click_at is not null then lead_id
        end
    ) as leads_with_click,

    min(click_at) as earliest_click_at,
    max(click_at) as latest_click_at

from {{ ref('fact_lead_attribution') }}

group by
    created_at::date,
    attribution_type,
    platform_name,
    campaign_id,
    campaign_name