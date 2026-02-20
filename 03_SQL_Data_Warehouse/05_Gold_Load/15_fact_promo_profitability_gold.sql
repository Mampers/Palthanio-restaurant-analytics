/* ============================================================
   GOLD (DERIVED) : fact_promo_profitability
   Source : gold.07_fact_sales
   Target : gold.fact_promo_profitability

   Grain:
   - 1 row per PromotionKey

   Measures:
   - UnitsSold
   - DiscountGiven (total discount amount)
   - Revenue (NetRevenue)
   - Profit (GrossProfit)
   - ProfitPerDiscountPound = Profit / DiscountGiven
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
IF OBJECT_ID('gold.fact_promo_profitability','U') IS NOT NULL
    DROP TABLE gold.fact_promo_profitability;
GO

CREATE TABLE gold.fact_promo_profitability
(
    PromotionKey             varchar(50)   NOT NULL,
    UnitsSold                int           NULL,
    DiscountGiven            decimal(38,2) NULL,
    Revenue                  decimal(38,2) NULL,
    Profit                   decimal(38,2) NULL,
    ProfitPerDiscountPound   numeric(38,6) NULL
);
GO

------------------------------------------------------------
-- 2) Aggregate from atomic sales
------------------------------------------------------------
;WITH agg AS
(
    SELECT
        fs.PromotionCode AS PromotionKey,

        SUM(ISNULL(fs.Quantity, 0))        AS UnitsSold,
        SUM(ISNULL(fs.DiscountAmount, 0))  AS DiscountGiven,
        SUM(ISNULL(fs.NetRevenue, 0))      AS Revenue,
        SUM(ISNULL(fs.GrossProfit, 0))     AS Profit

    FROM gold.07_fact_sales fs
    WHERE fs.PromotionCode IS NOT NULL
      AND LTRIM(RTRIM(fs.PromotionCode)) <> ''
    GROUP BY fs.PromotionCode
)
INSERT INTO gold.fact_promo_profitability
(
    PromotionKey,
    UnitsSold,
    DiscountGiven,
    Revenue,
    Profit,
    ProfitPerDiscountPound
)
SELECT
    a.PromotionKey,
    a.UnitsSold,
    CAST(a.DiscountGiven AS decimal(38,2)) AS DiscountGiven,
    CAST(a.Revenue        AS decimal(38,2)) AS Revenue,
    CAST(a.Profit         AS decimal(38,2)) AS Profit,

    CASE
        WHEN a.DiscountGiven IS NULL OR a.DiscountGiven = 0 THEN NULL
        ELSE CAST(a.Profit / NULLIF(a.DiscountGiven, 0) AS numeric(38,6))
    END AS ProfitPerDiscountPound
FROM agg a;
GO

------------------------------------------------------------
-- 3) Helpful index
------------------------------------------------------------
CREATE INDEX IX_gold_fact_promo_profitability_Promo
ON gold.fact_promo_profitability(PromotionKey);
GO

-- Optional spot check
-- SELECT TOP (50) * FROM gold.fact_promo_profitability ORDER BY Profit DESC;

