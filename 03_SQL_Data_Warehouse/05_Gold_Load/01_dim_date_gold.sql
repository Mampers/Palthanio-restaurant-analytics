/* ============================================================
   SILVER -> GOLD : 01_dim_date
   Source : silver.dim_date
   Target : gold.01_dim_date

   Purpose:
   - Presentation-ready Date dimension
   - Clean naming
   - Minimal business-friendly columns
   ============================================================ */

SET NOCOUNT ON;

------------------------------------------------------------
-- 0) Ensure schema exists
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold;');
GO

------------------------------------------------------------
-- 1) Drop + recreate (safe for reruns)
------------------------------------------------------------
IF OBJECT_ID('gold.01_dim_date','U') IS NOT NULL
    DROP TABLE gold.01_dim_date;
GO

CREATE TABLE gold.01_dim_date
(
    DateKey     int           NOT NULL,
    [Date]      date          NOT NULL,
    [Year]      smallint      NOT NULL,
    MonthNo     tinyint       NOT NULL,
    DayNo       tinyint       NOT NULL,
    MonthName   nvarchar(20)  NOT NULL,
    DayName     nvarchar(20)  NOT NULL,

    CONSTRAINT PK_01_dim_date PRIMARY KEY CLUSTERED (DateKey)
);
GO

------------------------------------------------------------
-- 2) Insert from SILVER
------------------------------------------------------------
INSERT INTO gold.01_dim_date
(
    DateKey,
    [Date],
    [Year],
    MonthNo,
    DayNo,
    MonthName,
    DayName
)
SELECT
    DateKey,
    FullDate         AS [Date],
    [Year],
    [Month]          AS MonthNo,
    [Day]            AS DayNo,
    MonthName,
    DayName
FROM silver.dim_date;
GO

------------------------------------------------------------
-- 3) Optional index (useful for filtering by Date)
------------------------------------------------------------
CREATE INDEX IX_01_dim_date_Date
ON gold.01_dim_date([Date]);
GO

