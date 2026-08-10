{% macro load_hyros_ad_attribution() %}

    {% set copy_sql %}

        COPY INTO
            {{ target.database }}.BRONZE.HYROS_AD_ATTRIBUTION_RAW

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
                $28,
                $29,
                $30,
                $31,
                $32,
                $33,
                $34,
                $35,
                $36,
                $37,
                $38,
                $39,
                $40,
                $41,
                $42,
                $43,
                $44,
                $45,
                $46,
                $47,
                $48,
                $49,
                $50,
                $51,
                $52,
                $53,
                $54,
                $55,
                $56,
                $57,
                $58,
                $59,
                $60,
                $61,
                $62,
                $63,
                $64,
                $65,
                $66,
                $67,
                $68,
                $69,
                $70,
                $71,
                $72,
                $73,
                $74,
                $75,
                $76,

                METADATA$FILENAME,
                METADATA$FILE_ROW_NUMBER,
                METADATA$FILE_LAST_MODIFIED,
                CURRENT_TIMESTAMP()

            FROM
                @{{ target.database }}.BRONZE.MARKETING_S3_STAGE
        )

        PATTERN = '.*[/]hyros_ad_attribution[.]csv'

        FILE_FORMAT =
        (
            FORMAT_NAME =
                '{{ target.database }}.BRONZE.MARKETING_CSV_FORMAT'
        )

        ON_ERROR = 'ABORT_STATEMENT'
        FORCE = FALSE

    {% endset %}


    {% if execute %}

        {{ log("Loading new HYROS_AD_ATTRIBUTION files...", info=True) }}

        {% set copy_result = run_query(copy_sql) %}

        {% if copy_result is not none %}

            {% for row in copy_result.rows %}

                {{ log(
                    "HYROS_AD_ATTRIBUTION | File: " ~ row[0]
                    ~ " | Status: " ~ row[1]
                    ~ " | Rows loaded: " ~ row[3],
                    info=True
                ) }}

            {% endfor %}

        {% endif %}

        {{ log("HYROS_AD_ATTRIBUTION load completed.", info=True) }}

    {% endif %}

{% endmacro %}