
/*
Bronze STAGE: dim_product_stage
Purpose: Landing table that mirrors the CSV structure for BULK INSERT.
All columns stored as VARCHAR to avoid datatype load issues.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.dim_product_stage;
GO

CREATE TABLE bronze.dim_product_stage (
    ProductKey       VARCHAR(20)  NULL,
    SKU              VARCHAR(50)  NULL,
    ProductName      VARCHAR(255) NULL,
    CategoryKey      VARCHAR(20)  NULL,
    ListPrice        VARCHAR(50)  NULL,
    UnitCost         VARCHAR(50)  NULL,
    PrepTimeSeconds  VARCHAR(50)  NULL,
    IsVegetarian     VARCHAR(10)  NULL,
    IsVegan          VARCHAR(10)  NULL,
    IsGlutenFree     VARCHAR(10)  NULL
);
GO

/*
BULK INSERT TEMPLATE (update file path locally)

BULK INSERT bronze.dim_product_stage
FROM 'C:\YourPath\dim_product.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK,
    CODEPAGE = '65001'
);
*/
