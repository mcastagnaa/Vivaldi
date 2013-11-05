USE RM_PTFL
GO

IF  EXISTS (SELECT * FROM dbo.sysusers WHERE name = 'OMAM\MargaretA')
EXEC dbo.sp_revokedbaccess 'OMAM\MargaretA'
GO

IF  EXISTS (SELECT * FROM dbo.sysusers WHERE name = 'OMAM\StephaneD')
EXEC dbo.sp_revokedbaccess 'OMAM\StephaneD'
GO

EXEC dbo.sp_grantdbaccess 'OMAM\MargaretA', 'OMAM\MargaretA'
EXEC sp_addrolemember 'db_datareader', 'OMAM\MargaretA'
EXEC sp_addrolemember 'db_datawriter', 'EU\Middle Office Europe'

EXEC dbo.sp_grantdbaccess 'EU\Qualitative Analysis', 'EU\Qualitative Analysis'
EXEC sp_addrolemember 'db_datareader', 'EU\Qualitative Analysis'
EXEC sp_addrolemember 'db_datawriter', 'EU\Qualitative Analysis'
GO