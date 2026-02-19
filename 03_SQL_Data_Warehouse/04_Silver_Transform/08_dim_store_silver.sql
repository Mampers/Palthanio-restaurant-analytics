/* SILVER: dim_store */

USE [PalthanioRestaurants];
GO
SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver;');
GO

IF OBJECT_ID('silver.dim_store','U') IS NOT NULL
    DROP TABLE silver.dim_store;
GO

CREATE TABLE silver.dim_store
(
    StoreKey       varchar(10)  NOT NULL,
    StoreName      varchar(50)  NULL,
    City           varchar(100) NULL,
    Region         varchar(50)  NULL,
    StoreType      varchar(50)  NULL,

    OpenDate       date         NULL,
    OpenDateKey    int          NULL,

    SquareFeet     int          NULL,
    Seats          int          NULL,

    StoreAgeDays   int          NULL,
    StoreSizeBand  varchar(20)  NULL
);
GO

INSERT INTO silver.dim_store
SELECT
    b.StoreKey,
    b.StoreName,
    b.City,
    b.Region,

    b.OpenDate AS StoreType,

    TRY_CONVERT(date, LEFT(b.SquareFeet, CHARINDEX(',', b.SquareFeet) - 1), 103) AS OpenDate,

    CONVERT(int, FORMAT(
        TRY_CONVERT(date, LEFT(b.SquareFeet, CHARINDEX(',', b.SquareFeet) - 1), 103),
        'yyyyMMdd'
    )) AS OpenDateKey,

    TRY_CONVERT(int,
        SUBSTRING(
            b.SquareFeet,
            CHARINDEX(',', b.SquareFeet) + 1,
            CHARINDEX(',', b.SquareFeet, CHARINDEX(',', b.SquareFeet)+1)
            - CHARINDEX(',', b.SquareFeet) - 1
        )
    ) AS SquareFeet,

    TRY_CONVERT(int,
        SUBSTRING(
            b.SquareFeet,
            CHARINDEX(',', b.SquareFeet, CHARINDEX(',', b.SquareFeet)+1) + 1,
            10
        )
    ) AS Seats,

    DATEDIFF(
        DAY,
        TRY_CONVERT(date, LEFT(b.SquareFeet, CHARINDEX(',', b.SquareFeet) - 1), 103),
        GETDATE()
    ) AS StoreAgeDays,

    CASE
        WHEN TRY_CONVERT(int,
            SUBSTRING(
                b.SquareFeet,
                CHARINDEX(',', b.SquareFeet) + 1,
                CHARINDEX(',', b.SquareFeet, CHARINDEX(',', b.SquareFeet)+1)
                - CHARINDEX(',', b.SquareFeet) - 1
            )
        ) < 150 THEN 'Small'
        WHEN TRY_CONVERT(int,
            SUBSTRING(
                b.SquareFeet,
                CHARINDEX(',', b.SquareFeet) + 1,
                CHARINDEX(',', b.SquareFeet, CHARINDEX(',', b.SquareFeet)+1)
                - CHARINDEX(',', b.SquareFeet) - 1
            )
        ) < 220 THEN 'Medium'
        ELSE 'Large'
    END AS StoreSizeBand
FROM bronze.dim_store_stage b;
GO

