<<<<<<< HEAD
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='lead_id',
        on_schema_change='sync_all_columns'
    )
}}

-- =====================================================================
-- SILVER MODEL: HYROS LEADS
--
-- Grain:
--   One row per LEAD_ID.
--
-- Responsibilities:
--   - Convert empty strings to NULL
--   - Standardize text fields
--   - Convert source dates into timestamps
--   - Deduplicate repeated lead versions
--   - Keep the latest version of each lead
--   - Preserve source lineage metadata
-- =====================================================================
=======
{{ config(
    materialized = 'incremental',
    unique_key = 'lead_id',
    incremental_strategy = 'merge',
    on_schema_change = 'sync_all_columns'
) }}
>>>>>>> ff66700 (final)

with source_data as (

    select
<<<<<<< HEAD
        *

    from {{ source('bronze', 'hyros_leads_raw') }}

    {% if is_incremental() %}

        -- Reprocess a small lookback window to support late-arriving
        -- or recently updated records.
        where load_timestamp >= (

            select coalesce(
                dateadd(day, -2, max(load_timestamp)),
                '1900-01-01'::timestamp_tz
            )
            from {{ this }}

        )

    {% endif %}

),

cleaned as (

    select
        -- -------------------------------------------------------------
        -- Lead identity
        -- -------------------------------------------------------------

=======
>>>>>>> ff66700 (final)
        nullif(trim(lead_id), '') as lead_id,

        try_to_timestamp_ntz(created_date) as created_at,

<<<<<<< HEAD
        -- -------------------------------------------------------------
        -- First-touch attribution
        -- -------------------------------------------------------------

=======
>>>>>>> ff66700 (final)
        try_to_timestamp_ntz(first_source_click_date)
            as first_source_click_at,

        nullif(trim(first_source_ad_account_id), '')
            as first_source_ad_account_id,

        nullif(trim(first_source_adset_id), '')
            as first_source_adset_id,

        upper(nullif(trim(first_source_platform_name), ''))
            as first_source_platform_name,

        nullif(trim(first_source_campaign_id), '')
            as first_source_campaign_id,

        nullif(trim(first_source_campaign_name), '')
            as first_source_campaign_name,

        nullif(trim(first_source_traffic_id), '')
            as first_source_traffic_id,

        nullif(trim(first_source_traffic_name), '')
            as first_source_traffic_name,

        nullif(trim(first_source_adset), '')
            as first_source_adset_name,

        nullif(trim(first_source_ad_name), '')
            as first_source_ad_name,

        nullif(trim(first_source_ad_id), '')
            as first_source_ad_id,

<<<<<<< HEAD
        -- -------------------------------------------------------------
        -- Last-touch attribution
        -- -------------------------------------------------------------

=======
>>>>>>> ff66700 (final)
        try_to_timestamp_ntz(last_source_click_date)
            as last_source_click_at,

        nullif(trim(last_source_ad_account_id), '')
            as last_source_ad_account_id,

        nullif(trim(last_source_adset_id), '')
            as last_source_adset_id,

        upper(nullif(trim(last_source_platform_name), ''))
            as last_source_platform_name,

        nullif(trim(last_source_campaign_id), '')
            as last_source_campaign_id,

        nullif(trim(last_source_campaign_name), '')
            as last_source_campaign_name,

        nullif(trim(last_source_traffic_id), '')
            as last_source_traffic_id,

        nullif(trim(last_source_traffic_name), '')
            as last_source_traffic_name,

        nullif(trim(last_source_adset), '')
            as last_source_adset_name,

        nullif(trim(last_source_ad_name), '')
            as last_source_ad_name,

        nullif(trim(last_source_ad_id), '')
            as last_source_ad_id,

<<<<<<< HEAD
        -- -------------------------------------------------------------
        -- Source audit fields
        -- -------------------------------------------------------------

=======
>>>>>>> ff66700 (final)
        nullif(trim(md5_hash), '') as md5_hash,

        try_to_timestamp_ntz(insert_date)
            as source_insert_at,

        try_to_timestamp_ntz(update_date)
            as source_update_at,

        source_file_name,
        source_file_row_number,
        source_file_last_modified,
        load_timestamp

<<<<<<< HEAD
    from source_data

),

deduplicated as (

    select
        *,

=======
    from {{ source('bronze', 'hyros_leads_raw') }}

    {% if is_incremental() %}

        where load_timestamp > (
            select coalesce(
                max(load_timestamp),
                '1900-01-01'::timestamp_tz
            )
            from {{ this }}
        )

    {% endif %}

),

ranked as (

    select
        *,
>>>>>>> ff66700 (final)
        row_number() over (
            partition by lead_id
            order by
                source_update_at desc nulls last,
                source_insert_at desc nulls last,
                load_timestamp desc,
                source_file_row_number desc
        ) as row_num

<<<<<<< HEAD
    from cleaned
=======
    from source_data
>>>>>>> ff66700 (final)

    where lead_id is not null

)

select
<<<<<<< HEAD
    lead_id,
    created_at,

    first_source_click_at,
    first_source_ad_account_id,
    first_source_adset_id,
    first_source_platform_name,
    first_source_campaign_id,
    first_source_campaign_name,
    first_source_traffic_id,
    first_source_traffic_name,
    first_source_adset_name,
    first_source_ad_name,
    first_source_ad_id,

    last_source_click_at,
    last_source_ad_account_id,
    last_source_adset_id,
    last_source_platform_name,
    last_source_campaign_id,
    last_source_campaign_name,
    last_source_traffic_id,
    last_source_traffic_name,
    last_source_adset_name,
    last_source_ad_name,
    last_source_ad_id,

    md5_hash,
    source_insert_at,
    source_update_at,

    source_file_name,
    source_file_row_number,
    source_file_last_modified,
    load_timestamp

from deduplicated
=======
    * exclude row_num

from ranked
>>>>>>> ff66700 (final)

where row_num = 1