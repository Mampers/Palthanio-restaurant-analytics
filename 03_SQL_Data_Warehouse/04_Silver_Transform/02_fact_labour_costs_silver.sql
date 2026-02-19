/*
SILVER: fact_labor_costs
- Cleans and types bronze.fact_labor_costs_raw
- Derives CalcLabourCost, variance metrics, EffectiveHourlyRate
*/

USE [PalthanioRestaurants];
GO
SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver;');
GO

IF OBJECT_ID('silver.fact_labor_costs','U') IS NOT NULL
    DROP TABLE silver.fact_labor_costs;
GO

SELECT
    LTRIM(RTRIM(b.LabourID)) AS LabourID,
    TRY_CONVERT(int, b.DateKey) AS DateKey,
    COALESCE(
        NULLIF(LTRIM(RTRIM(TRY_CONVERT(varchar(10), b.NewStoreKey))), ''),
        NULLIF(LTRIM(RTRIM(TRY_CONVERT(varchar(10), b.StoreKey))),  '')
    ) AS StoreCode,
    LTRIM(RTRIM(b.Role)) AS Role,

    TRY_CONVERT(decimal(10,2), b.HoursWorked) AS HoursWorked,
    TRY_CONVERT(decimal(10,2), b.HourlyRate)  AS HourlyRate,
    TRY_CONVERT(decimal(12,2), b.LabourCost)  AS LabourCost,

    TRY_CONVERT(decimal(12,2),
        TRY_CONVERT(decimal(10,4), b.HoursWorked) * TRY_CONVERT(decimal(10,4), b.HourlyRate)
    ) AS CalcLabourCost,

    TRY_CONVERT(decimal(12,2),
        TRY_CONVERT(decimal(12,4), b.LabourCost)
        -
        (TRY_CONVERT(decimal(10,4), b.HoursWorked) * TRY_CONVERT(decimal(10,4), b.HourlyRate))
    ) AS LabourCostVariance,

    CASE
        WHEN TRY_CONVERT(decimal(12,4), b.LabourCost) IS NULL OR TRY_CONVERT(decimal(12,4), b.LabourCost) = 0
            THEN NULL
        ELSE
            TRY_CONVERT(decimal(10,4),
                (
                    TRY_CONVERT(decimal(12,4), b.LabourCost)
                    -
                    (TRY_CONVERT(decimal(10,4), b.HoursWorked) * TRY_CONVERT(decimal(10,4), b.HourlyRate))
                )
                / TRY_CONVERT(decimal(12,4), b.LabourCost)
            )
    END AS LabourCostVariancePct,

    CASE
        WHEN TRY_CONVERT(decimal(10,4), b.HoursWorked) IS NULL OR TRY_CONVERT(decimal(10,4), b.HoursWorked) = 0
            THEN NULL
        ELSE
            TRY_CONVERT(decimal(10,2),
                TRY_CONVERT(decimal(12,4), b.LabourCost) / TRY_CONVERT(decimal(10,4), b.HoursWorked)
            )
    END AS EffectiveHourlyRate

INTO silver.fact_labor_costs
FROM bronze.fact_labor_costs_raw b;
GO

