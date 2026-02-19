/*
Bronze STAGE: dim_channel_paymentmethod_stage
Purpose: Landing table that mirrors the CSV structure for BULK INSERT.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.dim_channel_paymentmethod_stage;
GO

CREATE TABLE bronze.dim_channel_paymentmethod_stage (
    Channel        VARCHAR(100) NULL,
    PaymentMethod  VARCHAR(100) NULL
);
GO

/*
BULK INSERT TEMPLATE (uncomment and update path locally)

BULK INSERT bronze.dim_channel_paymentmethod_stage
FROM 'C:\YourPath\dim_channel_paymentmethod.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',  -- change to 0x0D0A if needed
    TABLOCK,
    CODEPAGE = '65001'
);
*/

