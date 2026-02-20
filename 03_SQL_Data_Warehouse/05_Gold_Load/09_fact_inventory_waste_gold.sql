/* ============================================================
   SILVER -> GOLD : fact_inventory_waste
   Source : silver.fact_inventory_waste
   Target : gold.fact_inventory_waste

   Grain:
   - 1 row per InventoryWasteID (waste event)

   Purpose:
   - Presentation-ready fact for waste KPIs
   - Clean join keys for Date/Store/Product
   ============================================================ */

SET NOCOUNT ON;

------------------------------------------------------------
-- 0) Ensure schema exists
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold;');
GO

------------------------------------------------------------
-- 1) Drop + recreate (safe for reruns)
------------------------------------------------------------
IF OBJECT_ID('gold.fact_inventory_waste','U') IS NOT NULL
    DROP TABLE gold.fact_inventory_waste;
GO

CREATE TABLE gold.fact_inventory_waste
(
    InventoryWasteID   varchar(20)    NOT NULL,
    DateKey            int            NOT NULL,
    StoreCode          varchar(10)    NULL,
    ProductCode        varchar(10)    NULL,

    WasteQuantity      int            NULL,
    WasteCost          decimal(12,2)  NULL,
    WasteReason        varchar(50)    NULL,
    WasteUnitCost      decimal(12,4)  NULL,
    WasteReasonGroup   varchar(30)    NULL,

    IsExpired          bit            NULL,
    IsDamaged          bit            NULL,
    IsPrepError        bit            NULL,
    IsSpillage         bit            NULL,
    IsOverproduction   bit            NULL,

    IsHighCostWaste    bit            NULL,
    IsHighQtyWaste     bit            NULL,

    -- Gold helper flags (optional but useful)
    IsKnownReason      bit            NOT NULL,
    IsOperationalWaste bit            NOT NULL,

    CONSTRAINT PK_gold_fact_inventory_waste
        PRIMARY KEY CLUSTERED (InventoryWasteID)
);
GO

------------------------------------------------------------
-- 2) Insert from Silver (minimal shaping)
------------------------------------------------------------
INSERT INTO gold.fact_inventory_waste
(
    InventoryWasteID,
    DateKey,
    StoreCode,
    ProductCode,
    WasteQuantity,
    WasteCost,
    WasteReason,
    WasteUnitCost,
    WasteReasonGroup,
    IsExpired,
    IsDamaged,
    IsPrepError,
    IsSpillage,
    IsOverproduction,
    IsHighCostWaste,
    IsHighQtyWaste,
    IsKnownReason,
    IsOperationalWaste
)
SELECT
    w.InventoryWasteID,
    w.DateKey,
    w.StoreCode,
    w.ProductCode,
    w.WasteQuantity,
    w.WasteCost,
    w.WasteReason,
    w.WasteUnitCost,
    w.WasteReasonGroup,
    w.IsExpired,
    w.IsDamaged,
    w.IsPrepError,
    w.IsSpillage,
    w.IsOverproduction,
    w.IsHighCostWaste,
    w.IsHighQtyWaste,

    -- Known reason flag
    CAST(
        CASE
            WHEN w.WasteReasonGroup IS NULL OR LTRIM(RTRIM(w.WasteReasonGroup)) = '' OR w.WasteReasonGroup = 'Unknown'
                THEN 0
            ELSE 1
        END AS bit
    ) AS IsKnownReason,

    -- Operational waste flag (excludes expired which is more stock mgmt)
    CAST(
        CASE
            WHEN w.IsPrepError = 1 OR w.IsSpillage = 1 OR w.IsOverproduction = 1 THEN 1
            ELSE 0
        END AS bit
    ) AS IsOperationalWaste

FROM silver.fact_inventory_waste w;
GO

------------------------------------------------------------
-- 3) Helpful indexes (Power BI performance)
------------------------------------------------------------
CREATE INDEX IX_gold_fact_inventory_waste_DateStore
ON gold.fact_inventory_waste(DateKey, StoreCode);

CREATE INDEX IX_gold_fact_inventory_waste_Product
ON gold.fact_inventory_waste(ProductCode);
GO

-- Optional spot check
-- SELECT TOP (50) * FROM gold.fact_inventory_waste ORDER BY DateKey DESC;

