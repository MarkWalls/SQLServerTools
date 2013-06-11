/*
Unfortunatelly there is NO change tracking in SQL 2005 - it was introduced in 2008... My mistake...

So we are back to trigger option...
There are multiple automatization solutions out there, but I used one provided by Microsoft to be the best and clenest
It doesn't modify the original table, only adds three triggers ( for insert, update and delete ), but creates a table
ORGINALTABLENAME_Audit with required fields.

Procedure code is given bellow - with parameter 1 it just generates code to enable auditing, with 0 it creates the
actual objects

Test code is bellow...
I think it is the best sollution for SQL 2005 because there is no change tracking in this version :(

*/

-- Create test table for data auditing
USE [TestDbMotus]
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TestDbMotus].[dbo].[AuditTest]') AND type in (N'U'))
	DROP TABLE [TestDbMotus].[dbo].[AuditTest]
GO

CREATE TABLE [TestDbMotus].[dbo].[AuditTest]
(
	AuditTestID int PRIMARY KEY,
	AuditTestData nvarchar(50),
	AuditTestDate datetime
)
GO

-- Creating a procedure
IF OBJECT_ID('GenerateTriggers','P') IS NOT NULL
	DROP PROC GenerateTriggers
GO


CREATE PROC GenerateTriggers
 @Schemaname Sysname = 'dbo'
,@Tablename  Sysname
,@GenerateScriptOnly	bit = 1
AS

SET NOCOUNT ON

/*
Parameters
@Schemaname			- SchemaName to which the table belongs to. Default value 'dbo'.
@Tablename			- TableName for which the procs needs to be generated.
@GenerateScriptOnly - When passed 1 , this will generate the scripts alone..
					  When passed 0 , this will create the audit tables and triggers in the current database.
					  Default value is 1
*/

DECLARE @SQL VARCHAR(MAX)
DECLARE @SQLTrigger VARCHAR(MAX)
DECLARE @AuditTableName SYSNAME

SELECT @AuditTableName =  @Tablename + '_Audit'

----------------------------------------------------------------------------------------------------------------------
-- Audit Create table 
----------------------------------------------------------------------------------------------------------------------

