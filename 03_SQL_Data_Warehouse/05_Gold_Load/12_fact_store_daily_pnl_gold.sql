/* ============================================================
   GOLD (DERIVED) : fact_store_daily_pnl
   Source : gold.07_fact_sales
   Target : gold.fact_store_daily_pnl

   Grain:
   - DateKey x StoreKey (daily per store)

   Measures:
   - UnitsSold (sum quantity)
   - GrossRevenue, DiscountAmount, NetRevenue, COGS
   - GrossProfit
   - GrossMarginPct = GrossProfit / NetRevenue (NULL if NetRevenue=0)
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
IF OBJECT_ID('gold.fact_store_daily_pnl','U') IS NOT NULL
    DROP TABLE gold.fact_store_daily_pnl;
GO

CREATE TABLE gold.fact_store_daily_pnl
(
    DateKey          int            NOT NULL,
    StoreKey         varchar(50)    NOT NULL,

    UnitsSold        int            NULL,
    GrossRevenue     decimal(38,2)  NULL,
    DiscountAmount   decimal(38,2)  NULL,
    NetRevenue       decimal(38,2)  NULL,
    COGS             decimal(38,2)  NULL,
    GrossProfit      decimal(38,2)  NULL,
    GrossMarginPct   numeric(38,6)  NULL
);
GO

------------------------------------------------------------
-- 2) Build aggregates from atomic sales
------------------------------------------------------------
;WITH agg AS
(
    SELECT
        fs.DateKey,
        fs.StoreCode AS StoreKey,

        SUM(ISNULL(fs.Quantity, 0))          AS UnitsSold,

        SUM(ISNULL(fs.GrossRevenue, 0))      AS GrossRevenue,
        SUM(ISNULL(fs.DiscountAmount, 0))    AS DiscountAmount,
        SUM(ISNULL(fs.NetRevenue, 0))        AS NetRevenue,
        SUM(ISNULL(fs.COGS, 0))              AS COGS,
        SUM(ISNULL(fs.GrossProfit, 0))       AS GrossProfit
    FROM gold.07_fact_sales fs
    GROUP BY
        fs.DateKey,
        fs.StoreCode
)
INSERT INTO gold.fact_store_daily_pnl
(
    DateKey,
    StoreKey,
    UnitsSold,
    GrossRevenue,
    DiscountAmount,
    NetRevenue,
    COGS,
    GrossProfit,
    GrossMarginPct
)
SELECT
    a.DateKey,
    a.StoreKey,
    a.UnitsSold,
    CAST(a.GrossRevenue   AS decimal(38,2)) AS GrossRevenue,
    CAST(a.DiscountAmount AS decimal(38,2)) AS DiscountAmount,
    CAST(a.NetRevenue     AS decimal(38,2)) AS NetRevenue,
    CAST(a.COGS           AS decimal(38,2)) AS COGS,
    CAST(a.GrossProfit    AS decimal(38,2)) AS GrossProfit,

    CASE
        WHEN a.NetRevenue IS NULL OR a.NetRevenue = 0 THEN NULL
        ELSE CAST(a.GrossProfit / NULLIF(a.NetRevenue, 0) AS numeric(38,6))
    END AS GrossMarginPct
FROM agg a;
GO

------------------------------------------------------------
-- 3) Helpful indexes
------------------------------------------------------------
CREATE INDEX IX_gold_fact_store_daily_pnl_DateStore
ON gold.fact_store_daily_pnl(DateKey, StoreKey);
GO

-- Optional spot check
-- SELECT TOP (50) * FROM gold.fact_store_daily_pnl ORDER BY DateKey DESC, StoreKey;



