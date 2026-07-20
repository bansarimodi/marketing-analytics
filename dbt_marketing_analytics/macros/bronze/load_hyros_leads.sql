{% macro load_hyros_leads() %}

    {% set copy_sql %}

        copy into
            {{ target.database }}.BRONZE.HYROS_LEADS_RAW

        from (
            select
                $1,  $2,  $3,  $4,  $5,
                $6,  $7,  $8,  $9,  $10,
                $11, $12, $13, $14, $15,
                $16, $17, $18, $19, $20,
                $21, $22, $23, $24, $25,
                $26, $27,

                metadata$filename,
                metadata$file_row_number,
                metadata$file_last_modified,
                current_timestamp()

            from
                @{{ target.database }}.BRONZE.STG_HYROS_LEADS
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

        {% do log('Loading HYROS_LEADS...', info=true) %}

        {% set result = run_query(copy_sql) %}

        {% do log('HYROS_LEADS load completed.', info=true) %}

    {% endif %}

{% endmacro %}