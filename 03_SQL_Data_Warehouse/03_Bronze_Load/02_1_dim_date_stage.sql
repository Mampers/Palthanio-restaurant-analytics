/*
Bronze STAGE: dim_date_stage
Purpose: Landing table that mirrors the CSV structure for BULK INSERT.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.dim_date_stage;
GO

CREATE TABLE bronze.dim_date_stage (
    DateKey     VARCHAR(20) NULL,
    FullDate    VARCHAR(30) NULL,
    [Year]      VARCHAR(10) NULL,
    [Quarter]   VARCHAR(10) NULL,
    [Month]     VARCHAR(10) NULL,
    MonthName   VARCHAR(20) NULL,
    [Day]       VARCHAR(10) NULL,
    DayOfWeek   VARCHAR(10) NULL,
    DayName     VARCHAR(20) NULL,
    IsWeekend   VARCHAR(10) NULL,
    WeekOfYear  VARCHAR(10) NULL
);
GO

/*
BULK INSERT TEMPLATE (uncomment and update path locally)

Tip:
- If your CSV uses Windows line endings, use ROWTERMINATOR = '0x0D0A'
- If you get encoding issues, keep CODEPAGE = '65001'

BULK INSERT bronze.dim_date_stage
FROM 'C:\YourPath\dim_date.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK,
    CODEPAGE = '65001'
);
*/

