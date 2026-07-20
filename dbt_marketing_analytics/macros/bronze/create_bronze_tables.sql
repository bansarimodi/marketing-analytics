{% macro create_bronze_tables() %}

    {% set create_ad_table %}

        create table if not exists
            {{ target.database }}.BRONZE.HYROS_AD_ATTRIBUTION_RAW (

            AD_ID varchar,
            AD_NAME varchar,
            ADSET_NAME varchar,
            PLATFORM varchar,
            LEVEL varchar,
            START_DATE varchar,
            END_DATE varchar,

            FIRST_SOURCE_CLICK_ID varchar,
            FIRST_SOURCE_CLICK_NAME varchar,
            FIRST_SOURCE_LEADS varchar,
            FIRST_SOURCE_NEW_LEADS varchar,
            FIRST_SOURCE_CALLS varchar,
            FIRST_SOURCE_QUALIFIED_CALLS varchar,
            FIRST_SOURCE_SALES varchar,
            FIRST_SOURCE_REVENUE varchar,
            FIRST_SOURCE_RECURRING_REVENUE varchar,
            FIRST_SOURCE_TOTAL_REVENUE varchar,
            FIRST_SOURCE_PROFIT varchar,
            FIRST_SOURCE_COST varchar,
            FIRST_SOURCE_ROI varchar,
            FIRST_SOURCE_ROAS varchar,
            FIRST_SOURCE_CLICKS varchar,
            FIRST_SOURCE_IMPRESSIONS varchar,
            FIRST_SOURCE_CTR varchar,
            FIRST_SOURCE_CPM varchar,
            FIRST_SOURCE_CVR varchar,
            FIRST_SOURCE_COST_PER_LEAD varchar,
            FIRST_SOURCE_COST_PER_CLICK varchar,
            FIRST_SOURCE_COST_PER_CALL varchar,

            LAST_SOURCE_CLICK_ID varchar,
            LAST_SOURCE_CLICK_NAME varchar,
            LAST_SOURCE_LEADS varchar,
            LAST_SOURCE_NEW_LEADS varchar,
            LAST_SOURCE_CALLS varchar,
            LAST_SOURCE_QUALIFIED_CALLS varchar,
            LAST_SOURCE_SALES varchar,
            LAST_SOURCE_REVENUE varchar,
            LAST_SOURCE_RECURRING_REVENUE varchar,
            LAST_SOURCE_TOTAL_REVENUE varchar,
            LAST_SOURCE_PROFIT varchar,
            LAST_SOURCE_COST varchar,
            LAST_SOURCE_ROI varchar,
            LAST_SOURCE_ROAS varchar,
            LAST_SOURCE_CLICKS varchar,
            LAST_SOURCE_IMPRESSIONS varchar,
            LAST_SOURCE_CTR varchar,
            LAST_SOURCE_CPM varchar,
            LAST_SOURCE_CVR varchar,
            LAST_SOURCE_COST_PER_LEAD varchar,
            LAST_SOURCE_COST_PER_CLICK varchar,
            LAST_SOURCE_COST_PER_CALL varchar,

            SCIENTIFIC_SOURCE_CLICK_ID varchar,
            SCIENTIFIC_SOURCE_CLICK_NAME varchar,
            SCIENTIFIC_SOURCE_LEADS varchar,
            SCIENTIFIC_SOURCE_NEW_LEADS varchar,
            SCIENTIFIC_SOURCE_CALLS varchar,
            SCIENTIFIC_SOURCE_QUALIFIED_CALLS varchar,
            SCIENTIFIC_SOURCE_SALES varchar,
            SCIENTIFIC_SOURCE_REVENUE varchar,
            SCIENTIFIC_SOURCE_RECURRING_REVENUE varchar,
            SCIENTIFIC_SOURCE_TOTAL_REVENUE varchar,
            SCIENTIFIC_SOURCE_PROFIT varchar,
            SCIENTIFIC_SOURCE_COST varchar,
            SCIENTIFIC_SOURCE_ROI varchar,
            SCIENTIFIC_SOURCE_ROAS varchar,
            SCIENTIFIC_SOURCE_CLICKS varchar,
            SCIENTIFIC_SOURCE_IMPRESSIONS varchar,
            SCIENTIFIC_SOURCE_CTR varchar,
            SCIENTIFIC_SOURCE_CPM varchar,
            SCIENTIFIC_SOURCE_CVR varchar,
            SCIENTIFIC_SOURCE_COST_PER_LEAD varchar,
            SCIENTIFIC_SOURCE_COST_PER_CLICK varchar,
            SCIENTIFIC_SOURCE_COST_PER_CALL varchar,

            MD5_HASH varchar,
            INSERT_DATE varchar,
            UPDATE_DATE varchar,

            SOURCE_FILE_NAME varchar,
            SOURCE_FILE_ROW_NUMBER number,
            SOURCE_FILE_LAST_MODIFIED timestamp_tz,
            LOAD_TIMESTAMP timestamp_tz default current_timestamp()
        )

    {% endset %}

    {% set create_leads_table %}

        create table if not exists
            {{ target.database }}.BRONZE.HYROS_LEADS_RAW (

            LEAD_ID varchar,
            CREATED_DATE varchar,

            FIRST_SOURCE_CLICK_DATE varchar,
            FIRST_SOURCE_AD_ACCOUNT_ID varchar,
            FIRST_SOURCE_ADSET_ID varchar,
            FIRST_SOURCE_PLATFORM_NAME varchar,
            FIRST_SOURCE_CAMPAIGN_ID varchar,
            FIRST_SOURCE_CAMPAIGN_NAME varchar,
            FIRST_SOURCE_TRAFFIC_ID varchar,
            FIRST_SOURCE_TRAFFIC_NAME varchar,
            FIRST_SOURCE_ADSET varchar,
            FIRST_SOURCE_AD_NAME varchar,
            FIRST_SOURCE_AD_ID varchar,

            LAST_SOURCE_CLICK_DATE varchar,
            LAST_SOURCE_AD_ACCOUNT_ID varchar,
            LAST_SOURCE_ADSET_ID varchar,
            LAST_SOURCE_PLATFORM_NAME varchar,
            LAST_SOURCE_CAMPAIGN_ID varchar,
            LAST_SOURCE_CAMPAIGN_NAME varchar,
            LAST_SOURCE_TRAFFIC_ID varchar,
            LAST_SOURCE_TRAFFIC_NAME varchar,
            LAST_SOURCE_ADSET varchar,
            LAST_SOURCE_AD_NAME varchar,
            LAST_SOURCE_AD_ID varchar,

            MD5_HASH varchar,
            INSERT_DATE varchar,
            UPDATE_DATE varchar,

            SOURCE_FILE_NAME varchar,
            SOURCE_FILE_ROW_NUMBER number,
            SOURCE_FILE_LAST_MODIFIED timestamp_tz,
            LOAD_TIMESTAMP timestamp_tz default current_timestamp()
        )

    {% endset %}

    {% set create_inbound_table %}

        create table if not exists
            {{ target.database }}.BRONZE.MARKETING_INBOUND_CAMPAIGN_RAW (

            FIRST_SOURCE_CALENDLY_CAMPAIGN varchar,
            FIRST_SOURCE varchar,
            LAST_SOURCE_CALENDLY_CAMPAIGN varchar,
            LAST_SOURCE varchar,
            ACTIVITY_LOG_DATE varchar,
            STATUS varchar,
            TRIAGE_CALL_DATE varchar,
            TRIAGE_YEAR_WEEK varchar,
            SETTER_CLOSER_NAME varchar,
            LEAD_ID varchar,
            TAKEN_STATUS varchar,
            STRATEGY_CALL_STATUS varchar,
            STRATEGY_CALL_TAKEN_STATUS varchar,
            CLOSER_NAME varchar,
            SALE_STATUS varchar,
            CONTRACTED_VALUE varchar,

            SOURCE_FILE_NAME varchar,
            SOURCE_FILE_ROW_NUMBER number,
            SOURCE_FILE_LAST_MODIFIED timestamp_tz,
            LOAD_TIMESTAMP timestamp_tz default current_timestamp()
        )

    {% endset %}

    {% if execute %}

        {% do log('Creating Bronze tables...', info=true) %}

        {% do run_query(create_ad_table) %}
        {% do run_query(create_leads_table) %}
        {% do run_query(create_inbound_table) %}

        {% do log('Bronze tables created successfully.', info=true) %}

    {% endif %}

{% endmacro %}