/*
SILVER: fact_sales
- Cleans and types bronze.fact_sales_raw
- Renames keys to codes (StoreCode/ProductCode/PromotionCode)
- Converts datatypes
- Calculates GrossProfit, GrossMargin, GrossMarginPct
*/

USE [PalthanioRestaurants];
GO
SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver;');
GO

BEGIN TRY
    BEGIN TRAN;

    IF OBJECT_ID('silver.fact_sales', 'U') IS NOT NULL
        DROP TABLE silver.fact_sales;

    CREATE TABLE silver.fact_sales
    (
        SalesLineID        varchar(50)  NOT NULL,
        TransactionRef     varchar(50)  NOT NULL,
        DateKey            int          NOT NULL,
        StoreCode          varchar(10)  NOT NULL,
        ProductCode        varchar(10)  NOT NULL,
        PromotionCode      varchar(10)  NOT NULL,
        Channel            varchar(50)  NULL,
        PaymentMethod      varchar(50)  NULL,
        DayPart            varchar(50)  NULL,
        TransactionTime    time(0)      NULL,
        Quantity           int          NULL,

        GrossRevenue       decimal(12,2) NULL,
        DiscountAmount     decimal(12,2) NULL,
        NetRevenue         decimal(12,2) NULL,
        COGS               decimal(12,2) NULL,

        GrossProfit        decimal(12,2) NULL,
        GrossMargin        decimal(12,2) NULL,
        GrossMarginPct     decimal(12,6) NULL
    );

    ;WITH src AS
    (
        SELECT
            b.SalesLineID,
            CONCAT('TRA', RIGHT(CONCAT('00000', TRY_CONVERT(int, b.TransactionID)), 5)) AS TransactionRef,
            TRY_CONVERT(int, b.DateKey) AS DateKey,

            b.NewStoreKey     AS StoreCode,
            b.NewProductKey   AS ProductCode,
            b.NewPromotionKey AS PromotionCode,

            b.Channel,
            b.PaymentMethod,
            b.DayPart,

            TRY_CONVERT(time(0),
                CASE
                    WHEN b.TransactionTime LIKE '%:%:%' THEN b.TransactionTime
                    WHEN b.TransactionTime LIKE '%:%'   THEN CONCAT(b.TransactionTime, ':00')
                    ELSE NULL
                END
            ) AS TransactionTime,

            TRY_CONVERT(int, b.Quantity) AS Quantity,

            TRY_CONVERT(decimal(12,2), NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(b.GrossRevenue)), ',', ''), '£', ''), ''))   AS GrossRevenue,
            TRY_CONVERT(decimal(12,2), NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(b.DiscountAmount)), ',', ''), '£', ''), '')) AS DiscountAmount,
            TRY_CONVERT(decimal(12,2), NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(b.NetRevenue)), ',', ''), '£', ''), ''))     AS NetRevenue,
            TRY_CONVERT(decimal(12,2), NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(b.COGS)), ',', ''), '£', ''), ''))           AS COGS
        FROM bronze.fact_sales_raw b
    )
    INSERT INTO silver.fact_sales
    (
        SalesLineID, TransactionRef, DateKey, StoreCode, ProductCode, PromotionCode,
        Channel, PaymentMethod, DayPart, TransactionTime, Quantity,
        GrossRevenue, DiscountAmount, NetRevenue, COGS,
        GrossProfit, GrossMargin, GrossMarginPct
    )
    SELECT
        s.SalesLineID,
        s.TransactionRef,
        s.DateKey,
        s.StoreCode,
        s.ProductCode,
        s.PromotionCode,
        s.Channel,
        s.PaymentMethod,
        s.DayPart,
        s.TransactionTime,
        s.Quantity,
        s.GrossRevenue,
        s.DiscountAmount,
        s.NetRevenue,
        s.COGS,

        CASE WHEN s.NetRevenue IS NULL OR s.COGS IS NULL THEN NULL ELSE s.NetRevenue - s.COGS END AS GrossProfit,
        CASE WHEN s.NetRevenue IS NULL OR s.COGS IS NULL THEN NULL ELSE s.NetRevenue - s.COGS END AS GrossMargin,
        CASE
            WHEN s.NetRevenue IS NULL OR s.NetRevenue = 0 OR s.COGS IS NULL THEN NULL
            ELSE CAST((s.NetRevenue - s.COGS) / s.NetRevenue AS decimal(12,6))
        END AS GrossMarginPct
    FROM src s;

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH;
GO

