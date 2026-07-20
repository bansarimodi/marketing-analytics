{% macro run_bronze_pipeline() %}

    {% do log('Starting Bronze pipeline...', info=true) %}

    {% do create_bronze_tables() %}
    {% do load_hyros_ad_attribution() %}
    {% do load_hyros_leads() %}
    {% do load_marketing_inbound_campaign() %}

    {% do log('Bronze pipeline completed successfully.', info=true) %}

{% endmacro %}