SELECT @SQL = ' 
	IF EXISTS (SELECT 1 
		         FROM sys.objects 
		        WHERE Name=''' + @AuditTableName + '''
			      AND Schema_id=Schema_id(''' + @Schemaname + ''')
			      AND Type = ''U'')

	DROP TABLE ' + @Schemaname + '.' + @AuditTableName + '

	SELECT *
		,AuditDataState=CONVERT(VARCHAR(10),'''') 
		,AuditDMLAction=CONVERT(VARCHAR(10),'''')  
		,AuditUser =CONVERT(SYSNAME,'''')
		,AuditDateTime=CONVERT(DATETIME,''01-JAN-1900'')
		Into ' + @Schemaname + '.' + @AuditTableName + '
	FROM ' + @Schemaname + '.' + @Tablename +'
	WHERE 1=2 '

IF @GenerateScriptOnly = 1
BEGIN
	PRINT REPLICATE ('-',200)
	PRINT '--Create Script Audit table for ' + @Schemaname + '.' + @Tablename
	PRINT REPLICATE ('-',200)
	PRINT @SQL
	PRINT 'GO'
END
ELSE
BEGIN
	PRINT 'Creating Audit table for ' + @Schemaname + '.' + @Tablename
	EXEC(@SQL)
	PRINT 'Audit table ' + @Schemaname + '.' + @AuditTableName + ' Created succefully'
END


----------------------------------------------------------------------------------------------------------------------
-- Create Insert Trigger
----------------------------------------------------------------------------------------------------------------------


SELECT @SQL = '
IF EXISTS (SELECT 1 
		     FROM sys.objects 
		    WHERE Name=''' + @Tablename + '_Insert' + '''
			  AND Schema_id=Schema_id(''' + @Schemaname + ''')
			  AND Type = ''TR'')
DROP TRIGGER ' + @Tablename + '_Insert
'
SELECT @SQLTrigger = '
CREATE TRIGGER ' + @Tablename + '_Insert
ON '+ @Schemaname + '.' + @Tablename + '
FOR INSERT
AS

 INSERT INTO ' + @Schemaname + '.' + @AuditTableName + '
 SELECT *,''New'',''Insert'',SUSER_SNAME(),getdate()  FROM INSERTED 

'

IF @GenerateScriptOnly = 1
BEGIN
	PRINT REPLICATE ('-',200)
	PRINT '--Create Script Insert Trigger for ' + @Schemaname + '.' + @Tablename
	PRINT REPLICATE ('-',200)
	PRINT @SQL
	PRINT 'GO'
	PRINT @SQLTrigger
	PRINT 'GO'
END
ELSE
BEGIN
	PRINT 'Creating Insert Trigger ' + @Tablename + '_Insert  for ' + @Schemaname + '.' + @Tablename
	EXEC(@SQL)
	EXEC(@SQLTrigger)
	PRINT 'Trigger ' + @Schemaname + '.' + @Tablename + '_Insert  Created succefully'
END


----------------------------------------------------------------------------------------------------------------------
-- Create Delete Trigger
----------------------------------------------------------------------------------------------------------------------


SELECT @SQL = '

IF EXISTS (SELECT 1 
		     FROM sys.objects 
		    WHERE Name=''' + @Tablename + '_Delete' + '''
			  AND Schema_id=Schema_id(''' + @Schemaname + ''')
			  AND Type = ''TR'')
DROP TRIGGER ' + @Tablename + '_Delete
'

SELECT @SQLTrigger = 
'
CREATE TRIGGER ' + @Tablename + '_Delete
ON '+ @Schemaname + '.' + @Tablename + '
FOR DELETE
AS

 INSERT INTO ' + @Schemaname + '.' + @AuditTableName + '
 SELECT *,''Old'',''Delete'',SUSER_SNAME(),getdate()  FROM DELETED 
'

IF @GenerateScriptOnly = 1
BEGIN
	PRINT REPLICATE ('-',200)
	PRINT '--Create Script Delete Trigger for ' + @Schemaname + '.' + @Tablename
	PRINT REPLICATE ('-',200)
	PRINT @SQL
	PRINT 'GO'
	PRINT @SQLTrigger
	PRINT 'GO'
END
ELSE
BEGIN
	PRINT 'Creating Delete Trigger ' + @Tablename + '_Delete  for ' + @Schemaname + '.' + @Tablename
	EXEC(@SQL)
	EXEC(@SQLTrigger)
	PRINT 'Trigger ' + @Schemaname + '.' + @Tablename + '_Delete  Created succefully'
END

----------------------------------------------------------------------------------------------------------------------
-- Create Update Trigger
----------------------------------------------------------------------------------------------------------------------


SELECT @SQL = '

IF EXISTS (SELECT 1 
		     FROM sys.objects 
		    WHERE Name=''' + @Tablename + '_Update' + '''
			  AND Schema_id=Schema_id(''' + @Schemaname + ''')
			  AND Type = ''TR'')
DROP TRIGGER ' + @Tablename + '_Update
'

SELECT @SQLTrigger =
'
CREATE TRIGGER ' + @Tablename + '_Update
ON '+ @Schemaname + '.' + @Tablename + '
FOR UPDATE
AS

 INSERT INTO ' + @Schemaname + '.' + @AuditTableName + '
 SELECT *,''New'',''Update'',SUSER_SNAME(),getdate()  FROM INSERTED 

 INSERT INTO ' + @Schemaname + '.' + @AuditTableName + '
 SELECT *,''Old'',''Update'',SUSER_SNAME(),getdate()  FROM DELETED 
 '

IF @GenerateScriptOnly = 1
BEGIN
	PRINT REPLICATE ('-',200)
	PRINT '--Create Script Update Trigger for ' + @Schemaname + '.' + @Tablename
	PRINT REPLICATE ('-',200)
	PRINT @SQL
	PRINT 'GO'
	PRINT @SQLTrigger
	PRINT 'GO'
END
ELSE
BEGIN
	PRINT 'Creating Delete Trigger ' + @Tablename + '_Update  for ' + @Schemaname + '.' + @Tablename
	EXEC(@SQL)
	EXEC(@SQLTrigger)
	PRINT 'Trigger ' + @Schemaname + '.' + @Tablename + '_Update  Created succefully'
END

SET NOCOUNT OFF
GO

-- Test for AuditTest table

-- Generate script only
EXEC GenerateTriggers 'dbo', 'AuditTest', 1
-- Generate objects
EXEC GenerateTriggers 'dbo', 'AuditTest', 0

-- Test on data changes
USE [TestDbMotus]
TRUNCATE TABLE AuditTest

INSERT INTO AuditTest VALUES ( 1, 'First', GETDATE() )
INSERT INTO AuditTest VALUES ( 2, 'Second', GETDATE() )

SELECT * FROM AuditTest_Audit

UPDATE AuditTest SET AuditTestData = 'Third', AuditTestDate = GETDATE()+1 WHERE AuditTestID = 1
UPDATE AuditTest SET AuditTestData = 'Fourth' WHERE AuditTestID = 2

SELECT * FROM AuditTest_Audit

DELETE AuditTest WHERE AuditTestID = 1
DELETE AuditTest

SELECT * FROM AuditTest_Audit