/* ============================================================
   BRONZE -> SILVER : fact_promo_performance
   Source : bronze.fact_promo_performance_raw
   Target : silver.fact_promo_performance

   Cleans:
   - trims text
   - converts PromoDate to date (supports dd/MM/yyyy + yyyy-MM-dd)
   - converts UnitsSold to int
   - converts Revenue / DiscountAmount to decimal(12,2)

   Adds:
   - PromoDateKey (YYYYMMDD int)
   - NetRevenueAfterDiscount = Revenue - DiscountAmount
   - DiscountPct = DiscountAmount / Revenue (NULL if Revenue = 0/NULL)
   ============================================================ */

SET NOCOUNT ON;

------------------------------------------------------------
-- 0) Ensure schema exists
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver;');

------------------------------------------------------------
-- 1) Drop + recreate (safe for reruns)
------------------------------------------------------------
IF OBJECT_ID('silver.fact_promo_performance', 'U') IS NOT NULL
    DROP TABLE silver.fact_promo_performance;

CREATE TABLE silver.fact_promo_performance
(
    PromoDate              date          NOT NULL,
    PromoDateKey           int           NOT NULL,   -- YYYYMMDD

    StoreCode              varchar(50)   NULL,
    StoreName              varchar(255)  NULL,
    ProductCode            varchar(50)   NULL,
    ProductName            varchar(255)  NULL,

    PromoType              varchar(100)  NULL,

    UnitsSold              int           NULL,
    Revenue                decimal(12,2) NULL,
    DiscountAmount         decimal(12,2) NULL,

    NetRevenueAfterDiscount decimal(12,2) NULL,
    DiscountPct            decimal(12,6) NULL
);

------------------------------------------------------------
-- 2) Insert cleaned + derived fields
------------------------------------------------------------
;WITH src AS
(
    SELECT
        -- PromoDate: try dd/MM/yyyy (103) then ISO-ish (23 / default)
        COALESCE(
            TRY_CONVERT(date, LTRIM(RTRIM(b.PromoDate)), 103),
            TRY_CONVERT(date, LTRIM(RTRIM(b.PromoDate)), 23),
            TRY_CONVERT(date, LTRIM(RTRIM(b.PromoDate)))
        ) AS PromoDate,

        NULLIF(LTRIM(RTRIM(b.StoreCode)), '')    AS StoreCode,
        NULLIF(LTRIM(RTRIM(b.StoreName)), '')    AS StoreName,
        NULLIF(LTRIM(RTRIM(b.ProductCode)), '')  AS ProductCode,
        NULLIF(LTRIM(RTRIM(b.ProductName)), '')  AS ProductName,
        NULLIF(LTRIM(RTRIM(b.PromoType)), '')    AS PromoType,

        TRY_CONVERT(int, NULLIF(LTRIM(RTRIM(b.UnitsSold)), '')) AS UnitsSold,

        TRY_CONVERT(decimal(12,2),
            NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(b.Revenue)), ',', ''), '£', ''), '')
        ) AS Revenue,

        TRY_CONVERT(decimal(12,2),
            NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(b.DiscountAmount)), ',', ''), '£', ''), '')
        ) AS DiscountAmount
    FROM bronze.fact_promo_performance_raw b
)
INSERT INTO silver.fact_promo_performance
(
    PromoDate, PromoDateKey,
    StoreCode, StoreName, ProductCode, ProductName,
    PromoType,
    UnitsSold, Revenue, DiscountAmount,
    NetRevenueAfterDiscount, DiscountPct
)
SELECT
    s.PromoDate,
    CONVERT(int, FORMAT(s.PromoDate, 'yyyyMMdd')) AS PromoDateKey,

    s.StoreCode, s.StoreName, s.ProductCode, s.ProductName,
    s.PromoType,

    s.UnitsSold,
    s.Revenue,
    s.DiscountAmount,

    CASE
        WHEN s.Revenue IS NULL THEN NULL
        ELSE s.Revenue - ISNULL(s.DiscountAmount, 0)
    END AS NetRevenueAfterDiscount,

    CASE
        WHEN s.Revenue IS NULL OR s.Revenue = 0 OR s.DiscountAmount IS NULL THEN NULL
        ELSE CAST(s.DiscountAmount / s.Revenue AS decimal(12,6))
    END AS DiscountPct
FROM src s
WHERE s.PromoDate IS NOT NULL;

------------------------------------------------------------
-- 3) Optional: indexes (helpful for joins/filters)
------------------------------------------------------------
CREATE INDEX IX_silver_fact_promo_perf_DateStoreProduct
ON silver.fact_promo_performance(PromoDateKey, StoreCode, ProductCode);

------------------------------------------------------------
-- 4) Spot check
------------------------------------------------------------
-- SELECT TOP (50) *
-- FROM silver.fact_promo_performance
-- ORDER BY PromoDate, StoreCode, ProductCode;

