/*
Bronze RAW: fact_orders_2025_raw
Purpose: Persisted bronze table with load timestamp.
Loads data from bronze.fact_orders_2025_stage.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.fact_orders_2025_raw;
GO

CREATE TABLE bronze.fact_orders_2025_raw (
    OrderID         NVARCHAR(50)  NULL,
    DateKey         NVARCHAR(20)  NULL,
    StoreKey        NVARCHAR(50)  NULL,
    ChannelKey      NVARCHAR(100) NULL,
    OrderRevenueNet NVARCHAR(50)  NULL,
    DiscountAmount  NVARCHAR(50)  NULL,
    SourceSystem    NVARCHAR(50)  NULL,
    SourceFile      NVARCHAR(260) NULL,
    LoadDts         DATETIME2(0)  NOT NULL
);
GO

ALTER TABLE bronze.fact_orders_2025_raw
ADD CONSTRAINT DF_bronze_fact_orders_2025_raw_LoadDts
DEFAULT (SYSUTCDATETIME()) FOR LoadDts;
GO

-- Insert STAGE -> RAW (minimal trimming only)
INSERT INTO bronze.fact_orders_2025_raw (
    OrderID,
    DateKey,
    StoreKey,
    ChannelKey,
    OrderRevenueNet,
    DiscountAmount,
    SourceSystem,
    SourceFile
)
SELECT
    LTRIM(RTRIM(OrderID)),
    LTRIM(RTRIM(DateKey)),
    LTRIM(RTRIM(StoreKey)),
    LTRIM(RTRIM(ChannelKey)),
    LTRIM(RTRIM(OrderRevenueNet)),
    LTRIM(RTRIM(DiscountAmount)),
    'pos',
    'fact_orders_2025.csv'
FROM bronze.fact_orders_2025_stage;
GO

