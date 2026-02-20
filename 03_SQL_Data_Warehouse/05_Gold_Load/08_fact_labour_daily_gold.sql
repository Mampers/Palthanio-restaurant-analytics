/* ============================================================
   SILVER -> GOLD : fact_labour_daily
   Source : silver.fact_labor_costs
   Target : gold.fact_labour_daily

   Grain:
   - DateKey x StoreKey (daily per store)

   Measures:
   - ShiftsWorked (count rows)
   - TotalHours, TotalLabourCost
   - AvgHourlyRate (weighted)
   - Role cost splits
   - CostPerHour
   - PayrollVarianceAbs (abs sum of variances)
   - IsHighStaffedDay (threshold flag)
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
IF OBJECT_ID('gold.fact_labour_daily','U') IS NOT NULL
    DROP TABLE gold.fact_labour_daily;
GO

CREATE TABLE gold.fact_labour_daily
(
    DateKey             int             NULL,
    StoreKey            varchar(10)     NULL,

    ShiftsWorked        int             NULL,
    TotalHours          decimal(38,2)   NULL,
    TotalLabourCost     decimal(38,2)   NULL,
    AvgHourlyRate       decimal(38,6)   NULL,

    BaristaCost         decimal(38,2)   NULL,
    KitchenCost         decimal(38,2)   NULL,
    ManagerCost         decimal(38,2)   NULL,
    CleanerCost         decimal(38,2)   NULL,

    CostPerHour         decimal(38,6)   NULL,
    PayrollVarianceAbs  decimal(38,2)   NULL,

    IsHighStaffedDay    int             NOT NULL
);
GO

------------------------------------------------------------
-- 2) Aggregate from silver.fact_labor_costs
------------------------------------------------------------
;WITH base AS
(
    SELECT
        TRY_CONVERT(int, DateKey) AS DateKey,
        NULLIF(LTRIM(RTRIM(StoreCode)), '') AS StoreKey,
        NULLIF(LTRIM(RTRIM(Role)), '') AS Role,

        TRY_CONVERT(decimal(18,4), HoursWorked) AS HoursWorked,
        TRY_CONVERT(decimal(18,4), HourlyRate)  AS HourlyRate,
        TRY_CONVERT(decimal(18,4), LabourCost)  AS LabourCost,

        -- If your Silver table has these, great; otherwise they’ll be NULL.
        TRY_CONVERT(decimal(18,4), CalcLabourCost)       AS CalcLabourCost,
        TRY_CONVERT(decimal(18,4), LabourCostVariance)   AS LabourCostVariance
    FROM silver.fact_labor_costs
),
agg AS
(
    SELECT
        b.DateKey,
        b.StoreKey,

        COUNT(*) AS ShiftsWorked,

        CAST(SUM(ISNULL(b.HoursWorked, 0)) AS decimal(38,2)) AS TotalHours,
        CAST(SUM(ISNULL(b.LabourCost, 0))  AS decimal(38,2)) AS TotalLabourCost,

        -- Weighted avg rate = total cost / total hours
        CAST(
            CASE
                WHEN SUM(ISNULL(b.HoursWorked, 0)) = 0 THEN NULL
                ELSE SUM(ISNULL(b.LabourCost, 0)) / NULLIF(SUM(ISNULL(b.HoursWorked, 0)), 0)
            END
        AS decimal(38,6)) AS AvgHourlyRate,

        -- Role splits (adjust role matching to your values)
        CAST(SUM(CASE WHEN UPPER(b.Role) LIKE '%BARISTA%' THEN ISNULL(b.LabourCost,0) ELSE 0 END) AS decimal(38,2)) AS BaristaCost,
        CAST(SUM(CASE WHEN UPPER(b.Role) LIKE '%KITCHEN%' OR UPPER(b.Role) LIKE '%CHEF%' THEN ISNULL(b.LabourCost,0) ELSE 0 END) AS decimal(38,2)) AS KitchenCost,
        CAST(SUM(CASE WHEN UPPER(b.Role) LIKE '%MANAGER%' THEN ISNULL(b.LabourCost,0) ELSE 0 END) AS decimal(38,2)) AS ManagerCost,
        CAST(SUM(CASE WHEN UPPER(b.Role) LIKE '%CLEAN%' THEN ISNULL(b.LabourCost,0) ELSE 0 END) AS decimal(38,2)) AS CleanerCost,

        -- Cost per hour (same as weighted rate)
        CAST(
            CASE
                WHEN SUM(ISNULL(b.HoursWorked, 0)) = 0 THEN NULL
                ELSE SUM(ISNULL(b.LabourCost, 0)) / NULLIF(SUM(ISNULL(b.HoursWorked, 0)), 0)
            END
        AS decimal(38,6)) AS CostPerHour,

        -- Payroll variance absolute (if variance exists)
        CAST(SUM(ABS(ISNULL(b.LabourCostVariance, 0))) AS decimal(38,2)) AS PayrollVarianceAbs

    FROM base b
    WHERE b.DateKey IS NOT NULL
      AND b.StoreKey IS NOT NULL
    GROUP BY
        b.DateKey,
        b.StoreKey
)
INSERT INTO gold.fact_labour_daily
(
    DateKey,
    StoreKey,
    ShiftsWorked,
    TotalHours,
    TotalLabourCost,
    AvgHourlyRate,
    BaristaCost,
    KitchenCost,
    ManagerCost,
    CleanerCost,
    CostPerHour,
    PayrollVarianceAbs,
    IsHighStaffedDay
)
SELECT
    a.DateKey,
    a.StoreKey,
    a.ShiftsWorked,
    a.TotalHours,
    a.TotalLabourCost,
    a.AvgHourlyRate,
    a.BaristaCost,
    a.KitchenCost,
    a.ManagerCost,
    a.CleanerCost,
    a.CostPerHour,
    a.PayrollVarianceAbs,

    -- High staffed day rule (tweak thresholds)
    CASE
        WHEN a.TotalHours >= 80 THEN 1
        ELSE 0
    END AS IsHighStaffedDay
FROM agg a;
GO

------------------------------------------------------------
-- 3) Helpful indexes
------------------------------------------------------------
CREATE INDEX IX_gold_fact_labour_daily_DateStore
ON gold.fact_labour_daily(DateKey, StoreKey);
GO

-- Spot check (optional)
-- SELECT TOP (50) * FROM gold.fact_labour_daily ORDER BY DateKey DESC, StoreKey;

