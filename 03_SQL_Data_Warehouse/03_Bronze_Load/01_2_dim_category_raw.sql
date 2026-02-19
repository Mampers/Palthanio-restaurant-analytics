/*
Bronze RAW: dim_category_raw
Purpose: Persisted bronze table with lineage + load timestamp.
Loads data from bronze.dim_category_stage.
*/

USE [PalthanioRestaurants];
GO

DROP TABLE IF EXISTS bronze.dim_category_raw;
GO

CREATE TABLE bronze.dim_category_raw (
    CategoryKey   VARCHAR(20)  NULL,
    CategoryName  VARCHAR(255) NULL,
    Department    VARCHAR(100) NULL,
    SourceSystem  VARCHAR(50)  NULL,
    SourceFile    VARCHAR(260) NULL,
    LoadDts       DATETIME2(0) NOT NULL
);
GO

ALTER TABLE bronze.dim_category_raw
ADD CONSTRAINT DF_bronze_dim_category_raw_LoadDts
DEFAULT (SYSDATETIME()) FOR LoadDts;
GO

-- Insert STAGE -> RAW (minimal transformation only)
INSERT INTO bronze.dim_category_raw (
    CategoryKey,
    CategoryName,
    Department,
    SourceSystem,
    SourceFile
)
SELECT
    LTRIM(RTRIM(CategoryKey))  AS CategoryKey,
    LTRIM(RTRIM(CategoryName)) AS CategoryName,
    LTRIM(RTRIM(Department))   AS Department,
    'mdm'                      AS SourceSystem,
    'dim_category.csv'         AS SourceFile
FROM bronze.dim_category_stage;
GO

