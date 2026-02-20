
/* ============================================================
   SILVER -> GOLD : 05_dim_channel
   Source : silver.dim_channel_paymentmethod
   Target : gold.05_dim_channel

   Purpose:
   - Business-ready channel dimension
   - De-duplicates channel values
   - Standardises naming
   - Adds IsActive flag
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
IF OBJECT_ID('gold.05_dim_channel','U') IS NOT NULL
    DROP TABLE gold.05_dim_channel;
GO

CREATE TABLE gold.05_dim_channel
(
    ChannelCode nvarchar(100) NOT NULL,
    ChannelName nvarchar(100) NOT NULL,
    IsActive    bit           NOT NULL,
    CONSTRAINT PK_gold_dim_channel PRIMARY KEY (ChannelCode)
);
GO

------------------------------------------------------------
-- 2) Insert distinct channels from Silver
------------------------------------------------------------
INSERT INTO gold.05_dim_channel
(
    ChannelCode,
    ChannelName,
    IsActive
)
SELECT DISTINCT
    UPPER(LTRIM(RTRIM(Channel))) AS ChannelCode,

    --------------------------------------------------------
    -- Friendly Business Label
    --------------------------------------------------------
    CASE 
        WHEN UPPER(Channel) IN ('UBER','UBEREATS') THEN 'Uber Eats'
        WHEN UPPER(Channel) IN ('JUSTEAT') THEN 'Just Eat'
        WHEN UPPER(Channel) IN ('DELIVEROO') THEN 'Deliveroo'
        WHEN UPPER(Channel) IN ('INSTORE','IN-STORE') THEN 'In Store'
        WHEN UPPER(Channel) IN ('DRIVE THRU','DRIVETHRU') THEN 'Drive Thru'
        ELSE LTRIM(RTRIM(Channel))
    END AS ChannelName,

    --------------------------------------------------------
    -- IsActive (all current channels assumed active)
    --------------------------------------------------------
    CAST(1 AS bit) AS IsActive

FROM silver.dim_channel_paymentmethod
WHERE Channel IS NOT NULL;
GO

------------------------------------------------------------
-- 3) Optional: helpful index
------------------------------------------------------------
CREATE INDEX IX_gold_dim_channel_Name
ON gold.05_dim_channel(ChannelName);
GO
