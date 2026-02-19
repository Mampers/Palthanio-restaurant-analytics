/*
Bronze RAW: dim_date_raw
Purpose: Persisted bronze table with lineage + load timestamp.
Loads data from bronze.dim_date_stage.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.dim_date_raw;
GO

CREATE TABLE bronze.dim_date_raw (
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
    WeekOfYear  VARCHAR(10) NULL,
    SourceSystem VARCHAR(50)  NULL,
    SourceFile   VARCHAR(260) NULL,
    LoadDts      DATETIME2(0) NOT NULL
);
GO

ALTER TABLE bronze.dim_date_raw
ADD CONSTRAINT DF_bronze_dim_date_raw_LoadDts
DEFAULT (SYSDATETIME()) FOR LoadDts;
GO

-- Insert STAGE -> RAW (minimal transformation only)
INSERT INTO bronze.dim_date_raw (
    DateKey,
    FullDate,
    [Year],
    [Quarter],
    [Month],
    MonthName,
    [Day],
    DayOfWeek,
    DayName,
    IsWeekend,
    WeekOfYear,
    SourceSystem,
    SourceFile
)
SELECT
    LTRIM(RTRIM(DateKey))    AS DateKey,
    LTRIM(RTRIM(FullDate))   AS FullDate,
    LTRIM(RTRIM([Year]))     AS [Year],
    LTRIM(RTRIM([Quarter]))  AS [Quarter],
    LTRIM(RTRIM([Month]))    AS [Month],
    LTRIM(RTRIM(MonthName))  AS MonthName,
    LTRIM(RTRIM([Day]))      AS [Day],
    LTRIM(RTRIM(DayOfWeek))  AS DayOfWeek,
    LTRIM(RTRIM(DayName))    AS DayName,
    LTRIM(RTRIM(IsWeekend))  AS IsWeekend,
    LTRIM(RTRIM(WeekOfYear)) AS WeekOfYear,
    'mdm'                    AS SourceSystem,
    'dim_date.csv'           AS SourceFile
FROM bronze.dim_date_stage;
GO

