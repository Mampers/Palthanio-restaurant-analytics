/*
Bronze RAW: fact_promo_performance_raw
Purpose: Persisted bronze table with lineage + load timestamp.
Loads data from bronze.fact_promo_performance_stage.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.fact_promo_performance_raw;
GO

CREATE TABLE bronze.fact_promo_performance_raw (
    PromoDate       VARCHAR(50)  NULL,
    StoreCode       VARCHAR(50)  NULL,
    StoreName       VARCHAR(255) NULL,
    ProductCode     VARCHAR(50)  NULL,
    ProductName     VARCHAR(255) NULL,
    PromoType       VARCHAR(100) NULL,
    UnitsSold       VARCHAR(50)  NULL,
    Revenue         VARCHAR(50)  NULL,
    DiscountAmount  VARCHAR(50)  NULL,
    SourceSystem    VARCHAR(50)  NULL,
    SourceFile      VARCHAR(260) NULL,
    LoadDts         DATETIME2(0) NOT NULL
);
GO

ALTER TABLE bronze.fact_promo_performance_raw
ADD CONSTRAINT DF_fact_promo_performance_raw_LoadDts
DEFAULT (SYSDATETIME()) FOR LoadDts;
GO

-- Insert STAGE -> RAW (minimal trimming only)
INSERT INTO bronze.fact_promo_performance_raw (
    PromoDate,
    StoreCode,
    StoreName,
    ProductCode,
    ProductName,
    PromoType,
    UnitsSold,
    Revenue,
    DiscountAmount,
    SourceSystem,
    SourceFile
)
SELECT
    LTRIM(RTRIM(PromoDate)),
    LTRIM(RTRIM(StoreCode)),
    LTRIM(RTRIM(StoreName)),
    LTRIM(RTRIM(ProductCode)),
    LTRIM(RTRIM(ProductName)),
    LTRIM(RTRIM(PromoType)),
    LTRIM(RTRIM(UnitsSold)),
    LTRIM(RTRIM(Revenue)),
    LTRIM(RTRIM(DiscountAmount)),
    'marketing',
    'fact_promo_performance.csv'
FROM bronze.fact_promo_performance_stage;
GO

