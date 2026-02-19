
/* SILVER: dim_date (enriched date dimension) */

USE [PalthanioRestaurants];
GO
SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver;');
GO

IF OBJECT_ID('silver.dim_date','U') IS NOT NULL
    DROP TABLE silver.dim_date;
GO

CREATE TABLE silver.dim_date
(
    DateKey                 int           NOT NULL,
    FullDate                date          NOT NULL,

    [Year]                  smallint      NOT NULL,
    [Quarter]               tinyint       NOT NULL,
    [Month]                 tinyint       NOT NULL,
    MonthName               varchar(10)   NOT NULL,
    [Day]                   tinyint       NOT NULL,

    DayOfWeek               tinyint       NOT NULL,
    DayName                 varchar(10)   NOT NULL,

    IsWeekend               bit           NOT NULL,
    WeekOfYear              tinyint       NOT NULL,

    YearMonthInt            int           NOT NULL,
    YearMonthLabel          char(7)       NOT NULL,
    MonthYearLabel          varchar(15)   NOT NULL,
    YearQuarterLabel        char(7)       NOT NULL,

    IsWeekday               bit           NOT NULL,
    IsMonthStart            bit           NOT NULL,
    IsMonthEnd              bit           NOT NULL,
    IsQuarterStart          bit           NOT NULL,
    IsQuarterEnd            bit           NOT NULL,
    IsYearStart             bit           NOT NULL,
    IsYearEnd               bit           NOT NULL,

    DayType                 varchar(10)   NOT NULL,

    DayOffsetFromToday      int           NULL,
    MonthOffsetFromCurrent  int           NULL,
    YearOffsetFromCurrent   int           NULL,

    IsCurrentMonth          bit           NOT NULL,
    IsLastMonth             bit           NOT NULL,
    IsYTD                   bit           NOT NULL
);
GO

;WITH src AS
(
    SELECT
        b.DateKey,
        TRY_CONVERT(date, b.FullDate, 103) AS FullDate,
        TRY_CONVERT(smallint, b.[Year])    AS [Year],
        TRY_CONVERT(tinyint,  b.[Quarter]) AS [Quarter],
        TRY_CONVERT(tinyint,  b.[Month])   AS [Month],
        LTRIM(RTRIM(b.MonthName))          AS MonthName,
        TRY_CONVERT(tinyint,  b.[Day])     AS [Day],
        TRY_CONVERT(tinyint,  b.DayOfWeek) AS DayOfWeek,
        LTRIM(RTRIM(b.DayName))            AS DayName,
        CAST(CASE WHEN b.IsWeekend IN (1,'1') THEN 1 ELSE 0 END AS bit) AS IsWeekend,
        TRY_CONVERT(tinyint,  b.WeekOfYear) AS WeekOfYear
    FROM bronze.dim_date_stage b
),
calcs AS
(
    SELECT
        s.*,
        (s.[Year] * 100) + s.[Month] AS YearMonthInt,
        CONVERT(char(7), DATEFROMPARTS(s.[Year], s.[Month], 1), 126) AS YearMonthLabel,
        CONCAT(LEFT(DATENAME(month, DATEFROMPARTS(s.[Year], s.[Month], 1)), 3), '-', s.[Year]) AS MonthYearLabel,
        CONCAT(s.[Year], '-Q', s.[Quarter]) AS YearQuarterLabel,

        CAST(CASE WHEN s.IsWeekend = 1 THEN 0 ELSE 1 END AS bit) AS IsWeekday,
        CAST(CASE WHEN s.[Day] = 1 THEN 1 ELSE 0 END AS bit) AS IsMonthStart,
        CAST(CASE WHEN s.FullDate = EOMONTH(s.FullDate) THEN 1 ELSE 0 END AS bit) AS IsMonthEnd,

        CAST(CASE WHEN s.FullDate = DATEFROMPARTS(s.[Year], ((s.[Quarter]-1)*3)+1, 1) THEN 1 ELSE 0 END AS bit) AS IsQuarterStart,
        CAST(CASE
                WHEN s.FullDate = EOMONTH(DATEFROMPARTS(s.[Year], ((s.[Quarter]-1)*3)+3, 1))
                THEN 1 ELSE 0
            END AS bit) AS IsQuarterEnd,

        CAST(CASE WHEN s.[Month] = 1 AND s.[Day] = 1 THEN 1 ELSE 0 END AS bit) AS IsYearStart,
        CAST(CASE WHEN s.[Month] = 12 AND s.FullDate = EOMONTH(s.FullDate) THEN 1 ELSE 0 END AS bit) AS IsYearEnd,

        CASE WHEN s.IsWeekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS DayType
    FROM src s
    WHERE s.FullDate IS NOT NULL
),
rel AS
(
    SELECT
        c.*,
        DATEDIFF(day,  CAST(GETDATE() AS date), c.FullDate) AS DayOffsetFromToday,

        (DATEDIFF(year, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1), DATEFROMPARTS(c.[Year], c.[Month], 1)) * 12)
        + DATEDIFF(month, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1), DATEFROMPARTS(c.[Year], c.[Month], 1))
        AS MonthOffsetFromCurrent,

        DATEDIFF(year, CAST(GETDATE() AS date), c.FullDate) AS YearOffsetFromCurrent,

        CAST(CASE WHEN c.[Year] = YEAR(GETDATE()) AND c.[Month] = MONTH(GETDATE()) THEN 1 ELSE 0 END AS bit) AS IsCurrentMonth,
        CAST(CASE WHEN c.[Year] = YEAR(DATEADD(month,-1,GETDATE())) AND c.[Month] = MONTH(DATEADD(month,-1,GETDATE())) THEN 1 ELSE 0 END AS bit) AS IsLastMonth,
        CAST(CASE WHEN c.[Year] = YEAR(GETDATE()) AND c.FullDate <= CAST(GETDATE() AS date) THEN 1 ELSE 0 END AS bit) AS IsYTD
    FROM calcs c
)
INSERT INTO silver.dim_date
SELECT
    DateKey, FullDate,
    [Year], [Quarter], [Month], MonthName, [Day],
    DayOfWeek, DayName, IsWeekend, WeekOfYear,
    YearMonthInt, YearMonthLabel, MonthYearLabel, YearQuarterLabel,
    IsWeekday, IsMonthStart, IsMonthEnd, IsQuarterStart, IsQuarterEnd, IsYearStart, IsYearEnd,
    DayType,
    DayOffsetFromToday, MonthOffsetFromCurrent, YearOffsetFromCurrent,
    IsCurrentMonth, IsLastMonth, IsYTD
FROM rel;
GO

ALTER TABLE silver.dim_date
ADD CONSTRAINT PK_silver_dim_date PRIMARY KEY (DateKey);
GO

CREATE INDEX IX_silver_dim_date_FullDate ON silver.dim_date(FullDate);
GO
