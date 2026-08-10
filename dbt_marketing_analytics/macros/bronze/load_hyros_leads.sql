{% macro load_hyros_leads() %}

    {% set copy_sql %}

        COPY INTO
            {{ target.database }}.BRONZE.HYROS_LEADS_RAW

        FROM
        (
            SELECT
                $1,
                $2,
                $3,
                $4,
                $5,
                $6,
                $7,
                $8,
                $9,
                $10,
                $11,
                $12,
                $13,
                $14,
                $15,
                $16,
                $17,
                $18,
                $19,
                $20,
                $21,
                $22,
                $23,
                $24,
                $25,
                $26,
                $27,

                METADATA$FILENAME,
                METADATA$FILE_ROW_NUMBER,
                METADATA$FILE_LAST_MODIFIED,
                CURRENT_TIMESTAMP()

            FROM
                @{{ target.database }}.BRONZE.MARKETING_S3_STAGE
        )

        PATTERN = '.*[/]hyros_leads[.]csv'

        FILE_FORMAT =
        (
            FORMAT_NAME =
                '{{ target.database }}.BRONZE.MARKETING_CSV_FORMAT'
        )

        ON_ERROR = 'ABORT_STATEMENT'
        FORCE = FALSE

    {% endset %}


    {% if execute %}

        {{ log("Loading new HYROS_LEADS files...", info=True) }}

        {% set copy_result = run_query(copy_sql) %}

        {% if copy_result is not none %}

            {% for row in copy_result.rows %}

                {{ log(
                    "HYROS_LEADS | File: " ~ row[0]
                    ~ " | Status: " ~ row[1]
                    ~ " | Rows loaded: " ~ row[3],
                    info=True
                ) }}

            {% endfor %}

        {% endif %}

        {{ log("HYROS_LEADS load completed.", info=True) }}

    {% endif %}

{% endmacro %}