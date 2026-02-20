/* ============================================================
   SILVER -> GOLD : 02_dim_store
   Source : silver.dim_store
   Target : gold.02_dim_store

   Purpose:
   - Business-ready Store dimension
   - Minimal presentation layer structure
   - Derives IsActive flag
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
IF OBJECT_ID('gold.02_dim_store','U') IS NOT NULL
    DROP TABLE gold.02_dim_store;
GO

CREATE TABLE gold.02_dim_store
(
    StoreKey    nvarchar(50)  NOT NULL,
    StoreName   nvarchar(100) NULL,
    IsActive    bit           NOT NULL,

    CONSTRAINT PK_02_dim_store PRIMARY KEY CLUSTERED (StoreKey)
);
GO

------------------------------------------------------------
-- 2) Insert from SILVER
------------------------------------------------------------
INSERT INTO gold.02_dim_store
(
    StoreKey,
    StoreName,
    IsActive
)
SELECT
    StoreKey,
    StoreName,

    -- Business Logic for IsActive:
    -- Active if OpenDate is not null and not in future
    CASE
        WHEN OpenDate IS NULL THEN 0
        WHEN OpenDate > CAST(GETDATE() AS date) THEN 0
        ELSE 1
    END AS IsActive

FROM silver.dim_store;
GO

------------------------------------------------------------
-- 3) Optional index (useful in joins)
------------------------------------------------------------
CREATE INDEX IX_02_dim_store_StoreName
ON gold.02_dim_store(StoreName);
GO

