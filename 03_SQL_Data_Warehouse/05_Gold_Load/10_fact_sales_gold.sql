USE [PalthanioRestaurants];
GO
SET NOCOUNT ON;
GO

/* ============================================================
   SILVER -> GOLD : fact_sales
   Source : silver.fact_sales
   Target : gold.fact_sales
   ============================================================ */

------------------------------------------------------------
-- 0) Ensure schema exists
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold;');
GO

------------------------------------------------------------
-- 1) Drop + recreate (safe for reruns)
------------------------------------------------------------
IF OBJECT_ID('gold.fact_sales','U') IS NOT NULL
    DROP TABLE gold.fact_sales;
GO

CREATE TABLE gold.fact_sales
(
    SalesLineID      varchar(50)  NOT NULL,
    TransactionRef   varchar(20)  NOT NULL,

    DateKey          int          NOT NULL,

    StoreKey         nvarchar(50) NOT NULL,
    ProductKey       varchar(10)  NOT NULL,
    PromotionKey     varchar(20)  NOT NULL,

    ChannelCode      nvarchar(100) NULL,
    PaymentMethod    varchar(50)  NULL,
    DayPart          varchar(50)  NULL,
    TransactionTime  time(0)      NULL,

    Quantity         int           NULL,
    GrossRevenue     decimal(12,2) NULL,
    DiscountAmount   decimal(12,2) NULL,
    NetRevenue       decimal(12,2) NULL,
    COGS             decimal(12,2) NULL,
    GrossProfit      decimal(12,2) NULL,
    GrossMargin      decimal(12,2) NULL,
    GrossMarginPct   decimal(10,4) NULL,

    IsDiscounted     bit NOT NULL,
    HasPromotion     bit NOT NULL,

    CONSTRAINT PK_gold_fact_sales PRIMARY KEY CLUSTERED (SalesLineID)
);
GO

------------------------------------------------------------
-- 2) Load from Silver (with conformed keys)
------------------------------------------------------------
INSERT INTO gold.fact_sales
(
    SalesLineID,
    TransactionRef,
    DateKey,
    StoreKey,
    ProductKey,
    PromotionKey,
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

    -- Conform StoreKey: TRIM + UPPER (prevents 'sto01 ' mismatches)
    UPPER(LTRIM(RTRIM(CAST(s.StoreCode AS nvarchar(50))))) AS StoreKey,

    -- Conform Product/Promotion keys lightly (trim)
    LTRIM(RTRIM(s.ProductCode))   AS ProductKey,
    LTRIM(RTRIM(s.PromotionCode)) AS PromotionKey,

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

    CAST(CASE WHEN ISNULL(s.DiscountAmount,0) > 0 THEN 1 ELSE 0 END AS bit) AS IsDiscounted,

    CAST(CASE
        WHEN s.PromotionCode IS NULL THEN 0
        WHEN LTRIM(RTRIM(s.PromotionCode)) = '' THEN 0
        WHEN UPPER(LTRIM(RTRIM(s.PromotionCode))) IN ('NONE','NO_PROMO','NOPROMO','NA','N/A') THEN 0
        ELSE 1
    END AS bit) AS HasPromotion
FROM silver.fact_sales s;
GO

------------------------------------------------------------
-- 3) Ensure UNKNOWN store exists + map invalid StoreKeys to UNKNOWN
------------------------------------------------------------
IF OBJECT_ID('gold.dim_store','U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM gold.dim_store WHERE StoreKey = 'UNKNOWN')
    BEGIN
        INSERT INTO gold.dim_store (StoreKey, StoreName, IsActive)
        VALUES ('UNKNOWN', 'Unknown', 1);
    END

    UPDATE fs
    SET fs.StoreKey = 'UNKNOWN'
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_store ds
        ON ds.StoreKey = fs.StoreKey
    WHERE ds.StoreKey IS NULL;
END
GO

------------------------------------------------------------
-- 4) Indexes (Power BI performance)
------------------------------------------------------------
CREATE INDEX IX_gold_fact_sales_DateStore
ON gold.fact_sales(DateKey, StoreKey);
GO

CREATE INDEX IX_gold_fact_sales_Product
ON gold.fact_sales(ProductKey);
GO

CREATE INDEX IX_gold_fact_sales_Promotion
ON gold.fact_sales(PromotionKey);
GO

CREATE INDEX IX_gold_fact_sales_Channel
ON gold.fact_sales(ChannelCode);
GO

------------------------------------------------------------
-- 5) Foreign Keys (robust to numbered vs non-numbered dims)
------------------------------------------------------------

/* DATE */
IF OBJECT_ID('gold.[01_dim_date]', 'U') IS NOT NULL
BEGIN
    ALTER TABLE gold.fact_sales WITH CHECK
    ADD CONSTRAINT FK_gold_fact_sales_date
    FOREIGN KEY (DateKey) REFERENCES gold.[01_dim_date](DateKey);

    ALTER TABLE gold.fact_sales CHECK CONSTRAINT FK_gold_fact_sales_date;
