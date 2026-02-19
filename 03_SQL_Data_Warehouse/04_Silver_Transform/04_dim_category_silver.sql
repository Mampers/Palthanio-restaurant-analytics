/*
SILVER: dim_category
- Standardises names and department
- Adds simple hierarchy flags
*/

USE [PalthanioRestaurants];
GO
SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver;');
GO

IF OBJECT_ID('silver.dim_category','U') IS NOT NULL
    DROP TABLE silver.dim_category;
GO

CREATE TABLE silver.dim_category
(
    CategoryKey   varchar(10)  NOT NULL,
    CategoryName  varchar(50)  NOT NULL,
    Department    varchar(20)  NOT NULL,
    IsFood        bit          NOT NULL,
    IsBeverage    bit          NOT NULL,
    IsOther       bit          NOT NULL
);
GO

INSERT INTO silver.dim_category
(
    CategoryKey, CategoryName, Department,
    IsFood, IsBeverage, IsOther
)
SELECT
    LTRIM(RTRIM(CategoryKey)),
    CASE WHEN CategoryName LIKE '%&%' THEN REPLACE(LTRIM(RTRIM(CategoryName)),'&','and')
         ELSE LTRIM(RTRIM(CategoryName))
    END,
    CASE
        WHEN UPPER(LTRIM(RTRIM(Department))) = 'FOOD' THEN 'Food'
        WHEN UPPER(LTRIM(RTRIM(Department))) = 'BEVERAGES' THEN 'Beverages'
        ELSE 'Other'
    END,
    CASE WHEN UPPER(Department) = 'FOOD' THEN 1 ELSE 0 END,
    CASE WHEN UPPER(Department) = 'BEVERAGES' THEN 1 ELSE 0 END,
    CASE WHEN UPPER(Department) NOT IN ('FOOD','BEVERAGES') THEN 1 ELSE 0 END
FROM bronze.dim_category_stage;
GO

