CREATE OR REPLACE STORAGE INTEGRATION MARKETING_S3_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN =
        'arn:aws:iam::435627632439:role/snowflake-s3-read-role'
    STORAGE_ALLOWED_LOCATIONS = (
        's3://marketing-analytics-project-7days/marketing-data/'
    );

DESC INTEGRATION MARKETING_S3_INT;