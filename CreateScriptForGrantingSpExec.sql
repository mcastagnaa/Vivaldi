USE RM_PTFL
GO

SELECT	'GRANT EXECUTE ON ' + name + ' TO [OMAM\StephaneD], [OMAM\MargaretA]' 
FROM 	sysobjects 
WHERE	type = 'P' AND (LEFT(name,3) = 'spS' OR LEFT(name,3) = 'spU')

