<<<<<<< HEAD
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='inbound_activity_key',
        on_schema_change='sync_all_columns'
    )
}}

-- =====================================================================
-- SILVER MODEL: MARKETING INBOUND CAMPAIGN
--
-- Grain:
--   One row per unique lead sales-funnel activity.
--
-- Responsibilities:
--   - Convert empty strings to NULL
--   - Convert dates and contracted value into proper types
--   - Standardize status text casing and whitespace
--   - Generate a stable activity key
--   - Deduplicate repeated source activities
--   - Preserve source lineage metadata
--
-- Business flags such as HAS_SALE and HAS_TRIAGE_CALL belong in Gold.
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

    from {{ source('bronze', 'marketing_inbound_campaign_raw') }}

    {% if is_incremental() %}

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
        -- Marketing source information
        -- -------------------------------------------------------------

        nullif(trim(first_source_calendly_campaign), '')
            as first_source_calendly_campaign,

        upper(nullif(trim(first_source), ''))
=======
        nullif(trim(first_source_calendly_campaign), '')
            as first_source_calendly_campaign,

        nullif(trim(first_source), '')
>>>>>>> ff66700 (final)
            as first_source,

        nullif(trim(last_source_calendly_campaign), '')
            as last_source_calendly_campaign,

<<<<<<< HEAD
        upper(nullif(trim(last_source), ''))
            as last_source,

        -- -------------------------------------------------------------
        -- Sales funnel activity
        -- -------------------------------------------------------------

        try_to_timestamp_ntz(activity_log_date)
            as activity_log_at,

        upper(
            regexp_replace(
                nullif(trim(status), ''),
                '\\s+',
                ' '
            )
        ) as status,
=======
        nullif(trim(last_source), '')
            as last_source,

        try_to_timestamp_ntz(activity_log_date)
            as activity_log_at,

        upper(nullif(trim(status), ''))
            as status,
>>>>>>> ff66700 (final)

        try_to_date(triage_call_date)
            as triage_call_date,

        nullif(trim(triage_year_week), '')
            as triage_year_week,

<<<<<<< HEAD
        nullif(trim(setter_closer_name), '')
            as setter_closer_name,

        nullif(trim(lead_id), '')
            as lead_id,

        upper(
            regexp_replace(
                nullif(trim(taken_status), ''),
                '\\s+',
                ' '
            )
        ) as taken_status,

        upper(
            regexp_replace(
                nullif(trim(strategy_call_status), ''),
                '\\s+',
                ' '
            )
        ) as strategy_call_status,

        upper(
            regexp_replace(
                nullif(trim(strategy_call_taken_status), ''),
                '\\s+',
                ' '
            )
        ) as strategy_call_taken_status,

        nullif(trim(closer_name), '')
            as closer_name,

        upper(
            regexp_replace(
                nullif(trim(sale_status), ''),
                '\\s+',
                ' '
            )
        ) as sale_status,

        try_to_decimal(contracted_value, 18, 2)
            as contracted_value,

        -- -------------------------------------------------------------
        -- Source lineage
        -- -------------------------------------------------------------
=======
        nullif(trim(lead_id), '')
            as lead_id,

        upper(nullif(trim(taken_status), ''))
            as taken_status,

        upper(nullif(trim(strategy_call_status), ''))
            as strategy_call_status,

        upper(nullif(trim(strategy_call_taken_status), ''))
            as strategy_call_taken_status,

        upper(nullif(trim(sale_status), ''))
            as sale_status,

        coalesce(
            try_to_decimal(contracted_value, 18, 2),
            0
        ) as contracted_value,
>>>>>>> ff66700 (final)

        source_file_name,
        source_file_row_number,
        source_file_last_modified,
        load_timestamp

<<<<<<< HEAD
    from source_data

),

with_activity_key as (

    select
        md5(
            concat_ws(
                '|',
                coalesce(lead_id, ''),
                coalesce(to_varchar(activity_log_at), ''),
                coalesce(status, ''),
                coalesce(to_varchar(triage_call_date), ''),
                coalesce(taken_status, ''),
                coalesce(strategy_call_status, ''),
                coalesce(strategy_call_taken_status, ''),
                coalesce(sale_status, ''),
                coalesce(to_varchar(contracted_value), '')
            )
        ) as inbound_activity_key,

        *

    from cleaned

    where lead_id is not null

),

deduplicated as (
=======
    from {{ source(
        'bronze',
        'marketing_inbound_campaign_raw'
    ) }}

    {% if is_incremental() %}

        where load_timestamp >= (
            select coalesce(
                max(load_timestamp),
                '1900-01-01'::timestamp_tz
            )
            from {{ this }}
        )

    {% endif %}

),

ranked as (
>>>>>>> ff66700 (final)

    select
        *,

        row_number() over (
<<<<<<< HEAD
            partition by inbound_activity_key
            order by
                load_timestamp desc,
                source_file_last_modified desc nulls last,
                source_file_row_number desc
        ) as row_num

    from with_activity_key
=======
            partition by lead_id
            order by
                load_timestamp desc,
                source_file_last_modified desc nulls last,
                source_file_row_number desc,
                activity_log_at desc nulls last
        ) as row_num

    from source_data

    where lead_id is not null
>>>>>>> ff66700 (final)

)

select
<<<<<<< HEAD
    inbound_activity_key,

    first_source_calendly_campaign,
    first_source,
    last_source_calendly_campaign,
    last_source,

    activity_log_at,
    status,
    triage_call_date,
    triage_year_week,

    setter_closer_name,
    lead_id,

    taken_status,
    strategy_call_status,
    strategy_call_taken_status,

    closer_name,
    sale_status,
    contracted_value,

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