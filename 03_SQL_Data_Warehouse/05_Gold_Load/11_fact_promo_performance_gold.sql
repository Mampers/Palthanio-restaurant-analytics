/* ============================================================
   SILVER -> GOLD : fact_promo_performance
   Source : silver.fact_promo_performance
   Target : gold.fact_promo_performance

   Grain:
   - PromoDate x StoreName x ProductName x PromoType

   Adds:
   - PromoDateKey (YYYYMMDD int for joining to gold.01_dim_date)
   - NetRevenueAfterDiscount (Revenue - DiscountAmount)
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
IF OBJECT_ID('gold.fact_promo_performance','U') IS NOT NULL
    DROP TABLE gold.fact_promo_performance;
GO

CREATE TABLE gold.fact_promo_performance
(
    PromoDate              int            NOT NULL,  -- keep as in Silver (int)
    PromoDateKey           int            NOT NULL,  -- join key to gold.01_dim_date

    StoreName              varchar(50)    NULL,
    ProductName            varchar(50)    NULL,
    PromoType              varchar(20)    NULL,

    UnitsSold              int            NULL,
    Revenue                decimal(12,2)  NULL,
    DiscountAmount         decimal(12,2)  NULL,

    RevenuePerUnit         decimal(12,2)  NULL,
    DiscountPerUnit        decimal(12,2)  NULL,

    NetRevenueAfterDiscount decimal(12,2) NULL,
    IsDiscounted           bit            NULL
);
GO

------------------------------------------------------------
-- 2) Insert from Silver + derived fields
------------------------------------------------------------
INSERT INTO gold.fact_promo_performance
(
    PromoDate,
    PromoDateKey,
    StoreName,
    ProductName,
    PromoType,
    UnitsSold,
    Revenue,
    DiscountAmount,
    RevenuePerUnit,
    DiscountPerUnit,
    NetRevenueAfterDiscount,
    IsDiscounted
)
SELECT
    s.PromoDate,
    -- If PromoDate already equals DateKey format (YYYYMMDD), keep it:
    s.PromoDate AS PromoDateKey,

    s.StoreName,
    s.ProductName,
    s.PromoType,
    s.UnitsSold,
    s.Revenue,
    s.DiscountAmount,
    s.RevenuePerUnit,
    s.DiscountPerUnit,

    CASE
        WHEN s.Revenue IS NULL THEN NULL
        ELSE s.Revenue - ISNULL(s.DiscountAmount, 0)
    END AS NetRevenueAfterDiscount,

    s.IsDiscounted
FROM silver.fact_promo_performance s;
GO

------------------------------------------------------------
-- 3) Helpful indexes
------------------------------------------------------------
CREATE INDEX IX_gold_fact_promo_perf_Date
ON gold.fact_promo_performance(PromoDateKey);

CREATE INDEX IX_gold_fact_promo_perf_StoreProduct
ON gold.fact_promo_performance(StoreName, ProductName);
GO

-- Optional spot check
-- SELECT TOP (50) * FROM gold.fact_promo_performance ORDER BY PromoDateKey DESC;

