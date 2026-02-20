/* ============================================================
   GOLD (DERIVED) : fact_channel_performance
   Source : gold.07_fact_sales (atomic)
   Target : gold.fact_channel_performance

   Grain:
   - Channel x PaymentMethod (aggregated)

   Measures:
   - UnitsSold
   - Revenue (NetRevenue)
   - Profit (GrossProfit)
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
IF OBJECT_ID('gold.fact_channel_performance','U') IS NOT NULL
    DROP TABLE gold.fact_channel_performance;
GO

CREATE TABLE gold.fact_channel_performance
(
    Channel          varchar(50)      NULL,
    PaymentMethod    varchar(50)      NULL,
    UnitsSold        int              NULL,
    Revenue          decimal(38,2)    NULL,
    Profit           decimal(38,2)    NULL,
    ProfitMarginPct  numeric(38,6)    NULL
);
GO

------------------------------------------------------------
-- 2) Build aggregates from atomic sales
------------------------------------------------------------
;WITH agg AS
(
    SELECT
        -- Use dim_channel if available, else fall back to the code/text
        COALESCE(dc.ChannelName, fs.ChannelCode) AS Channel,
        fs.PaymentMethod,

        SUM(ISNULL(fs.Quantity, 0))                         AS UnitsSold,
        SUM(ISNULL(fs.NetRevenue, 0))                       AS Revenue,
        SUM(ISNULL(fs.GrossProfit, 0))                      AS Profit
    FROM gold.07_fact_sales fs
    LEFT JOIN gold.05_dim_channel dc
        ON dc.ChannelCode = fs.ChannelCode
    GROUP BY
        COALESCE(dc.ChannelName, fs.ChannelCode),
        fs.PaymentMethod
)
INSERT INTO gold.fact_channel_performance
(
    Channel,
    PaymentMethod,
    UnitsSold,
    Revenue,
    Profit,
    ProfitMarginPct
)
SELECT
    a.Channel,
    a.PaymentMethod,
    a.UnitsSold,
    a.Revenue,
    a.Profit,

    CASE
        WHEN a.Revenue IS NULL OR a.Revenue = 0 THEN NULL
        ELSE CAST(a.Profit / NULLIF(a.Revenue, 0) AS numeric(38,6))
    END AS ProfitMarginPct
FROM agg a;
GO

------------------------------------------------------------
-- 3) Helpful indexes
------------------------------------------------------------
CREATE INDEX IX_gold_fact_channel_perf_Channel
ON gold.fact_channel_performance(Channel);

CREATE INDEX IX_gold_fact_channel_perf_PaymentMethod
ON gold.fact_channel_performance(PaymentMethod);
GO

-- Spot check (optional)
-- SELECT * FROM gold.fact_channel_performance ORDER BY Revenue DESC;

