/*
Bronze STAGE: fact_labor_costs_stage
Purpose: Landing table that mirrors the CSV structure for BULK INSERT.
All columns stored as VARCHAR to avoid datatype load issues.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.fact_labor_costs_stage;
GO

CREATE TABLE bronze.fact_labor_costs_stage (
    LabourID     VARCHAR(20)  NULL,
    DateKey      VARCHAR(50)  NULL,
    StoreKey     VARCHAR(50)  NULL,
    NewStoreKEy  VARCHAR(20)  NULL,
    [Role]       VARCHAR(100) NULL,
    HoursWorked  VARCHAR(50)  NULL,
    HourlyRate   VARCHAR(50)  NULL,
    LabourCost   VARCHAR(50)  NULL
);
GO

/*
BULK INSERT TEMPLATE (update path locally before running)

BULK INSERT bronze.fact_labor_costs_stage
FROM 'C:\YourPath\fact_labor_costs.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',   -- use 0x0D0A if needed
    TABLOCK,
    CODEPAGE = '65001'
);
*/

