/*
Bronze RAW: fact_sales_raw
Purpose: Persisted bronze table with lineage + load timestamp.
Loads data from bronze.fact_sales_stage.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.fact_sales_raw;
GO

CREATE TABLE bronze.fact_sales_raw (
    SalesLineID      VARCHAR(50) NULL,
    TransactionID    VARCHAR(50) NULL,
    DateKey          VARCHAR(50) NULL,
    StoreKey         VARCHAR(50) NULL,
    NewStoreKey      VARCHAR(50) NULL,
    ProductKey       VARCHAR(50) NULL,
    NewProductKey    VARCHAR(50) NULL,
    PromotionKey     VARCHAR(50) NULL,
    NewPromotionKey  VARCHAR(50) NULL,
    Channel          VARCHAR(50) NULL,
    PaymentMethod    VARCHAR(50) NULL,
    DayPart          VARCHAR(50) NULL,
    TransactionTime  VARCHAR(20) NULL,
    Quantity         VARCHAR(50) NULL,
    GrossRevenue     VARCHAR(50) NULL,
    DiscountAmount   VARCHAR(50) NULL,
    NetRevenue       VARCHAR(50) NULL,
    COGS             VARCHAR(50) NULL,
    SourceSystem     VARCHAR(50) NULL,
    SourceFile       VARCHAR(260) NULL,
    LoadDts          DATETIME2(0) NOT NULL
);
GO

ALTER TABLE bronze.fact_sales_raw
ADD CONSTRAINT DF_fact_sales_raw_LoadDts
DEFAULT (SYSDATETIME()) FOR LoadDts;
GO

-- Insert STAGE -> RAW (minimal trimming only)
INSERT INTO bronze.fact_sales_raw (
    SalesLineID,
    TransactionID,
    DateKey,
    StoreKey,
    NewStoreKey,
    ProductKey,
    NewProductKey,
    PromotionKey,
    NewPromotionKey,
    Channel,
    PaymentMethod,
    DayPart,
    TransactionTime,
    Quantity,
    GrossRevenue,
    DiscountAmount,
    NetRevenue,
    COGS,
    SourceSystem,
    SourceFile
)
SELECT
    LTRIM(RTRIM(SalesLineID)),
    LTRIM(RTRIM(TransactionID)),
    LTRIM(RTRIM(DateKey)),
    LTRIM(RTRIM(StoreKey)),
    LTRIM(RTRIM(NewStoreKey)),
    LTRIM(RTRIM(ProductKey)),
    LTRIM(RTRIM(NewProductKey)),
    LTRIM(RTRIM(PromotionKey)),
    LTRIM(RTRIM(NewPromotionKey)),
    LTRIM(RTRIM(Channel)),
    LTRIM(RTRIM(PaymentMethod)),
    LTRIM(RTRIM(DayPart)),
    LTRIM(RTRIM(TransactionTime)),
    LTRIM(RTRIM(Quantity)),
    LTRIM(RTRIM(GrossRevenue)),
    LTRIM(RTRIM(DiscountAmount)),
    LTRIM(RTRIM(NetRevenue)),
    LTRIM(RTRIM(COGS)),
    'pos',
    'fact_sales.csv'
FROM bronze.fact_sales_stage;
GO

