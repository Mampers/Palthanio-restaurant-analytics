/* ============================================================
   SILVER -> GOLD : 06_dim_promotion
   Source : silver.dim_promotion
   Target : gold.06_dim_promotion

   Notes:
   - Uses gold.01_dim_date to convert StartDate/EndDate into keys
   - Assumes silver.dim_promotion.DiscountValue holds either:
       * a percent value (e.g., 10 = 10%) OR
       * a currency value (e.g., 2.50 = £2.50 off)
     determined by DiscountType text.
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
IF OBJECT_ID('gold.06_dim_promotion','U') IS NOT NULL
    DROP TABLE gold.06_dim_promotion;
GO

CREATE TABLE gold.06_dim_promotion
(
    PromotionKey          varchar(20)   NOT NULL,
    PromotionName         varchar(50)   NULL,
    PromotionType         varchar(100)  NULL,
    DiscountType          varchar(50)   NULL,

    StartDateKey          int           NULL,
    EndDateKey            int           NULL,

    DiscountValuePercent  decimal(10,2) NULL,
    DiscountValueAmount   decimal(10,2) NULL,

    Channel               nvarchar(128) NULL,

    PromoDurationDays     int           NULL,
    IsActive              int           NULL,

    PromoMechanic         varchar(7)    NOT NULL,   -- required
    DiscountDepthBand     varchar(6)    NOT NULL,   -- required
    ChannelGroup          nvarchar(128) NULL,

    IsBOGO                int           NOT NULL,
    IsSeasonal            int           NOT NULL,
    IsLoyalty             int           NOT NULL,

    CONSTRAINT PK_gold_dim_promotion PRIMARY KEY CLUSTERED (PromotionKey)
);
GO

------------------------------------------------------------
-- 2) Insert from Silver + derived fields
------------------------------------------------------------
;WITH src AS
(
    SELECT
        p.PromotionKey,
        p.PromotionName,
        p.PromotionType,
        p.DiscountType,
        p.DiscountValue,
        p.StartDate,
        p.EndDate,
        p.PromotionDurationDays
    FROM silver.dim_promotion p
),
date_keys AS
(
    SELECT
        s.*,
        d1.DateKey AS StartDateKey,
        d2.DateKey AS EndDateKey
    FROM src s
    LEFT JOIN gold.01_dim_date d1
        ON d1.[Date] = s.StartDate
    LEFT JOIN gold.01_dim_date d2
        ON d2.[Date] = s.EndDate
),
discount_split AS
(
    SELECT
        dk.*,

        -- Percent vs Amount split driven by DiscountType text
        CASE
            WHEN dk.DiscountValue IS NULL THEN NULL
            WHEN UPPER(ISNULL(dk.DiscountType,'')) LIKE '%PERCENT%' OR UPPER(ISNULL(dk.DiscountType,'')) LIKE '%PCT%' OR UPPER(ISNULL(dk.DiscountType,'')) LIKE '%\%%' ESCAPE '\'
                THEN dk.DiscountValue
            WHEN UPPER(ISNULL(dk.DiscountType,'')) LIKE '%AMOUNT%' OR UPPER(ISNULL(dk.DiscountType,'')) LIKE '%£%' OR UPPER(ISNULL(dk.DiscountType,'')) LIKE '%GBP%' OR UPPER(ISNULL(dk.DiscountType,'')) LIKE '%VALUE%'
                THEN NULL
            -- fallback: if value <= 1 treat as percent (0.10 = 10%) else unknown => assume percent-style
            WHEN dk.DiscountValue <= 1 THEN dk.DiscountValue * 100
            ELSE dk.DiscountValue
        END AS DiscountValuePercent,

        CASE
            WHEN dk.DiscountValue IS NULL THEN NULL
            WHEN UPPER(ISNULL(dk.DiscountType,'')) LIKE '%AMOUNT%' OR UPPER(ISNULL(dk.DiscountType,'')) LIKE '%£%' OR UPPER(ISNULL(dk.DiscountType,'')) LIKE '%GBP%' OR UPPER(ISNULL(dk.DiscountType,'')) LIKE '%VALUE%'
                THEN dk.DiscountValue
            WHEN UPPER(ISNULL(dk.DiscountType,'')) LIKE '%PERCENT%' OR UPPER(ISNULL(dk.DiscountType,'')) LIKE '%PCT%' OR UPPER(ISNULL(dk.DiscountType,'')) LIKE '%\%%' ESCAPE '\'
                THEN NULL
            ELSE NULL
        END AS DiscountValueAmount
    FROM date_keys dk
),
enriched AS
(
    SELECT
        ds.*,

        --------------------------------------------------------
        -- PromoDurationDays (prefer silver value, else compute)
        --------------------------------------------------------
        COALESCE(
            ds.PromotionDurationDays,
            CASE WHEN ds.StartDate IS NULL OR ds.EndDate IS NULL THEN NULL
                 ELSE DATEDIFF(day, ds.StartDate, ds.EndDate) + 1
            END
        ) AS PromoDurationDays,

        --------------------------------------------------------
        -- IsActive (today between start/end)
        --------------------------------------------------------
        CASE
            WHEN ds.StartDate IS NULL OR ds.EndDate IS NULL THEN 0
            WHEN CAST(GETDATE() AS date) BETWEEN ds.StartDate AND ds.EndDate THEN 1
            ELSE 0
        END AS IsActive,

        --------------------------------------------------------
        -- Channel (if you don't have it in source, keep NULL)
        --------------------------------------------------------
        CAST(NULL AS nvarchar(128)) AS Channel
    FROM discount_split ds
)
INSERT INTO gold.06_dim_promotion
(
    PromotionKey,
    PromotionName,
    PromotionType,
    DiscountType,
    StartDateKey,
    EndDateKey,
    DiscountValuePercent,
    DiscountValueAmount,
    Channel,
    PromoDurationDays,
    IsActive,
    PromoMechanic,
    DiscountDepthBand,
    ChannelGroup,
    IsBOGO,
    IsSeasonal,
    IsLoyalty
)
SELECT
    e.PromotionKey,
    LEFT(e.PromotionName, 50) AS PromotionName,  -- enforce your 50 length
    e.PromotionType,
    e.DiscountType,
    e.StartDateKey,
    e.EndDateKey,
    e.DiscountValuePercent,
    e.DiscountValueAmount,
    e.Channel,
    e.PromoDurationDays,
    e.IsActive,

    --------------------------------------------------------
    -- PromoMechanic (required, max 7)
    --------------------------------------------------------
    CASE
        WHEN UPPER(ISNULL(e.PromotionType,'')) LIKE '%BOGO%' OR UPPER(ISNULL(e.PromotionName,'')) LIKE '%BOGO%' THEN 'BOGO'
        WHEN UPPER(ISNULL(e.PromotionType,'')) LIKE '%LOYAL%' OR UPPER(ISNULL(e.PromotionName,'')) LIKE '%LOYAL%' THEN 'Loyal'
        WHEN UPPER(ISNULL(e.PromotionType,'')) LIKE '%SEASON%' OR UPPER(ISNULL(e.PromotionName,'')) LIKE '%SEASON%' THEN 'Season'
        WHEN UPPER(ISNULL(e.PromotionType,'')) LIKE '%BUNDLE%' OR UPPER(ISNULL(e.PromotionName,'')) LIKE '%BUNDLE%' THEN 'Bundle'
        WHEN e.DiscountValuePercent IS NOT NULL THEN 'Disc%'
        WHEN e.DiscountValueAmount  IS NOT NULL THEN 'Disc£'
        ELSE 'Other'
    END AS PromoMechanic,

    --------------------------------------------------------
    -- DiscountDepthBand (required, max 6)
    -- based on percent if available, else amount bands
    --------------------------------------------------------
    CASE
        WHEN e.DiscountValuePercent IS NOT NULL THEN
            CASE
                WHEN e.DiscountValuePercent < 10 THEN 'Low'
                WHEN e.DiscountValuePercent < 25 THEN 'Med'
                ELSE 'High'
            END
        WHEN e.DiscountValueAmount IS NOT NULL THEN
            CASE
                WHEN e.DiscountValueAmount < 1 THEN 'Low'
                WHEN e.DiscountValueAmount < 3 THEN 'Med'
                ELSE 'High'
            END
        ELSE 'Low'
    END AS DiscountDepthBand,

    --------------------------------------------------------
    -- ChannelGroup (if you later populate Channel)
    --------------------------------------------------------
    CASE
        WHEN e.Channel IS NULL THEN NULL
        WHEN UPPER(e.Channel) IN ('IN STORE','INSTORE') THEN 'InStore'
        WHEN UPPER(e.Channel) LIKE '%DELIVER%' THEN 'Delivery'
        ELSE 'Other'
    END AS ChannelGroup,

    --------------------------------------------------------
    -- Flags (required ints)
    --------------------------------------------------------
    CASE
        WHEN UPPER(ISNULL(e.PromotionType,'')) LIKE '%BOGO%' OR UPPER(ISNULL(e.PromotionName,'')) LIKE '%BOGO%'
            THEN 1 ELSE 0
    END AS IsBOGO,

    CASE
        WHEN UPPER(ISNULL(e.PromotionType,'')) LIKE '%SEASON%' OR UPPER(ISNULL(e.PromotionName,'')) LIKE '%SEASON%'
            THEN 1 ELSE 0
    END AS IsSeasonal,

    CASE
        WHEN UPPER(ISNULL(e.PromotionType,'')) LIKE '%LOYAL%' OR UPPER(ISNULL(e.PromotionName,'')) LIKE '%LOYAL%'
            THEN 1 ELSE 0
    END AS IsLoyalty

FROM enriched e
WHERE e.PromotionKey IS NOT NULL;
GO

------------------------------------------------------------
-- 3) Helpful index
------------------------------------------------------------
CREATE INDEX IX_gold_dim_promotion_DateKeys
ON gold.06_dim_promotion(StartDateKey, EndDateKey);
GO

