{% macro run_bronze_pipeline() %}

    {% if execute %}

        {{ log(
            "Starting Marketing Analytics Bronze pipeline...",
            info=True
        ) }}

        {% do create_bronze_tables() %}

        {% do load_hyros_ad_attribution() %}

        {% do load_hyros_leads() %}

        {% do load_marketing_inbound_campaign() %}

        {{ log(
            "Marketing Analytics Bronze pipeline completed.",
            info=True
        ) }}

    {% endif %}

{% endmacro %}