/*
Bronze RAW: fact_labor_costs_raw
Purpose: Persisted bronze table with lineage + load timestamp.
Loads data from bronze.fact_labor_costs_stage.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.fact_labor_costs_raw;
GO

CREATE TABLE bronze.fact_labor_costs_raw (
    LabourID     VARCHAR(20)    NULL,
    DateKey      INT            NULL,
    StoreKey     INT            NULL,
    NewStoreKEy  VARCHAR(20)    NULL,
    [Role]       VARCHAR(100)   NULL,
    HoursWorked  DECIMAL(10,2)  NULL,
    HourlyRate   DECIMAL(10,2)  NULL,
    LabourCost   DECIMAL(12,2)  NULL,
    SourceSystem VARCHAR(50)    NULL,
    SourceFile   VARCHAR(260)   NULL,
    LoadDts      DATETIME2(0)   NOT NULL
);
GO

ALTER TABLE bronze.fact_labor_costs_raw
ADD CONSTRAINT DF_fact_labor_costs_raw_LoadDts
DEFAULT (SYSDATETIME()) FOR LoadDts;
GO

-- Insert STAGE -> RAW (minimal casting only)
INSERT INTO bronze.fact_labor_costs_raw (
    LabourID,
    DateKey,
    StoreKey,
    NewStoreKEy,
    [Role],
    HoursWorked,
    HourlyRate,
    LabourCost,
    SourceSystem,
    SourceFile
)
SELECT
    LTRIM(RTRIM(LabourID)),
    TRY_CONVERT(INT, LTRIM(RTRIM(DateKey))),
    TRY_CONVERT(INT, LTRIM(RTRIM(StoreKey))),
    LTRIM(RTRIM(NewStoreKEy)),
    LTRIM(RTRIM([Role])),
    TRY_CONVERT(DECIMAL(10,2), LTRIM(RTRIM(HoursWorked))),
    TRY_CONVERT(DECIMAL(10,2), LTRIM(RTRIM(HourlyRate))),
    TRY_CONVERT(DECIMAL(12,2), LTRIM(RTRIM(LabourCost))),
    'ops',
    'fact_labor_costs.csv'
FROM bronze.fact_labor_costs_stage;
GO

