USE ROLE ACCOUNTADMIN;
USE WAREHOUSE MARKETING_WH;
USE DATABASE MARKETING_ANALYTICS;
USE SCHEMA CONTROL;

CREATE OR REPLACE PROCEDURE SP_LOAD_BRONZE()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
BEGIN

    COPY INTO MARKETING_ANALYTICS.BRONZE.HYROS_AD_ATTRIBUTION_RAW
    FROM (
        SELECT
            $1, $2, $3, $4, $5, $6, $7,
            $8, $9, $10, $11, $12, $13, $14, $15, $16, $17,
            $18, $19, $20, $21, $22, $23, $24, $25, $26, $27,
            $28, $29, $30, $31, $32, $33, $34, $35, $36, $37,
            $38, $39, $40, $41, $42, $43, $44, $45, $46, $47,
            $48, $49, $50, $51, $52, $53, $54, $55, $56, $57,
            $58, $59, $60, $61, $62, $63, $64, $65, $66, $67,
            $68, $69, $70, $71, $72, $73, $74, $75, $76,

            METADATA$FILENAME,
            METADATA$FILE_ROW_NUMBER,
            METADATA$FILE_LAST_MODIFIED,
            CURRENT_TIMESTAMP()

        FROM @MARKETING_ANALYTICS.BRONZE.STG_HYROS_AD_ATTRIBUTION
    )
    ON_ERROR = 'ABORT_STATEMENT'
    FORCE = FALSE;


    COPY INTO MARKETING_ANALYTICS.BRONZE.HYROS_LEADS_RAW
    FROM (
        SELECT
            $1, $2, $3, $4, $5,
            $6, $7, $8, $9, $10,
            $11, $12, $13, $14, $15,
            $16, $17, $18, $19, $20,
            $21, $22, $23, $24, $25,
            $26, $27,

            METADATA$FILENAME,
            METADATA$FILE_ROW_NUMBER,
            METADATA$FILE_LAST_MODIFIED,
            CURRENT_TIMESTAMP()

        FROM @MARKETING_ANALYTICS.BRONZE.STG_HYROS_LEADS
    )
    ON_ERROR = 'ABORT_STATEMENT'
    FORCE = FALSE;


    COPY INTO MARKETING_ANALYTICS.BRONZE.MARKETING_INBOUND_CAMPAIGN_RAW
    FROM (
        SELECT
            $1, $2, $3, $4,
            $5, $6, $7, $8,
            $9, $10, $11, $12,
            $13, $14, $15, $16,

            METADATA$FILENAME,
            METADATA$FILE_ROW_NUMBER,
            METADATA$FILE_LAST_MODIFIED,
            CURRENT_TIMESTAMP()

        FROM @MARKETING_ANALYTICS.BRONZE.STG_MARKETING_INBOUND_CAMPAIGN
    )
    ON_ERROR = 'ABORT_STATEMENT'
    FORCE = FALSE;


    RETURN 'Bronze load completed successfully';

END;
$$;