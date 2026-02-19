/*
SILVER: fact_inventory_waste
- Cleans and types bronze.fact_inventory_waste_raw
- Adds KPI columns and standardised reason grouping
*/

USE [PalthanioRestaurants];
GO
SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver;');
GO

IF OBJECT_ID('silver.fact_inventory_waste', 'U') IS NOT NULL
    DROP TABLE silver.fact_inventory_waste;
GO

CREATE TABLE silver.fact_inventory_waste
(
    WasteID            varchar(50)    NOT NULL,
    DateKey            int            NOT NULL,
    StoreCode          varchar(10)    NULL,
    ProductCode        varchar(10)    NULL,

    WasteQuantity      int            NULL,
    WasteCost          decimal(12,2)  NULL,
    WasteReason        varchar(200)   NULL,

    WasteUnitCost      decimal(12,4)  NULL,
    WasteReasonGroup   varchar(30)    NULL,

    IsExpired          bit            NULL,
    IsDamaged          bit            NULL,
    IsPrepError        bit            NULL,
    IsSpillage         bit            NULL,
    IsOverproduction   bit            NULL,

    IsHighCostWaste    bit            NULL,
    IsHighQtyWaste     bit            NULL
);
GO

INSERT INTO silver.fact_inventory_waste
(
    WasteID, DateKey, StoreCode, ProductCode,
    WasteQuantity, WasteCost, WasteReason,
    WasteUnitCost, WasteReasonGroup,
    IsExpired, IsDamaged, IsPrepError, IsSpillage, IsOverproduction,
    IsHighCostWaste, IsHighQtyWaste
)
SELECT
    LTRIM(RTRIM(b.WasteID)) AS WasteID,
    TRY_CONVERT(int, b.DateKey) AS DateKey,
    NULLIF(LTRIM(RTRIM(b.NewStoreKey)), '') AS StoreCode,
    NULLIF(LTRIM(RTRIM(b.NewProductKey)), '') AS ProductCode,
    TRY_CONVERT(int, b.WasteQuantity) AS WasteQuantity,
    TRY_CONVERT(decimal(12,2), b.WasteCost) AS WasteCost,
    NULLIF(LTRIM(RTRIM(b.WasteReason)), '') AS WasteReason,

    CASE
        WHEN TRY_CONVERT(decimal(12,4), b.WasteCost) IS NULL
          OR TRY_CONVERT(decimal(12,4), b.WasteQuantity) IS NULL
          OR TRY_CONVERT(decimal(12,4), b.WasteQuantity) = 0
            THEN NULL
        ELSE CAST(TRY_CONVERT(decimal(12,4), b.WasteCost) / TRY_CONVERT(decimal(12,4), b.WasteQuantity) AS decimal(12,4))
    END AS WasteUnitCost,

    CASE
        WHEN UPPER(LTRIM(RTRIM(b.WasteReason))) IN ('EXPIRED') THEN 'Expired'
        WHEN UPPER(LTRIM(RTRIM(b.WasteReason))) IN ('DAMAGED') THEN 'Damaged'
        WHEN UPPER(LTRIM(RTRIM(b.WasteReason))) IN ('PREP ERROR','PREPERROR') THEN 'Prep Error'
        WHEN UPPER(LTRIM(RTRIM(b.WasteReason))) IN ('SPILLAGE','SPILL','SPILT') THEN 'Spillage'
        WHEN UPPER(LTRIM(RTRIM(b.WasteReason))) IN ('OVERPRODUCTION','OVER PRODUCTION') THEN 'Overproduction'
        WHEN b.WasteReason IS NULL OR LTRIM(RTRIM(b.WasteReason)) = '' THEN 'Unknown'
        ELSE 'Other'
    END AS WasteReasonGroup,

    CAST(CASE WHEN UPPER(LTRIM(RTRIM(b.WasteReason))) = 'EXPIRED' THEN 1 ELSE 0 END AS bit) AS IsExpired,
    CAST(CASE WHEN UPPER(LTRIM(RTRIM(b.WasteReason))) = 'DAMAGED' THEN 1 ELSE 0 END AS bit) AS IsDamaged,
    CAST(CASE WHEN UPPER(LTRIM(RTRIM(b.WasteReason))) IN ('PREP ERROR','PREPERROR') THEN 1 ELSE 0 END AS bit) AS IsPrepError,
    CAST(CASE WHEN UPPER(LTRIM(RTRIM(b.WasteReason))) IN ('SPILLAGE','SPILL','SPILT') THEN 1 ELSE 0 END AS bit) AS IsSpillage,
    CAST(CASE WHEN UPPER(LTRIM(RTRIM(b.WasteReason))) IN ('OVERPRODUCTION','OVER PRODUCTION') THEN 1 ELSE 0 END AS bit) AS IsOverproduction,

    CAST(CASE WHEN TRY_CONVERT(decimal(12,2), b.WasteCost) >= 5.00 THEN 1 ELSE 0 END AS bit) AS IsHighCostWaste,
    CAST(CASE WHEN TRY_CONVERT(int, b.WasteQuantity) >= 5 THEN 1 ELSE 0 END AS bit) AS IsHighQtyWaste
FROM bronze.fact_inventory_waste_raw b;
GO

