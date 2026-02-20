/* ============================================================
   GOLD (DERIVED) : fact_product_profitability
   Source : gold.07_fact_sales
   Target : gold.fact_product_profitability

   Grain:
   - 1 row per ProductCode

   Measures:
   - UnitsSold
   - Revenue (NetRevenue)
   - COGS
   - Profit
   - ProfitMarginPct = Profit / Revenue
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
IF OBJECT_ID('gold.fact_product_profitability','U') IS NOT NULL
    DROP TABLE gold.fact_product_profitability;
GO

CREATE TABLE gold.fact_product_profitability
(
    ProductCode      varchar(50)    NOT NULL,
    UnitsSold        int            NULL,
    Revenue          decimal(38,2)  NULL,
    COGS             decimal(38,2)  NULL,
    Profit           decimal(38,2)  NULL,
    ProfitMarginPct  numeric(38,6)  NULL
);
GO

------------------------------------------------------------
-- 2) Aggregate from atomic sales
------------------------------------------------------------
;WITH agg AS
(
    SELECT
        fs.ProductCode,
        SUM(ISNULL(fs.Quantity, 0))      AS UnitsSold,
        SUM(ISNULL(fs.NetRevenue, 0))    AS Revenue,
        SUM(ISNULL(fs.COGS, 0))          AS COGS,
        SUM(ISNULL(fs.GrossProfit, 0))   AS Profit
    FROM gold.07_fact_sales fs
    GROUP BY fs.ProductCode
)
INSERT INTO gold.fact_product_profitability
(
    ProductCode,
    UnitsSold,
    Revenue,
    COGS,
    Profit,
    ProfitMarginPct
)
SELECT
    a.ProductCode,
    a.UnitsSold,
    CAST(a.Revenue AS decimal(38,2)) AS Revenue,
    CAST(a.COGS    AS decimal(38,2)) AS COGS,
    CAST(a.Profit  AS decimal(38,2)) AS Profit,

    CASE
        WHEN a.Revenue IS NULL OR a.Revenue = 0 THEN NULL
        ELSE CAST(a.Profit / NULLIF(a.Revenue, 0) AS numeric(38,6))
    END AS ProfitMarginPct
FROM agg a;
GO

------------------------------------------------------------
-- 3) Helpful index
------------------------------------------------------------
CREATE INDEX IX_gold_fact_product_profitability_Product
ON gold.fact_product_profitability(ProductCode);
GO

-- Optional spot check
-- SELECT TOP (50) * FROM gold.fact_product_profitability ORDER BY Profit DESC;

