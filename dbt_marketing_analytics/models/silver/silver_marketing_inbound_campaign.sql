{{ config(
    materialized = 'incremental',
    unique_key = 'inbound_activity_key',
    incremental_strategy = 'merge',
    on_schema_change = 'sync_all_columns'
) }}

with source_data as (

    select
        nullif(trim(first_source_calendly_campaign), '')
            as first_source_calendly_campaign,

        nullif(trim(first_source), '')
            as first_source,

        nullif(trim(last_source_calendly_campaign), '')
            as last_source_calendly_campaign,

        nullif(trim(last_source), '')
            as last_source,

        try_to_timestamp_ntz(activity_log_date)
            as activity_log_at,

        upper(nullif(trim(status), ''))
            as status,

        try_to_date(triage_call_date)
            as triage_call_date,

        nullif(trim(triage_year_week), '')
            as triage_year_week,

        nullif(trim(setter_closer_name), '')
            as setter_closer_name,

        nullif(trim(lead_id), '')
            as lead_id,

        upper(nullif(trim(taken_status), ''))
            as taken_status,

        upper(nullif(trim(strategy_call_status), ''))
            as strategy_call_status,

        upper(nullif(trim(strategy_call_taken_status), ''))
            as strategy_call_taken_status,

        nullif(trim(closer_name), '')
            as closer_name,

        upper(nullif(trim(sale_status), ''))
            as sale_status,

        coalesce(
            try_to_decimal(contracted_value, 18, 2),
            0
        ) as contracted_value,

        source_file_name,
        source_file_row_number,
        source_file_last_modified,
        load_timestamp

    from {{ source('bronze', 'marketing_inbound_campaign_raw') }}

    {% if is_incremental() %}

        where load_timestamp >= (
            select dateadd(
                day,
                -2,
                coalesce(max(load_timestamp), '1900-01-01'::timestamp_tz)
            )
            from {{ this }}
        )

    {% endif %}

),

keyed as (

    select
        md5(
            concat_ws(
                '|',
                coalesce(lead_id, ''),
                coalesce(activity_log_at::varchar, ''),
                coalesce(status, ''),
                coalesce(triage_call_date::varchar, ''),
                coalesce(strategy_call_status, ''),
                coalesce(sale_status, ''),
                coalesce(contracted_value::varchar, '')
            )
        ) as inbound_activity_key,

        *

    from source_data

),

ranked as (

    select
        *,
        row_number() over (
            partition by inbound_activity_key
            order by
                load_timestamp desc,
                source_file_row_number desc
        ) as row_num

    from keyed

)

select
    * exclude row_num

from ranked

where row_num = 1