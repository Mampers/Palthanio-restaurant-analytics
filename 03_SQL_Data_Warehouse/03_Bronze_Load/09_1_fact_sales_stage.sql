/*
Bronze STAGE: fact_sales_stage
Purpose: Landing table that mirrors the CSV structure for BULK INSERT.
No transformations performed here.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.fact_sales_stage;
GO

CREATE TABLE bronze.fact_sales_stage (
    SalesLineID      VARCHAR(50) NULL,
    TransactionID    VARCHAR(50) NULL,
    DateKey          VARCHAR(50) NULL,
    StoreKey         VARCHAR(50) NULL,
    NewStoreKey      VARCHAR(50) NULL,
    ProductKey       VARCHAR(50) NULL,
    NewProductKey    VARCHAR(50) NULL,
    PromotionKey     VARCHAR(50) NULL,
    NewPromotionKey  VARCHAR(50) NULL,
    Channel          VARCHAR(50) NULL,
    PaymentMethod    VARCHAR(50) NULL,
    DayPart          VARCHAR(50) NULL,
    TransactionTime  VARCHAR(20) NULL,
    Quantity         VARCHAR(50) NULL,
    GrossRevenue     VARCHAR(50) NULL,
    DiscountAmount   VARCHAR(50) NULL,
    NetRevenue       VARCHAR(50) NULL,
    COGS             VARCHAR(50) NULL
);
GO

/*
BULK INSERT TEMPLATE (update file path locally before running)

BULK INSERT bronze.fact_sales_stage
FROM 'C:\YourPath\fact_sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',   -- change to 0x0D0A if needed
    TABLOCK,
    CODEPAGE = '65001'
);
*/