END
ELSE IF OBJECT_ID('gold.[dim_date]', 'U') IS NOT NULL
BEGIN
    ALTER TABLE gold.fact_sales WITH CHECK
    ADD CONSTRAINT FK_gold_fact_sales_date
    FOREIGN KEY (DateKey) REFERENCES gold.[dim_date](DateKey);

    ALTER TABLE gold.fact_sales CHECK CONSTRAINT FK_gold_fact_sales_date;
END
ELSE
    PRINT 'WARNING: No gold date dimension found. Date FK not created.';


/* STORE */
IF OBJECT_ID('gold.[02_dim_store]', 'U') IS NOT NULL
BEGIN
    ALTER TABLE gold.fact_sales WITH CHECK
    ADD CONSTRAINT FK_gold_fact_sales_store
    FOREIGN KEY (StoreKey) REFERENCES gold.[02_dim_store](StoreKey);

    ALTER TABLE gold.fact_sales CHECK CONSTRAINT FK_gold_fact_sales_store;
END
ELSE IF OBJECT_ID('gold.[dim_store]', 'U') IS NOT NULL
BEGIN
    ALTER TABLE gold.fact_sales WITH CHECK
    ADD CONSTRAINT FK_gold_fact_sales_store
    FOREIGN KEY (StoreKey) REFERENCES gold.[dim_store](StoreKey);

    ALTER TABLE gold.fact_sales CHECK CONSTRAINT FK_gold_fact_sales_store;
END
ELSE
    PRINT 'WARNING: No gold store dimension found. Store FK not created.';


/* PRODUCT */
IF OBJECT_ID('gold.[03_dim_product]', 'U') IS NOT NULL
BEGIN
    ALTER TABLE gold.fact_sales WITH CHECK
    ADD CONSTRAINT FK_gold_fact_sales_product
    FOREIGN KEY (ProductKey) REFERENCES gold.[03_dim_product](ProductKey);

    ALTER TABLE gold.fact_sales CHECK CONSTRAINT FK_gold_fact_sales_product;
END
ELSE IF OBJECT_ID('gold.[dim_product]', 'U') IS NOT NULL
BEGIN
    ALTER TABLE gold.fact_sales WITH CHECK
    ADD CONSTRAINT FK_gold_fact_sales_product
    FOREIGN KEY (ProductKey) REFERENCES gold.[dim_product](ProductKey);

    ALTER TABLE gold.fact_sales CHECK CONSTRAINT FK_gold_fact_sales_product;
END
ELSE
    PRINT 'WARNING: No gold product dimension found. Product FK not created.';


/* CHANNEL */
IF OBJECT_ID('gold.[05_dim_channel]', 'U') IS NOT NULL
BEGIN
    ALTER TABLE gold.fact_sales WITH CHECK
    ADD CONSTRAINT FK_gold_fact_sales_channel
    FOREIGN KEY (ChannelCode) REFERENCES gold.[05_dim_channel](ChannelCode);

    ALTER TABLE gold.fact_sales CHECK CONSTRAINT FK_gold_fact_sales_channel;
END
ELSE IF OBJECT_ID('gold.[dim_channel]', 'U') IS NOT NULL
BEGIN
    ALTER TABLE gold.fact_sales WITH CHECK
    ADD CONSTRAINT FK_gold_fact_sales_channel
    FOREIGN KEY (ChannelCode) REFERENCES gold.[dim_channel](ChannelCode);

    ALTER TABLE gold.fact_sales CHECK CONSTRAINT FK_gold_fact_sales_channel;
END
ELSE
    PRINT 'WARNING: No gold channel dimension found. Channel FK not created.';


/* PROMOTION */
IF OBJECT_ID('gold.[06_dim_promotion]', 'U') IS NOT NULL
BEGIN
    ALTER TABLE gold.fact_sales WITH CHECK
    ADD CONSTRAINT FK_gold_fact_sales_promotion
    FOREIGN KEY (PromotionKey) REFERENCES gold.[06_dim_promotion](PromotionKey);

    ALTER TABLE gold.fact_sales CHECK CONSTRAINT FK_gold_fact_sales_promotion;
END
ELSE IF OBJECT_ID('gold.[dim_promotion]', 'U') IS NOT NULL
BEGIN
    ALTER TABLE gold.fact_sales WITH CHECK
    ADD CONSTRAINT FK_gold_fact_sales_promotion
    FOREIGN KEY (PromotionKey) REFERENCES gold.[dim_promotion](PromotionKey);

    ALTER TABLE gold.fact_sales CHECK CONSTRAINT FK_gold_fact_sales_promotion;
END
ELSE
    PRINT 'WARNING: No gold promotion dimension found. Promotion FK not created.';
GO

------------------------------------------------------------
-- 6) Quick QA: how many rows got mapped to UNKNOWN?
------------------------------------------------------------
SELECT
    StoreKey,
    COUNT(*) AS Rows
FROM gold.fact_sales
GROUP BY StoreKey
ORDER BY CASE WHEN StoreKey = 'UNKNOWN' THEN 0 ELSE 1 END, Rows DESC;
GO


SELECT *
FROM [gold].[fact_sales]
