USE [PalthanioRestaurants]
GO

/****** Object:  Table [bronze].[dim_category_raw]    Script Date: 19/02/2026 13:48:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bronze].[dim_category_raw](
	[CategoryKey] [varchar](20) NULL,
	[CategoryName] [varchar](255) NULL,
	[Department] [varchar](100) NULL,
	[SourceSystem] [varchar](50) NULL,
	[SourceFile] [varchar](260) NULL,
	[LoadDts] [datetime2](0) NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [bronze].[dim_category_raw] ADD  CONSTRAINT [DF_bronze_dim_category_raw_LoadDts]  DEFAULT (sysdatetime()) FOR [LoadDts]
GO
