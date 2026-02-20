USE [PalthanioRestaurants];
GO

/* ============================================================
   BRONZE -> SILVER : dim_promotion
   Source : bronze.dim_promotion_raw
   Target : silver.dim_promotion

   Cleans:
   - trims text
   - standardises PromotionType/DiscountType casing
   - deduplicates

   Adds:
   - PromotionDurationDays
   - IsActiveToday
   - IsValidDateRange
   ============================================================ */

SET NOCOUNT ON;

------------------------------------------------------------
-- 0) Ensure schema exists
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver;');
GO

------------------------------------------------------------
-- 1) Drop + recreate (safe for reruns)
------------------------------------------------------------
IF OBJECT_ID('silver.dim_promotion', 'U') IS NOT NULL
    DROP TABLE silver.dim_promotion;
GO

CREATE TABLE silver.dim_promotion
(
    PromotionKey         varchar(20)   NOT NULL,
    PromotionName        varchar(255)  NULL,
    PromotionType        varchar(100)  NULL,
    DiscountType         varchar(50)   NULL,
    DiscountValue        decimal(10,2) NULL,
    StartDate            date          NULL,
    EndDate              date          NULL,

    PromotionDurationDays int          NULL,
    IsActiveToday        bit           NOT NULL,
    IsValidDateRange     bit           NOT NULL
);
GO

------------------------------------------------------------
-- 2) Insert cleaned + enriched data
------------------------------------------------------------
;WITH cleaned AS
(
    SELECT
        NULLIF(LTRIM(RTRIM(PromotionKey)), '') AS PromotionKey,
        NULLIF(LTRIM(RTRIM(PromotionName)), '') AS PromotionName,

        -- standardise types (simple casing cleanup)
        NULLIF(LTRIM(RTRIM(PromotionType)), '') AS PromotionType,
        NULLIF(LTRIM(RTRIM(DiscountType)), '')  AS DiscountType,

        TRY_CONVERT(decimal(10,2), DiscountValue) AS DiscountValue,
        TRY_CONVERT(date, StartDate) AS StartDate,
        TRY_CONVERT(date, EndDate)   AS EndDate,

        LoadDts
    FROM bronze.dim_promotion_raw
),
dedup AS
(
    -- if multiple loads exist, keep the latest LoadDts per PromotionKey
    SELECT *
    FROM
    (
        SELECT
            c.*,
            ROW_NUMBER() OVER (PARTITION BY c.PromotionKey ORDER BY c.LoadDts DESC) AS rn
        FROM cleaned c
        WHERE c.PromotionKey IS NOT NULL
    ) x
    WHERE x.rn = 1
)
INSERT INTO silver.dim_promotion
(
    PromotionKey,
    PromotionName,
    PromotionType,
    DiscountType,
    DiscountValue,
    StartDate,
    EndDate,
    PromotionDurationDays,
    IsActiveToday,
    IsValidDateRange
)
SELECT
    d.PromotionKey,
    d.PromotionName,
    d.PromotionType,
    d.DiscountType,
    d.DiscountValue,
    d.StartDate,
    d.EndDate,

    CASE
        WHEN d.StartDate IS NULL OR d.EndDate IS NULL THEN NULL
        ELSE DATEDIFF(day, d.StartDate, d.EndDate) + 1
    END AS PromotionDurationDays,

    CAST(CASE
        WHEN d.StartDate IS NULL OR d.EndDate IS NULL THEN 0
        WHEN CAST(GETDATE() AS date) BETWEEN d.StartDate AND d.EndDate THEN 1
        ELSE 0
    END AS bit) AS IsActiveToday,

    CAST(CASE
        WHEN d.StartDate IS NULL OR d.EndDate IS NULL THEN 0
        WHEN d.EndDate < d.StartDate THEN 0
        ELSE 1
    END AS bit) AS IsValidDateRange
FROM dedup d;
GO

------------------------------------------------------------
-- 3) Optional: Primary key + helpful index
------------------------------------------------------------
ALTER TABLE silver.dim_promotion
ADD CONSTRAINT PK_silver_dim_promotion PRIMARY KEY (PromotionKey);
GO

CREATE INDEX IX_silver_dim_promotion_Dates
ON silver.dim_promotion(StartDate, EndDate);
GO

-- Spot check (optional)
-- SELECT TOP (50) * FROM silver.dim_promotion ORDER BY PromotionKey;

