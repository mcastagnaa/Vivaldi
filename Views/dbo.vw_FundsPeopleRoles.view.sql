USE RM_PTFL
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_FundsPeopleRoles]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_FundsPeopleRoles]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_FundsPeopleRoles]
AS

SELECT 	Funds.Id AS FundId	
	, Funds.FundCode
	, People.Name
	, People.Surname
	, People.ShortCode AS PeopleCode
	, People.eMail As eMail
	, People.extension As PhoneExtension
	, Roles.ShortName AS RoleCode
	, Roles.LongName AS Role
	, People.Id AS PeopleId
	, Roles.Id As RoleId

	
FROM 	tbl_funds AS Funds RIGHT JOIN
	tbl_fundsPeopleRoles AS MtM ON (
		Funds.Id = MtM.FundId
		) LEFT JOIN
	tbl_People AS People ON (
		MtM.PeopleId = People.Id
		) LEFT JOIN
	tbl_EnumRoles AS Roles ON (
		MtM.RoleId = Roles.ID
		) 
	
