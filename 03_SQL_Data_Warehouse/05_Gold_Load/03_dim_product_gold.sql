/* ============================================================
   SILVER -> GOLD : 03_dim_product
   Source : silver.dim_product (base)
            silver.dim_category (lookup)
   Target : gold.03_dim_product

   Purpose:
   - Business-ready product dimension
   - Enriches product with category attributes
   - Adds analytical groupings:
       ProductType, MarginBand, PrepSpeedBand, MarginPerPrepMinute
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
IF OBJECT_ID('gold.03_dim_product','U') IS NOT NULL
    DROP TABLE gold.03_dim_product;
GO

CREATE TABLE gold.03_dim_product
(
    ProductKey            varchar(10)    NOT NULL,
    SKU                   varchar(20)    NULL,
    ProductName           varchar(100)   NULL,
    CategoryKey           varchar(10)    NULL,

    CategoryName          varchar(50)    NULL,
    Department            varchar(20)    NULL,
    CategoryGroup         varchar(8)     NULL,   -- Food/Beverage/Other
    CategoryType          varchar(10)    NULL,   -- optional label
    IsCoreRevenue         int            NULL,   -- optional flag
    CategorySortOrder     int            NULL,   -- optional ordering

    ListPrice             decimal(10,2)  NULL,
    UnitCost              decimal(10,2)  NULL,
    GrossMargin           decimal(10,2)  NULL,
    GrossMarginPct        decimal(10,4)  NULL,
    PrepTimeSeconds       int            NULL,
    PrepTimeMinutes       decimal(10,2)  NULL,

    IsVegetarian          bit            NULL,
    IsVegan               bit            NULL,
    IsGlutenFree          bit            NULL,

    PriceBand             varchar(20)    NULL,
    CostBand              varchar(20)    NULL,
    IsHighMargin          bit            NULL,

    --------------------------------------------------------
    -- Gold-only analytics groupings
    --------------------------------------------------------
    ProductType           varchar(8)     NOT NULL,  -- Food/Drink/Other
    MarginBand            varchar(9)     NOT NULL,  -- Low/Med/High
    PrepSpeedBand         varchar(6)     NOT NULL,  -- Fast/Med/Slow
    MarginPerPrepMinute   decimal(23,13) NULL,

    CONSTRAINT PK_gold_dim_product PRIMARY KEY CLUSTERED (ProductKey)
);
GO

------------------------------------------------------------
-- 2) Insert from Silver + Category enrichment
------------------------------------------------------------
INSERT INTO gold.03_dim_product
(
    ProductKey, SKU, ProductName, CategoryKey,
    CategoryName, Department, CategoryGroup, CategoryType, IsCoreRevenue, CategorySortOrder,
    ListPrice, UnitCost, GrossMargin, GrossMarginPct,
    PrepTimeSeconds, PrepTimeMinutes,
    IsVegetarian, IsVegan, IsGlutenFree,
    PriceBand, CostBand, IsHighMargin,
    ProductType, MarginBand, PrepSpeedBand, MarginPerPrepMinute
)
SELECT
    p.ProductKey,
    p.SKU,
    p.ProductName,
    p.CategoryKey,

    c.CategoryName,
    c.Department,

    --------------------------------------------------------
    -- CategoryGroup (simple, business-friendly grouping)
    --------------------------------------------------------
    CASE
        WHEN c.Department = 'Food' THEN 'Food'
        WHEN c.Department = 'Beverages' THEN 'Beverage'
        ELSE 'Other'
    END AS CategoryGroup,

    --------------------------------------------------------
    -- CategoryType (optional: tweak to your business rules)
    --------------------------------------------------------
    CASE
        WHEN c.Department = 'Food' THEN 'MenuItem'
        WHEN c.Department = 'Beverages' THEN 'Drink'
        ELSE 'Other'
    END AS CategoryType,

    --------------------------------------------------------
    -- IsCoreRevenue (optional: tweak)
    -- Example logic: core if Food or Beverage and ListPrice not null
    --------------------------------------------------------
    CASE
        WHEN c.Department IN ('Food','Beverages') AND p.ListPrice IS NOT NULL THEN 1
        ELSE 0
    END AS IsCoreRevenue,

    --------------------------------------------------------
    -- CategorySortOrder (optional: tweak)
    --------------------------------------------------------
    CASE
        WHEN c.Department = 'Food' THEN 1
        WHEN c.Department = 'Beverages' THEN 2
        ELSE 3
    END AS CategorySortOrder,

    p.ListPrice,
    p.UnitCost,
    p.GrossMargin,
    p.GrossMarginPct,
    p.PrepTimeSeconds,
    p.PrepTimeMinutes,
    p.IsVegetarian,
    p.IsVegan,
    p.IsGlutenFree,
    p.PriceBand,
    p.CostBand,
    p.IsHighMargin,

    --------------------------------------------------------
    -- ProductType (required)
    --------------------------------------------------------
    CASE
        WHEN c.Department = 'Food' THEN 'Food'
        WHEN c.Department = 'Beverages' THEN 'Drink'
        ELSE 'Other'
    END AS ProductType,

    --------------------------------------------------------
    -- MarginBand (required)
    --------------------------------------------------------
    CASE
        WHEN p.GrossMarginPct IS NULL THEN 'Unknown'
        WHEN p.GrossMarginPct < 0.40 THEN 'Low'
        WHEN p.GrossMarginPct < 0.60 THEN 'Medium'
        ELSE 'High'
    END AS MarginBand,

    --------------------------------------------------------
    -- PrepSpeedBand (required)
    --------------------------------------------------------
    CASE
        WHEN p.PrepTimeSeconds IS NULL THEN 'Unknown'
        WHEN p.PrepTimeSeconds <= 120 THEN 'Fast'
        WHEN p.PrepTimeSeconds <= 300 THEN 'Med'
        ELSE 'Slow'
    END AS PrepSpeedBand,

    --------------------------------------------------------
    -- MarginPerPrepMinute (useful KPI)
    --------------------------------------------------------
    CASE
        WHEN p.GrossMargin IS NULL OR p.PrepTimeMinutes IS NULL OR p.PrepTimeMinutes = 0
            THEN NULL
        ELSE CAST(p.GrossMargin / NULLIF(p.PrepTimeMinutes, 0) AS decimal(23,13))
    END AS MarginPerPrepMinute

FROM silver.dim_product p
LEFT JOIN silver.dim_category c
    ON p.CategoryKey = c.CategoryKey;
GO

------------------------------------------------------------
-- 3) Helpful indexes
------------------------------------------------------------
CREATE INDEX IX_gold_dim_product_CategoryKey
ON gold.03_dim_product(CategoryKey);

CREATE INDEX IX_gold_dim_product_ProductName
ON gold.03_dim_product(ProductName);
GO

