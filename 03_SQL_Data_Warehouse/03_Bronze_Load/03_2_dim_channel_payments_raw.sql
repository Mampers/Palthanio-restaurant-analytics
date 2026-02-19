/*
Bronze RAW: dim_channel_paymentmethod_raw
Purpose: Persisted bronze table with lineage + load timestamp.
Loads data from bronze.dim_channel_paymentmethod_stage.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.dim_channel_paymentmethod_raw;
GO

CREATE TABLE bronze.dim_channel_paymentmethod_raw (
    Channel        VARCHAR(100) NULL,
    PaymentMethod  VARCHAR(100) NULL,
    SourceSystem   VARCHAR(50)  NULL,
    SourceFile     VARCHAR(260) NULL,
    LoadDts        DATETIME2(0) NOT NULL
);
GO

ALTER TABLE bronze.dim_channel_paymentmethod_raw
ADD CONSTRAINT DF_bronze_dim_channel_paymentmethod_raw_LoadDts
DEFAULT (SYSDATETIME()) FOR LoadDts;
GO

-- Insert STAGE -> RAW (minimal transformation only)
INSERT INTO bronze.dim_channel_paymentmethod_raw (
    Channel,
    PaymentMethod,
    SourceSystem,
    SourceFile
)
SELECT
    LTRIM(RTRIM(Channel))       AS Channel,
    LTRIM(RTRIM(PaymentMethod)) AS PaymentMethod,
    'pos'                       AS SourceSystem,
    'dim_channel_paymentmethod.csv' AS SourceFile
FROM bronze.dim_channel_paymentmethod_stage;
GO

