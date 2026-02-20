/* ============================================================
   SILVER -> GOLD : 07_fact_sales
   Source : silver.fact_sales
   Target : gold.07_fact_sales

   Grain:
   - 1 row per SalesLineID (atomic sales line)

   Notes:
   - Uses gold.05_dim_channel where ChannelCode = UPPER(Channel)
   - Keeps financial fields as already typed in Silver
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
IF OBJECT_ID('gold.07_fact_sales','U') IS NOT NULL
    DROP TABLE gold.07_fact_sales;
GO

CREATE TABLE gold.07_fact_sales
(
    SalesLineID      varchar(50)  NOT NULL,
    TransactionRef   varchar(20)  NOT NULL,

    DateKey          int          NOT NULL,
    StoreCode        varchar(50)  NOT NULL,
    ProductCode      varchar(50)  NOT NULL,
    PromotionCode    varchar(50)  NOT NULL,

    ChannelCode      nvarchar(100) NULL,     -- aligns to gold.05_dim_channel.ChannelCode
    PaymentMethod    varchar(50)  NULL,
    DayPart          varchar(50)  NULL,
    TransactionTime  time(0)      NULL,

    Quantity         int          NULL,
    GrossRevenue     decimal(12,2) NULL,
    DiscountAmount   decimal(12,2) NULL,
    NetRevenue       decimal(12,2) NULL,
    COGS             decimal(12,2) NULL,
    GrossProfit      decimal(12,2) NULL,
    GrossMargin      decimal(12,2) NULL,
    GrossMarginPct   decimal(10,4) NULL,

    -- Helpful Gold flags
    IsDiscounted     bit          NOT NULL,
    HasPromotion     bit          NOT NULL,

    CONSTRAINT PK_gold_07_fact_sales PRIMARY KEY CLUSTERED (SalesLineID)
);
GO

------------------------------------------------------------
-- 2) Insert from Silver (light standardisation only)
------------------------------------------------------------
INSERT INTO gold.07_fact_sales
(
    SalesLineID,
    TransactionRef,
    DateKey,
    StoreCode,
    ProductCode,
    PromotionCode,
    ChannelCode,
    PaymentMethod,
    DayPart,
    TransactionTime,
    Quantity,
    GrossRevenue,
    DiscountAmount,
    NetRevenue,
    COGS,
    GrossProfit,
    GrossMargin,
    GrossMarginPct,
    IsDiscounted,
    HasPromotion
)
SELECT
    s.SalesLineID,
    s.TransactionRef,
    s.DateKey,
    s.StoreCode,
    s.ProductCode,
    s.PromotionCode,

    -- Align to dim_channel key style (ChannelCode is UPPER in your dim)
    CASE
        WHEN s.Channel IS NULL OR LTRIM(RTRIM(s.Channel)) = '' THEN NULL
        ELSE UPPER(LTRIM(RTRIM(s.Channel)))
    END AS ChannelCode,

    s.PaymentMethod,
    s.DayPart,
    s.TransactionTime,
    s.Quantity,
    s.GrossRevenue,
    s.DiscountAmount,
    s.NetRevenue,
    s.COGS,
    s.GrossProfit,
    s.GrossMargin,
    s.GrossMarginPct,

    CAST(CASE WHEN ISNULL(s.DiscountAmount, 0) > 0 THEN 1 ELSE 0 END AS bit) AS IsDiscounted,

    CAST(CASE
        WHEN s.PromotionCode IS NULL THEN 0
        WHEN LTRIM(RTRIM(s.PromotionCode)) = '' THEN 0
        WHEN UPPER(LTRIM(RTRIM(s.PromotionCode))) IN ('NONE','NO_PROMO','NOPROMO','NA','N/A') THEN 0
        ELSE 1
    END AS bit) AS HasPromotion

FROM silver.fact_sales s;
GO

------------------------------------------------------------
-- 3) Indexes for Power BI performance
------------------------------------------------------------
CREATE INDEX IX_gold_07_fact_sales_DateStore
ON gold.07_fact_sales(DateKey, StoreCode);

CREATE INDEX IX_gold_07_fact_sales_Product
ON gold.07_fact_sales(ProductCode);

CREATE INDEX IX_gold_07_fact_sales_Channel
ON gold.07_fact_sales(ChannelCode);
GO

-- Spot check (optional)
-- SELECT TOP (50) * FROM gold.07_fact_sales ORDER BY DateKey, StoreCode;

