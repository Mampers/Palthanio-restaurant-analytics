/* ============================================================
   SILVER -> GOLD : 04_dim_category
   Source : silver.dim_category
   Target : gold.04_dim_category

   Purpose:
   - Business-ready category dimension
   - Adds semantic grouping fields
   - Adds ordering + core revenue flags
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
IF OBJECT_ID('gold.04_dim_category','U') IS NOT NULL
    DROP TABLE gold.04_dim_category;
GO

CREATE TABLE gold.04_dim_category
(
    CategoryKey        varchar(10) NOT NULL,
    CategoryName       varchar(50) NOT NULL,
    Department         varchar(20) NOT NULL,
    CategoryGroup      varchar(8)  NOT NULL,
    CategoryType       varchar(10) NOT NULL,
    IsCoreRevenue      int         NOT NULL,
    CategorySortOrder  int         NOT NULL
);
GO

------------------------------------------------------------
-- 2) Insert from Silver with business logic
------------------------------------------------------------
INSERT INTO gold.04_dim_category
(
    CategoryKey,
    CategoryName,
    Department,
    CategoryGroup,
    CategoryType,
    IsCoreRevenue,
    CategorySortOrder
)
SELECT
    c.CategoryKey,
    c.CategoryName,
    c.Department,

    --------------------------------------------------------
    -- CategoryGroup (executive-level grouping)
    --------------------------------------------------------
    CASE
        WHEN c.Department = 'Food' THEN 'Food'
        WHEN c.Department = 'Beverages' THEN 'Beverage'
        ELSE 'Other'
    END AS CategoryGroup,

    --------------------------------------------------------
    -- CategoryType (analytics grouping)
    --------------------------------------------------------
    CASE
        WHEN c.Department = 'Food' THEN 'MenuItem'
        WHEN c.Department = 'Beverages' THEN 'Drink'
        ELSE 'NonCore'
    END AS CategoryType,

    --------------------------------------------------------
    -- IsCoreRevenue
    -- Example rule: Food + Beverages drive revenue
    --------------------------------------------------------
    CASE
        WHEN c.Department IN ('Food','Beverages') THEN 1
        ELSE 0
    END AS IsCoreRevenue,

    --------------------------------------------------------
    -- CategorySortOrder (controls report display order)
    --------------------------------------------------------
    CASE
        WHEN c.Department = 'Food' THEN 1
        WHEN c.Department = 'Beverages' THEN 2
        ELSE 3
    END AS CategorySortOrder

FROM silver.dim_category c;
GO

------------------------------------------------------------
-- 3) Add PK
------------------------------------------------------------
ALTER TABLE gold.04_dim_category
ADD CONSTRAINT PK_gold_dim_category
PRIMARY KEY (CategoryKey);
GO

------------------------------------------------------------
-- 4) Helpful index
------------------------------------------------------------
CREATE INDEX IX_gold_dim_category_Department
ON gold.04_dim_category(Department);
GO

