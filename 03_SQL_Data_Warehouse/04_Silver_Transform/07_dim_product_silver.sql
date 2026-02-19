/* SILVER: dim_product (clean + enriched) */

USE [PalthanioRestaurants];
GO
SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver;');
GO

IF OBJECT_ID('silver.dim_product', 'U') IS NOT NULL
    DROP TABLE silver.dim_product;
GO

CREATE TABLE silver.dim_product
(
    ProductKey        varchar(10)    NOT NULL,
    SKU               varchar(20)    NULL,
    ProductName       varchar(100)   NULL,
    CategoryKey       varchar(10)    NULL,
    ListPrice         decimal(10,2)  NULL,
    UnitCost          decimal(10,2)  NULL,
    GrossMargin       decimal(10,2)  NULL,
    GrossMarginPct    decimal(10,4)  NULL,
    PrepTimeSeconds   int            NULL,
    PrepTimeMinutes   decimal(10,2)  NULL,
    IsVegetarian      bit            NULL,
    IsVegan           bit            NULL,
    IsGlutenFree      bit            NULL,
    PriceBand         varchar(20)    NULL,
    CostBand          varchar(20)    NULL,
    IsHighMargin      bit            NULL
);
GO

INSERT INTO silver.dim_product
(
    ProductKey, SKU, ProductName, CategoryKey,
    ListPrice, UnitCost, GrossMargin, GrossMarginPct,
    PrepTimeSeconds, PrepTimeMinutes,
    IsVegetarian, IsVegan, IsGlutenFree,
    PriceBand, CostBand, IsHighMargin
)
SELECT
    LTRIM(RTRIM(b.ProductKey)),
    LTRIM(RTRIM(b.SKU)),
    LTRIM(RTRIM(b.ProductName)),
    LTRIM(RTRIM(b.CategoryKey)),
    lp.ListPrice,
    uc.UnitCost,
    CASE WHEN lp.ListPrice IS NULL OR uc.UnitCost IS NULL THEN NULL
         ELSE CAST(ROUND(lp.ListPrice - uc.UnitCost, 2) AS decimal(10,2)) END,
    CASE WHEN lp.ListPrice IS NULL OR lp.ListPrice = 0 OR uc.UnitCost IS NULL THEN NULL
         ELSE CAST(ROUND((lp.ListPrice - uc.UnitCost) / NULLIF(lp.ListPrice,0), 4) AS decimal(10,4)) END,
    pts.PrepTimeSeconds,
    CASE WHEN pts.PrepTimeSeconds IS NULL THEN NULL
         ELSE CAST(ROUND(pts.PrepTimeSeconds / 60.0, 2) AS decimal(10,2)) END,
    f.IsVegetarian, f.IsVegan, f.IsGlutenFree,
    CASE WHEN lp.ListPrice IS NULL THEN NULL
         WHEN lp.ListPrice < 3.00 THEN 'Budget'
         WHEN lp.ListPrice <= 6.00 THEN 'Standard'
         ELSE 'Premium' END,
    CASE WHEN uc.UnitCost IS NULL THEN NULL
         WHEN uc.UnitCost < 1.00 THEN 'Low'
         WHEN uc.UnitCost <= 2.50 THEN 'Medium'
         ELSE 'High' END,
    CASE
        WHEN lp.ListPrice IS NULL OR lp.ListPrice = 0 OR uc.UnitCost IS NULL THEN NULL
        WHEN ((lp.ListPrice - uc.UnitCost) / NULLIF(lp.ListPrice,0)) >= 0.60 THEN CAST(1 AS bit)
        ELSE CAST(0 AS bit)
    END
FROM bronze.dim_product_stage b
CROSS APPLY (SELECT TRY_CONVERT(decimal(10,2), b.ListPrice) AS ListPrice) lp
CROSS APPLY (SELECT TRY_CONVERT(decimal(10,2), b.UnitCost)  AS UnitCost)  uc
CROSS APPLY (SELECT TRY_CONVERT(int, b.PrepTimeSeconds)     AS PrepTimeSeconds) pts
CROSS APPLY
(
    SELECT
        CASE WHEN TRY_CONVERT(int, b.IsVegetarian) = 1 THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS IsVegetarian,
        CASE WHEN TRY_CONVERT(int, b.IsVegan)      = 1 THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS IsVegan,
        CASE WHEN TRY_CONVERT(int, b.IsGlutenFree) = 1 THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS IsGlutenFree
) f;
GO

