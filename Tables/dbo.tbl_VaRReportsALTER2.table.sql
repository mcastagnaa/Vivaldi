USE RM_PTFL
GO

CREATE NONCLUSTERED INDEX [BBGInstrId] ON [dbo].[tbl_VaRReports] 
(
	[BBGInstrId] ASC
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDBloomberg] ON [dbo].[tbl_AssetPrices] 
(
	[IDBloomberg] ASC
) ON [PRIMARY]
GO
