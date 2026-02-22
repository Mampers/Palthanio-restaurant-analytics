/* ============================================================
   QA & Reconciliation Checks
   Palthanio Restaurant Analytics
   ============================================================ */

------------------------------------------------------------
-- 1. Bronze vs Silver Row Count Validation
------------------------------------------------------------
SELECT 'Bronze Sales' AS Layer, COUNT(*) AS RowCount
FROM bronze.sales_raw

UNION ALL

SELECT 'Silver Sales', COUNT(*)
FROM silver.fact_sales;


------------------------------------------------------------
-- 2. Silver vs Gold Row Count Validation
------------------------------------------------------------
SELECT 'Silver Sales', COUNT(*) AS RowCount
FROM silver.fact_sales

UNION ALL

SELECT 'Gold Sales', COUNT(*)
FROM gold.fact_sales;


------------------------------------------------------------
-- 3. Revenue Reconciliation (Silver vs Gold)
------------------------------------------------------------
SELECT
    'Silver' AS Layer,
    SUM(NetRevenue) AS TotalRevenue
FROM silver.fact_sales

UNION ALL

SELECT
    'Gold',
    SUM(NetRevenue)
FROM gold.fact_sales;


------------------------------------------------------------
-- 4. Orphan Foreign Key Check
------------------------------------------------------------
SELECT COUNT(*) AS MissingStoreKeys
FROM gold.fact_sales f
LEFT JOIN gold.dim_store d
    ON f.StoreKey = d.StoreKey
WHERE d.StoreKey IS NULL;


------------------------------------------------------------
-- 5. Duplicate SalesLineID Check
------------------------------------------------------------
SELECT SalesLineID, COUNT(*) AS DuplicateCount
FROM gold.fact_sales
GROUP BY SalesLineID
HAVING COUNT(*) > 1;


------------------------------------------------------------
-- 6. Null Key Validation
------------------------------------------------------------
SELECT COUNT(*) AS NullDateKeys
FROM gold.fact_sales
WHERE DateKey IS NULL;


------------------------------------------------------------
-- 7. Negative Revenue Validation
------------------------------------------------------------
SELECT COUNT(*) AS NegativeRevenueRows
FROM gold.fact_sales
WHERE NetRevenue < 0;


------------------------------------------------------------
-- 8. Labour vs Store Existence
------------------------------------------------------------
SELECT COUNT(*) AS MissingStoreInLabour
FROM gold.fact_labour_costs l
LEFT JOIN gold.dim_store s
    ON l.StoreKey = s.StoreKey
WHERE s.StoreKey IS NULL;
