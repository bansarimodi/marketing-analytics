{% macro load_marketing_inbound_campaign() %}

    {% set copy_sql %}

        copy into
            {{ target.database }}.BRONZE.MARKETING_INBOUND_CAMPAIGN_RAW

        from (
            select
                $1,  $2,  $3,  $4,
                $5,  $6,  $7,  $8,
                $9,  $10, $11, $12,
                $13, $14, $15, $16,

                metadata$filename,
                metadata$file_row_number,
                metadata$file_last_modified,
                current_timestamp()

            from
                @{{ target.database }}.BRONZE.STG_MARKETING_INBOUND_CAMPAIGN
        )

        file_format = (
            type = csv
            field_delimiter = ','
            skip_header = 1
            field_optionally_enclosed_by = '"'
            empty_field_as_null = true
            null_if = ('', 'NULL', 'null')
            trim_space = true
            error_on_column_count_mismatch = true
            replace_invalid_characters = true
        )

        on_error = 'ABORT_STATEMENT'
        force = false

    {% endset %}

    {% if execute %}

        {% do log('Loading MARKETING_INBOUND_CAMPAIGN...', info=true) %}

        {% set result = run_query(copy_sql) %}

        {% do log(
            'MARKETING_INBOUND_CAMPAIGN load completed.',
            info=true
        ) %}

    {% endif %}

{% endmacro %}