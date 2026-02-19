/*
Bronze STAGE: fact_promo_performance_stage
Purpose: Landing table that mirrors the CSV structure for BULK INSERT.
No transformations performed here.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.fact_promo_performance_stage;
GO

CREATE TABLE bronze.fact_promo_performance_stage (
    PromoDate       VARCHAR(50)  NULL,
    StoreCode       VARCHAR(50)  NULL,
    StoreName       VARCHAR(255) NULL,
    ProductCode     VARCHAR(50)  NULL,
    ProductName     VARCHAR(255) NULL,
    PromoType       VARCHAR(100) NULL,
    UnitsSold       VARCHAR(50)  NULL,
    Revenue         VARCHAR(50)  NULL,
    DiscountAmount  VARCHAR(50)  NULL
);
GO

/*
BULK INSERT TEMPLATE (update file path locally before running)

BULK INSERT bronze.fact_promo_performance_stage
FROM 'C:\YourPath\fact_promo_performance.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',   -- change to 0x0D0A if needed
    TABLOCK,
    CODEPAGE = '65001'
);
*/

