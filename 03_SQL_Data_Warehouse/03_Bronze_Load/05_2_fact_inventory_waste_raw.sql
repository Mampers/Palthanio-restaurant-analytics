
/*
Bronze RAW: fact_inventory_waste_raw
Purpose: Persisted bronze table with lineage + load timestamp.
Loads data from bronze.fact_inventory_waste_stage.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.fact_inventory_waste_raw;
GO

CREATE TABLE bronze.fact_inventory_waste_raw (
    WasteID            VARCHAR(50) NULL,
    DateKey            VARCHAR(50) NULL,
    StoreKey           VARCHAR(50) NULL,
    NewStoreKey        VARCHAR(50) NULL,
    ProductKey         VARCHAR(50) NULL,
    NewProductKey      VARCHAR(50) NULL,
    WasteQuantity      VARCHAR(50) NULL,
    WasteCost          VARCHAR(50) NULL,
    WasteReason        VARCHAR(200) NULL,
    Unused1            VARCHAR(50) NULL,
    Unused2            VARCHAR(50) NULL,
    Unused3            VARCHAR(50) NULL,
    Unused4            VARCHAR(50) NULL,
    Unused5            VARCHAR(50) NULL,
    Unused6            VARCHAR(50) NULL,
    ExtraStoreKey      VARCHAR(50) NULL,
    ExtraNewStoreKey   VARCHAR(50) NULL,
    SourceSystem       VARCHAR(50)  NULL,
    SourceFile         VARCHAR(260) NULL,
    LoadDts            DATETIME2(0) NOT NULL
);
GO

ALTER TABLE bronze.fact_inventory_waste_raw
ADD CONSTRAINT DF_fact_inventory_waste_raw_LoadDts
DEFAULT (SYSDATETIME()) FOR LoadDts;
GO

-- Insert STAGE -> RAW (minimal trimming only)
INSERT INTO bronze.fact_inventory_waste_raw (
    WasteID,
    DateKey,
    StoreKey,
    NewStoreKey,
    ProductKey,
    NewProductKey,
    WasteQuantity,
    WasteCost,
    WasteReason,
    Unused1,
    Unused2,
    Unused3,
    Unused4,
    Unused5,
    Unused6,
    ExtraStoreKey,
    ExtraNewStoreKey,
    SourceSystem,
    SourceFile
)
SELECT
    LTRIM(RTRIM(WasteID)),
    LTRIM(RTRIM(DateKey)),
    LTRIM(RTRIM(StoreKey)),
    LTRIM(RTRIM(NewStoreKey)),
    LTRIM(RTRIM(ProductKey)),
    LTRIM(RTRIM(NewProductKey)),
    LTRIM(RTRIM(WasteQuantity)),
    LTRIM(RTRIM(WasteCost)),
    LTRIM(RTRIM(WasteReason)),
    LTRIM(RTRIM(Unused1)),
    LTRIM(RTRIM(Unused2)),
    LTRIM(RTRIM(Unused3)),
    LTRIM(RTRIM(Unused4)),
    LTRIM(RTRIM(Unused5)),
    LTRIM(RTRIM(Unused6)),
    LTRIM(RTRIM(ExtraStoreKey)),
    LTRIM(RTRIM(ExtraNewStoreKey)),
    'ops',
    'fact_inventory_waste.csv'
FROM bronze.fact_inventory_waste_stage;
GO
