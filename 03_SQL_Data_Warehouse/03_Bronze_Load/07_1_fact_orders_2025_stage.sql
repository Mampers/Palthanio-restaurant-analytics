/*
Bronze STAGE: fact_orders_2025_stage
Purpose: Landing table that mirrors the CSV structure for BULK INSERT.
All columns stored as NVARCHAR to match the raw definition and avoid datatype issues.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.fact_orders_2025_stage;
GO

CREATE TABLE bronze.fact_orders_2025_stage (
    OrderID         NVARCHAR(50)  NULL,
    DateKey         NVARCHAR(20)  NULL,
    StoreKey        NVARCHAR(50)  NULL,
    ChannelKey      NVARCHAR(100) NULL,
    OrderRevenueNet NVARCHAR(50)  NULL,
    DiscountAmount  NVARCHAR(50)  NULL
);
GO

/*
BULK INSERT TEMPLATE (uncomment and update path locally before running)

BULK INSERT bronze.fact_orders_2025_stage
FROM 'C:\YourPath\fact_orders_2025.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',   -- use 0x0D0A if needed
    TABLOCK,
    CODEPAGE = '65001'
);
*/

