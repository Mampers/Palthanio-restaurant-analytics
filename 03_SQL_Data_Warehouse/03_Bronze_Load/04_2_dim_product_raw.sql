/*
Bronze RAW: dim_product_raw
Purpose: Persisted bronze table with lineage + load timestamp.
Loads data from bronze.dim_product_stage.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.dim_product_raw;
GO

CREATE TABLE bronze.dim_product_raw (
    ProductKey      VARCHAR(20)  NULL,
    SKU             VARCHAR(50)  NULL,
    ProductName     VARCHAR(255) NULL,
    CategoryKey     VARCHAR(20)  NULL,
    ListPrice       DECIMAL(10,2) NULL,
    UnitCost        DECIMAL(10,2) NULL,
    PrepTimeSeconds INT NULL,
    IsVegetarian    BIT NULL,
    IsVegan         BIT NULL,
    IsGlutenFree    BIT NULL,
    SourceSystem    VARCHAR(50)  NULL,
    SourceFile      VARCHAR(260) NULL,
    LoadDts         DATETIME2(0) NOT NULL
);
GO

ALTER TABLE bronze.dim_product_raw
ADD CONSTRAINT DF_dim_product_raw_LoadDts
DEFAULT (SYSDATETIME()) FOR LoadDts;
GO

-- Insert STAGE -> RAW (minimal casting only)
INSERT INTO bronze.dim_product_raw (
    ProductKey,
    SKU,
    ProductName,
    CategoryKey,
    ListPrice,
    UnitCost,
    PrepTimeSeconds,
    IsVegetarian,
    IsVegan,
    IsGlutenFree,
    SourceSystem,
    SourceFile
)
SELECT
    LTRIM(RTRIM(ProductKey)),
    LTRIM(RTRIM(SKU)),
    LTRIM(RTRIM(ProductName)),
    LTRIM(RTRIM(CategoryKey)),
    TRY_CONVERT(DECIMAL(10,2), ListPrice),
    TRY_CONVERT(DECIMAL(10,2), UnitCost),
    TRY_CONVERT(INT, PrepTimeSeconds),
    TRY_CONVERT(BIT, IsVegetarian),
    TRY_CONVERT(BIT, IsVegan),
    TRY_CONVERT(BIT, IsGlutenFree),
    'mdm',
    'dim_product.csv'
FROM bronze.dim_product_stage;
GO

