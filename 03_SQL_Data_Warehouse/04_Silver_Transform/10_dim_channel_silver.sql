USE [PalthanioRestaurants];
GO

/* ============================================================
   BRONZE -> SILVER : dim_channel_paymentmethod
   Source : bronze.dim_channel_paymentmethod_raw
   Target : silver.dim_channel_paymentmethod

   Cleans:
   - trims whitespace
   - standardises casing
   - removes SourceSystem / LoadDts
   - deduplicates rows

   Adds:
   - ChannelPaymentKey (surrogate key)
   ============================================================ */

SET NOCOUNT ON;

------------------------------------------------------------
-- 0) Ensure schema exists
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver;');

------------------------------------------------------------
-- 1) Drop + recreate (safe for reruns)
------------------------------------------------------------
IF OBJECT_ID('silver.dim_channel_paymentmethod', 'U') IS NOT NULL
    DROP TABLE silver.dim_channel_paymentmethod;

CREATE TABLE silver.dim_channel_paymentmethod
(
    ChannelPaymentKey int IDENTITY(1,1) PRIMARY KEY,
    Channel           varchar(50) NOT NULL,
    PaymentMethod     varchar(50) NOT NULL
);

------------------------------------------------------------
-- 2) Insert cleaned + deduplicated data
------------------------------------------------------------
INSERT INTO silver.dim_channel_paymentmethod
(
    Channel,
    PaymentMethod
)
SELECT DISTINCT
    -- Standardise Channel
    CASE 
        WHEN UPPER(LTRIM(RTRIM(Channel))) = 'INSTORE' THEN 'InStore'
        WHEN UPPER(LTRIM(RTRIM(Channel))) = 'DELIVERY' THEN 'Delivery'
        WHEN UPPER(LTRIM(RTRIM(Channel))) = 'CLICK & COLLECT' THEN 'Click & Collect'
        ELSE LTRIM(RTRIM(Channel))
    END AS Channel,

    -- Standardise PaymentMethod
    CASE 
        WHEN UPPER(LTRIM(RTRIM(PaymentMethod))) = 'CARD' THEN 'Card'
        WHEN UPPER(LTRIM(RTRIM(PaymentMethod))) = 'CASH' THEN 'Cash'
        WHEN UPPER(LTRIM(RTRIM(PaymentMethod))) = 'APPLE PAY' THEN 'Apple Pay'
        WHEN UPPER(LTRIM(RTRIM(PaymentMethod))) = 'GOOGLE PAY' THEN 'Google Pay'
        ELSE LTRIM(RTRIM(PaymentMethod))
    END AS PaymentMethod

FROM bronze.dim_channel_paymentmethod_raw
WHERE Channel IS NOT NULL
  AND PaymentMethod IS NOT NULL;

------------------------------------------------------------
-- 3) Helpful index for joins
------------------------------------------------------------
CREATE UNIQUE INDEX UX_silver_dim_channel_paymentmethod
ON silver.dim_channel_paymentmethod(Channel, PaymentMethod);
GO

-- Spot check
-- SELECT * FROM silver.dim_channel_paymentmethod;

