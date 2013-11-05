USE VIVALDI

ALTER TABLE dbo.TmpFundRiskDetails 
ALTER COLUMN FundId int not NULL

ALTER TABLE dbo.TmpFundRiskDetails 
ALTER COLUMN SecurityGroup nvarchar(30) not NULL

ALTER TABLE dbo.TmpFundRiskDetails 
ALTER COLUMN BMISCode nvarchar(30) not NULL
GO

ALTER TABLE dbo.TmpFundRiskDetails 
ADD CONSTRAINT TmpFundRiskDetails_PK PRIMARY KEY NONCLUSTERED 
(
	FundId ASC,
	SecurityGroup ASC,
	BMISCode ASC
)



