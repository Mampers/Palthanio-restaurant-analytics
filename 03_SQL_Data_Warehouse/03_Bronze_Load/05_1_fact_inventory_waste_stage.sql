
/*
Bronze STAGE: fact_inventory_waste_stage
Purpose: Landing table that mirrors the CSV structure for BULK INSERT.
No transformations performed here.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.fact_inventory_waste_stage;
GO

CREATE TABLE bronze.fact_inventory_waste_stage (
    WasteID            VARCHAR(50) NULL,
    DateKey            VARCHAR(50) NULL,
    StoreKey           VARCHAR(50) NULL,
    NewStoreKey        VARCHAR(50) NULL,
    ProductKey         VARCHAR(50) NULL,
    NewProductKey      VARCHAR(50) NULL,
    WasteQuantity      VARCHAR(50) NULL,
    WasteCost          VARCHAR(50) NULL,
    WasteReason        VARCHAR(200) NULL,
    Unused1            VARCHAR(50) NULL,
    Unused2            VARCHAR(50) NULL,
    Unused3            VARCHAR(50) NULL,
    Unused4            VARCHAR(50) NULL,
    Unused5            VARCHAR(50) NULL,
    Unused6            VARCHAR(50) NULL,
    ExtraStoreKey      VARCHAR(50) NULL,
    ExtraNewStoreKey   VARCHAR(50) NULL
);
GO

/*
BULK INSERT TEMPLATE (update path locally before running)

BULK INSERT bronze.fact_inventory_waste_stage
FROM 'C:\YourPath\fact_inventory_waste.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',   -- use 0x0D0A if needed
    TABLOCK,
    CODEPAGE = '65001'
);
*/
