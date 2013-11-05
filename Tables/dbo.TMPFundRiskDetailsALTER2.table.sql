USE VIVALDI

ALTER TABLE dbo.TmpFundRiskDetails 
ALTER COLUMN DetsDate datetime not NULL

ALTER TABLE dbo.TmpFundRiskDetails 
DROP CONSTRAINT TmpFundRiskDetails_PK

ALTER TABLE dbo.TmpFundRiskDetails 
ADD CONSTRAINT TmpFundRiskDetails_PK PRIMARY KEY NONCLUSTERED 
(
	FundId ASC,
	SecurityGroup ASC,
	BMISCode ASC,
	DetsDate ASC
)


