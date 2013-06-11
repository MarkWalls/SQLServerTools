------------
-- Dynamic SQL 101 - QUICK SYNTAX - T-SQL exec / execute - SQL Server sp_executeSQL
-- sp_exeduteSQL has advantages over EXEC including performance (execution plan reuse)
------------
USE AdventureWorks2008;
EXEC ('SELECT * FROM Production.Product')    -- tsql constant string execution 
------------
DECLARE @TableName sysname ='Sales.SalesOrderHeader'
EXECUTE ('SELECT * FROM '+@TableName)        -- T-SQL string with variable - dynamic 
------------
EXECUTE sp_executeSQL N'SELECT * FROM Purchasing.PurchaseOrderHeader'
------------
DECLARE @SQL varchar(256); SET @SQL='SELECT * FROM Production.Product'
EXEC (@SQL)                -- SQL Server 2008 dynamic SQL query execution
------------
 
DECLARE @SQL varchar(256), @Table sysname;
SET @SQL='SELECT * FROM'; SET @Table = 'Production.Product'
SET @SQL = @SQL+' '+@Table
PRINT @SQL     -- for debugging dynamic SQL prior to execution of generated static code
EXEC (@SQL)    -- Microsoft dynamic SQL execution - SQL Server 2005 execute dynamic SQL
------------

-- Dynamic queries with local variables and parameter(s) - t-sql parameterized query
-- Parameters are NOT ALLOWED everywhere in an SQL statement - hence dynamic SQL
DECLARE @Color varchar(16) = 'Yellow'
SELECT Color=@Color, ProductCount=COUNT(Color)
FROM AdventureWorks2008.Production.Product
WHERE Color = @Color
/*    Color    ProductCount
      Yellow      36              */
------------

-- SQL Server 2012 sp_executeSQL usage with input and output parameters (2008/2005)
DECLARE @SQL NVARCHAR(max), @ParmDefinition NVARCHAR(1024)
DECLARE @ListPrice money = 2000.0, @LastProduct varchar(64)
SET @SQL =       N'SELECT @pLastProduct = max(Name)
                   FROM AdventureWorks2008.Production.Product
                   WHERE ListPrice >= @pListPrice'
SET @ParmDefinition = N'@pListPrice money,
                        @pLastProduct varchar(64) OUTPUT'
EXECUTE sp_executeSQL      -- Dynamic T-SQL
            @SQL,
            @ParmDefinition,
            @pListPrice = @ListPrice,
            @pLastProduct=@LastProduct OUTPUT
SELECT [ListPrice >=]=@ListPrice, LastProduct=@LastProduct
/* ListPrice >=   LastProduct
2000.00     Touring-1000 Yellow, 60 */
------------
-- 3-part naming execution of dynamic SQL - Specifying database (USE dbname)
EXEC AdventureWorks2008R2.dbo.sp_executeSQL N'exec sp_help'
------------

-- INSERT EXEC dynamic SQL execution
CREATE TABLE #Product(ProductID int, ProductName varchar(64))
INSERT #Product
EXEC sp_executeSQL N'SELECT ProductID, Name
                    FROM AdventureWorks2008.Production.Product'
-- (504 row(s) affected)
SELECT * FROM #Product ORDER BY ProductName
GO
DROP TABLE #Product
------------    

------------
-- Loop through all databases to get table count - Dynamic SQL tutorial
-- Change database context dynamically (USE database substitution)
------------
    DECLARE @SQL nvarchar(max), @dbName sysname;
    DECLARE DBcursor CURSOR  FOR
    SELECT name FROM     master.dbo.sysdatabases
    WHERE  name NOT IN ('master','tempdb','model','msdb')
      AND  DATABASEPROPERTYEX(name,'status')='ONLINE' ORDER BY name;
    OPEN DBcursor; FETCH  DBcursor   INTO @dbName;
    WHILE (@@FETCH_STATUS = 0) -- loop through all db-s
      BEGIN
        DECLARE @dbContext nvarchar(256)=@dbName+'.dbo.'+'sp_executeSQL'
        SET @SQL = 'SELECT ''Database: '+ @dbName +
                   ' table count'' = COUNT(*) FROM sys.tables';
        PRINT @SQL;
-- SELECT 'Database: AdventureWorks table count' = COUNT(*) FROM sys.tables
        EXEC @dbContext @SQL;
        FETCH  DBcursor INTO @dbName;
     END; -- while
   CLOSE DBcursor; DEALLOCATE DBcursor;
----------

------------ 
-- SQL Server Assemble, Test & Execute Dynamic SQL Command - Dynamic SQL Tutorial
-- Generate dynamic SQL statements in SQL Server 2008
------------
DECLARE @SQLStatement nvarchar(max)   -- String variable for assembly of SQL statement
DECLARE @ColumnList   nvarchar(max), @Where nvarchar(max), @Table nvarchar(max)
SET @ColumnList = 'ProductID, ProductName=Name, ListPrice'
SET @Table      = 'AdventureWorks2008.Production.Product'
SET @Where      = 'Color is not null'
SET @SQLStatement = ' SELECT ' + @ColumnList + CHAR(13) + ' FROM '+@Table + CHAR(13) +
                    ' WHERE 1 = 1 AND ' + @Where
PRINT @SQLStatement
/* SELECT ProductID, ProductName=Name, ListPrice
   FROM AdventureWorks2008.Production.Product
   WHERE 1 = 1 AND Color is not null  */
EXECUTE sp_executeSQL @SQLStatement          -- Execute Dynamic SQL - T-SQL Dynamic SQL
-- (256 row(s) affected)
------------

-- Dynamic alias for column / table - SQL Server EXECUTE
DECLARE @Legend varchar(32)='ProductName'
EXEC ('SELECT Name AS '+@Legend+' FROM AdventureWorks2008.Production.Product')
------------

-- Dynamic SQL for rowcount in all tables - database metadata usage in dynamic SQL
DECLARE @SQL nvarchar(max), @Schema sysname, @Table sysname;
SET @SQL = ''
SELECT @SQL = @SQL + 'SELECT '''+QUOTENAME(TABLE_SCHEMA)+'.'+
  QUOTENAME(TABLE_NAME)+''''+
  '= COUNT(*) FROM '+ QUOTENAME(TABLE_SCHEMA)+'.'+QUOTENAME(TABLE_NAME) +';'
FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'
PRINT @SQL                -- test & debug
EXEC sp_executesql @SQL   -- Dynamic SQL query execution - sp_executesql SQL Server
------------
 
-- Equivalent code with the undocumented sp_MSforeachtable
EXEC sp_MSforeachtable 'select ''?'', count(*) from ?'
------------

------------
-- SQL Server dynamic SQL variables - result into variable - input from variable
------------
DECLARE @LastName nvarchar(32) = 'Smith', @MaxFirstName NVARCHAR(50)
DECLARE @SQL NVARCHAR(MAX) = N'SELECT @pMaxFirstNameOUT = max(QUOTENAME(FirstName))
  FROM AdventureWorks2008.Person.Person'+CHAR(13)+
  'WHERE LastName = @pLastName'
PRINT @SQL+CHAR(13)
EXEC sp_executeSQL      @SQL,   -- getting variable input / setting variable output
                        N'@pLastName nvarchar(32),               
                          @pMaxFirstNameOUT nvarchar(50) OUTPUT', -- parms definition
                        @pLastName = @LastName,                   -- input parameter
                        @pMaxFirstNameOUT=@MaxFirstName OUTPUT    -- output parameter
 
SELECT [Max First Name] = @MaxFirstName, Legend='of last names ',
       LastName=@LastName
/* Max First Name Legend      LastName
[Zachary]   of last names     Smith   */

-----------
-- SQL Server dynamic sql stored procedure -- parametrized SQL statement
-----------
-- Dynamic SQL is not allowed in function (UDF)
 
CREATE PROCEDURE uspProductSearch @ProductName VARCHAR(32)  = NULL
AS
  BEGIN
    DECLARE  @SQL NVARCHAR(MAX)
    SELECT @SQL = ' SELECT ProductID, ProductName=Name, Color, ListPrice ' + CHAR(10)+
                  ' FROM AdventureWorks2008.Production.Product' + CHAR(10)+
                  ' WHERE 1 = 1 ' + CHAR(10)
    IF @ProductName IS NOT NULL
      SELECT @SQL = @SQL + ' AND Name LIKE @pProductName'
    PRINT @SQL 
-- parametrized execution
    EXEC sp_executesql @SQL, N'@pProductName varchar(32)', @ProductName 
  END
GO
-- Execute dynamic SQL stored procedure with parameter
EXEC uspProductSearch '%bike%' 
/*    ProductID   ProductName             Color ListPrice
....
      710         Mountain Bike Socks, L  White 9.50
      709         Mountain Bike Socks, M  White 9.50  .... */
 
------------
-- Dynamic SQL for OPENQUERY execution within stored procedure
------------
USE AdventureWorks2008;
GO
CREATE PROC sprocGetBOM @ProductID int, @Date date
AS
BEGIN
  DECLARE @SQL nvarchar(max)=
  'SELECT *
   INTO   ##BOM
   FROM   OPENQUERY(localhost,'' EXECUTE
          [AdventureWorks].[dbo].[uspGetBillOfMaterials] '+
                           convert(varchar,@ProductID)+
                           ','''''+convert(varchar,@Date)+''''''')'
  PRINT @SQL
  EXEC sp_executeSQL @SQL
END
GO
EXEC sprocGetBOM 900, '2004-03-15'
GO
SELECT * FROM ##BOM     -- Global temporary table with scope outside the sproc
-- (24 row(s) affected)
DROP TABLE ##BOM
------------

-- Dynamic sorting with specific collation - Dynamic ORDER BY
DECLARE @SQL nvarchar(max)='SELECT ProductID, Name, ListPrice, Color
  FROM AdventureWorks2008.Production.Product
  ORDER BY Name '
DECLARE @Collation nvarchar(max) = 'COLLATE SQL_Latin1_General_CP1250_CS_AS'
SET @SQL=@SQL + @Collation
PRINT @SQL
EXEC sp_executeSQL @SQL          -- Execute dynamic query SQL Server

-- Dynamic (ad-hoc) stored procedure execution with parameter(s)
DECLARE @spName varchar(256) = '[AdventureWorks2008].[dbo].[uspGetManagerEmployees]'
DECLARE @valParm1 int = 1
EXECUTE @spName @valParm1
------------
 
-- Count tables in all databases without looping through db metadata
SET NOCOUNT ON; CREATE TABLE #DBTables ( DBName  SYSNAME, TableCount INT );
DECLARE @DynamicSQL NVARCHAR(MAX) = '';
SELECT @DynamicSQL = @DynamicSQL + 'USE' + QUOTENAME(name)+'; '  +
                 ' insert into #DBTables select ' + Quotename(name,'''') +
                 ', count(*) from sys.tables; ' +char(13)
FROM   sys.databases;
PRINT @DynamicSQL;
EXEC sp_executeSQL   @DynamicSQL;
SELECT   * FROM #DBTables ORDER BY TableCount DESC;
GO
DROP TABLE #DBTables;
------------

-- Create database dynamically
USE AdventureWorks2008;
GO
CREATE PROC uspCreateDB @DBName sysname
AS
BEGIN
  DECLARE @SQL nvarchar(255) = 'CREATE DATABASE '+@DBName;
  EXEC sp_executeSQL @SQL;
END
GO
 
EXEC uspCreateDB 'InventoryJUL';
------------

Related article: Dynamic SQL

-- Dynamic SQL stored procedure for customer list 

USE Northwind;
GO
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = Object_id(N'[dbo].[CustomerListByState]')
                  AND TYPE IN (N'P',N'PC'))
  DROP PROCEDURE [dbo].[CustomerListByState]
GO
 
-- Dynamic SQL stored procedure - Dynamic SQL IN list clause
/***** WARNING - This sproc is vulnerable to SQL Injection Attack *****/
-- CSV List splitter and JOIN is the preferred solution
CREATE PROCEDURE CustomerListByState @States VARCHAR(128)
AS
  BEGIN
    DECLARE  @SQL NVARCHAR(1024)
    SET @SQL = 'select CustomerID, CompanyName, ContactName, Phone,
                        Region from Customers where Region
                        IN (' + @States + ')' + ' order by Region'
    PRINT @SQL -- For testing and debugging
/* The following query is executed as dynamic SQL
select CustomerID, CompanyName, ContactName, Phone, Region
   from Customers where Region IN ('WA', 'OR', 'ID', 'CA') order by Region
*/
    -- Dynamic SQL execution
    EXEC Sp_executesql  @SQL
  END
GO
 
-- Execute dynamic SQL stored procedure
DECLARE  @States VARCHAR(100)
SET @States = '''WA'', ''OR'', ''ID'', ''CA'''
EXEC CustomerListByState   @States
GO
/* Partial results
 
CustomerID  CompanyName                   ContactName       Phone           Region
LETSS       Let's Stop N Shop             Jaime Yorres      (415) 555-5938  CA
SAVEA       Save-a-lot Markets            Jose Pavarotti    (208) 555-8097  ID
GREAL       Great Lakes Food Market       Howard Snyder     (503) 555-7555  OR
HUNGC       Hungry Coyote Import Store    Yoshi Latimer     (503) 555-6874  OR
*/
 
/* QUOTENAME can also be used to build sproc execution string
 
DECLARE @States VARCHAR(100)
SET @States = QUOTENAME('WA','''')+','+ QUOTENAME('OR','''')
EXEC CustomerListByState @States
GO
*/

------------

 
-- Make TABLESAMPLE dynamic
 
-- Dynamic SQL for TABLESAMPLE - T-SQL dynamic sql - SQL tablesample
DECLARE @Size tinyint = 7
DECLARE @SQL nvarchar(512) =
    'SELECT PurchaseOrderID, OrderDate = CAST(OrderDate AS DATE),
     VendorID FROM AdventureWorks2008.Purchasing.PurchaseOrderHeader
       TABLESAMPLE ('+ CAST(@Size AS VARCHAR)+' PERCENT)'
PRINT @SQL -- for testing & debugging purposes
/* SELECT PurchaseOrderID, OrderDate = CAST(OrderDate AS DATE),
   VendorID FROM AdventureWorks2008.Purchasing.PurchaseOrderHeader
       TABLESAMPLE (7 PERCENT) */
-- SQL Server execute dynamic sql
EXEC sp_executesql @SQL
GO -- (435 row(s) affected)
/* Partial results
 
PurchaseOrderID   OrderDate   VendorID
349               2003-06-23  1672
350               2003-06-23  1600
351               2003-06-23  1522
352               2003-06-23  1570
353               2003-06-23  1516
*/

------------

 
-- Dynamic SQL execution with parameters
 
-- Dynamic SQL script - SQL Server 2008 - sp_executesql parameter usage
-- Communicating with child process using command line parameters
USE AdventureWorks2008;
DECLARE  @ParmDefinition NVARCHAR(1024) = N'@FirstLetterOfLastName char(1),
      @LastFirstNameOUT nvarchar(50) OUTPUT'
DECLARE @FirstLetter CHAR(1) = 'P', @LastFirstName NVARCHAR(50)
DECLARE @SQL NVARCHAR(MAX) = N'SELECT @LastFirstNameOUT = max(FirstName)
      FROM Person.Person'+CHAR(13)+
      'WHERE left(LastName,1) = @FirstLetterOfLastName'
PRINT @SQL+CHAR(13) -- For testing and debugging
/*
SELECT @LastFirstNameOUT = max(FirstName)
FROM Person.Person
WHERE left(LastName,1) = @FirstLetterOfLastName
*/
PRINT @ParmDefinition -- For testing and debugging
/*
@FirstLetterOfLastName char(1),
@LastFirstNameOUT nvarchar(50) OUTPUT
*/ 
-- SQL Server dynamic SQL return value - Returning values from dynamic SQL
EXECUTE sp_executeSQL
      @SQL,
      @ParmDefinition,
      @FirstLetterOfLastName = @FirstLetter,
      @LastFirstNameOUT=@LastFirstName OUTPUT
 
SELECT
[Last First Name] = @LastFirstName,
Legend='of last names starting with',
Letter=@FirstLetter
GO
------------
 
-- Enumerate all objects in databases

-- Return objects count in all databases on the server
-- Dynamic SQL stored procedure - SQL quotename used to build valid db object names
USE AdventureWorks;
GO
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = Object_id(N'[dbo].[sprocObjectCountsAllDBs]')
                  AND TYPE IN (N'P',N'PC'))
  DROP PROCEDURE [dbo].[sprocObjectCountsAllDBs]
GO
CREATE PROC sprocObjectCountsAllDBs
AS
  BEGIN
    DECLARE  @dbName      SYSNAME,
             @ObjectCount INT
    DECLARE  @SQL NVARCHAR(MAX)
    DECLARE  @DBObjectStats  TABLE(
                                   DBName    SYSNAME,
                                   DBObjects INT
                                   )
    DECLARE curAllDBs CURSOR  FOR
    SELECT   name
    FROM     MASTER.dbo.sysdatabases
    WHERE    name NOT IN ('master','tempdb','model','msdb')
    ORDER BY name
    OPEN curAllDBs
    FETCH  curAllDBs
    INTO @dbName
  
    WHILE (@@FETCH_STATUS = 0) -- loop through all db-s
      BEGIN
        -- Build valid yet hard-wired SQL statement
        -- SQL QUOTENAME is used for valid identifier formation
        SET @SQL = 'select @dbObjects = count(*)' + Char(13) + 'from ' + Quotename(@dbName) + '.dbo.sysobjects'
        
        PRINT @SQL -- Use it for debugging
        
        -- Dynamic SQL call with output parameter(s)
        EXEC Sp_executesql
          @SQL ,
          N'@dbObjects int output' ,
          @dbObjects = @ObjectCount OUTPUT
        
        INSERT @DBObjectStats
        SELECT @dbName,  @ObjectCount
        
        FETCH  curAllDBs INTO @dbName
      END -- while
    CLOSE curAllDBs
    DEALLOCATE curAllDBs
    -- Return results
    SELECT *
    FROM   @DBObjectStats
  END
GO
 
-- Execute stored procedure with dynamic SQL
EXEC sprocObjectCountsAllDBs
GO
------------

-- Frequency of column value in database
------------
-- Find frequency of a column value (800) in all tables with column ProductID
------------
DECLARE @DynamicSQL nvarchar(MAX) = '',  @ProductID int = '800'; 
DECLARE @ColumnName sysname = N'ProductID', @Parms nvarchar(32) = N'@pProductID int';
SELECT @DynamicSQL = @DynamicSQL +
       CASE WHEN LEN(@DynamicSQL) <> 0 THEN char(13)+'UNION ALL' ELSE '' END +
       ' SELECT '''+ t.TABLE_SCHEMA+'.'+ t.TABLE_NAME +
       ''' AS TableName, Frequency=COUNT(*) FROM ' +
       QUOTENAME(t.TABLE_SCHEMA) +'.' + QUOTENAME(t.TABLE_NAME) +
       ' WHERE CONVERT(INT, ' + QUOTENAME(c.COLUMN_NAME) + ') = @pProductID'
FROM [AdventureWorks2008].[INFORMATION_SCHEMA].[TABLES] t
  INNER JOIN [AdventureWorks2008].[INFORMATION_SCHEMA].[COLUMNS] c
    ON  t.TABLE_SCHEMA = c.TABLE_SCHEMA
      AND t.TABLE_NAME = c.TABLE_NAME
WHERE TABLE_TYPE='BASE TABLE'
  AND c.COLUMN_NAME = @ColumnName;
SET @DynamicSQL = @DynamicSQL + N' ORDER BY Frequency DESC;';
PRINT @DynamicSQL;
EXEC sp_executeSQL @DynamicSQL, @Parms, @pProductID = @ProductID;
/*    TableName                           Frequency
      Sales.SalesOrderDetail              495
      Production.TransactionHistory       418             ....*/
------------

-- Automatic code generation for 
-- datetime conversion from style 0 to 14

-- Dynamic SQL using temporary table - SQL Server Dynamic SQL temp table
USE AdventureWorks2008;
DECLARE @I INT = -1
DECLARE @SQLDynamic nvarchar(1024)
CREATE TABLE #SQL(STYLE int, SQL varchar(256), Result varchar(32))
WHILE (@I < 14)
BEGIN
      SET @I += 1
      INSERT #SQL(STYLE, SQL)
      SELECT @I, 'SELECT '+
      'CONVERT(VARCHAR, GETDATE(), '+CONVERT(VARCHAR,@I)+')'
      SET @SQLDynamic = 'UPDATE #SQL SET Result=(SELECT
      CONVERT(VARCHAR, GETDATE(), '+CONVERT(VARCHAR,@I)+
      ')) WHERE STYLE='+ CONVERT(VARCHAR,@I)
      PRINT @SQLDynamic
/* Printed in Messages - partial listing
UPDATE #SQL SET Result=(SELECT
CONVERT(VARCHAR, GETDATE(), 0)) WHERE STYLE=5
*/
     EXEC sp_executeSQL @SQLDynamic
END
SELECT * FROM #SQL
DROP TABLE #SQL

------------

-- Communicating between parent and 
-- child process using a shared temporary table

-- Temporary table created in parent session is visible to child
-- Parent session
-- Dynamic SQL
DECLARE @SQL nvarchar(512)
SELECT City='Montreal', Country = convert(varchar(30),'Canada')
INTO #City
-- Child session T-SQL script
SET @SQL = 'SELECT * FROM #City;
  INSERT #City VALUES(''Dallas'',''United States'');'
 
/* char(39)(ascii single quote) can be used to eliminate nested quotes
 
INSERT #City VALUES('+char(39)+'Dallas'+char(39)+','+char(39)+
                     'United States'+char(39)+');'
*/

PRINT @SQL
/*
SELECT * FROM #City; INSERT #City VALUES('Dallas','United States');
*/
EXEC sp_executeSQL @SQL
/* Result of select in child session
City        Country
Montreal    Canada
*/
SELECT * FROM #City
GO
/* Results
 
City        Country
Dallas      United States
Montreal    Canada
*/
DROP TABLE #City
GO

------------

-- The importance of QUOTENAME usage 

-- QUOTENAME ensures that dynamic SQL will execute correctly
USE Northwind;
GO
 
-- SQL create stored procedure - SQL dynamic SQL - SQL quotename usage
CREATE PROCEDURE SelectFromAnyTable  @TableName nvarchar(256)
AS
BEGIN
  DECLARE @SQL NVARCHAR(512)
    IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = @TableName)
    BEGIN
      RAISERROR('Invalid table name %s!',16,1, @TableName)
      RETURN 0
    END
  SET @SQL = 'select * from ' + QUOTENAME(@TableName)
  PRINT @SQL
-- select * from [Order Details]
  EXECUTE sp_executeSQL @SQL
  RETURN 1
END
 
-- SQL execute script - SQL execute dynamic sql stored procedure
EXEC SelectFromAnyTable   'Order Details'
 
/* Partial results
OrderID     ProductID   UnitPrice   Quantity    Discount
10248       11          14.00       12          0
10248       42          9.80        10          0
10248       72          34.80       5           0
10249       14          18.60       9           0
*/

------------

--  Dynamic pivot query for crosstabulation

-- SQL pivot crosstab report - SQL dynamic pivot - SQL dynamic sql
-- SQL dynamic crosstab report with pivot
USE AdventureWorks
GO
DECLARE  @SQLtext  AS NVARCHAR(MAX)
DECLARE  @ReportColumnNames  AS NVARCHAR(MAX)
-- SQL pivot list generation dynamically - Dynamic pivot list        
SELECT  @ReportColumnNames = Stuff( (
SELECT ', ' + QUOTENAME(YYYY) AS [text()]
FROM   (SELECT DISTINCT YYYY=CAST (Year(OrderDate) as VARCHAR)
FROM Sales.SalesOrderHeader ) x
ORDER BY YYYY
-- SQL xml path for comma-limited list generation
FOR XML PATH ('')), 1, 1, '')
 
SET @SQLtext = N'SELECT * FROM (SELECT [Store (Freight Summary)]=s.Name,
YEAR(OrderDate) AS OrderYear,  Freight = convert(money,convert(varchar, Freight))
FROM Sales.SalesOrderHeader soh  JOIN Sales.Store s
ON soh.CustomerID = s.CustomerID) as Header
PIVOT (SUM(Freight) FOR OrderYear IN(' + @ReportColumnNames + N'))
AS Pvt ORDER BY 1'
 
PRINT @SQLtext -- Testing & debugging
/*
SELECT * FROM (SELECT [Store (Freight Summary)]=s.Name,
YEAR(OrderDate) AS OrderYear,  Freight = convert(money,convert(varchar, Freight))
FROM Sales.SalesOrderHeader soh  JOIN Sales.Store s
ON soh.CustomerID = s.CustomerID) as Header
PIVOT (SUM(Freight) FOR OrderYear IN([2001],[2002],[2003],[2004]))
AS Pvt ORDER BY 1
*/
-- SQL dynamic query execution
EXEC sp_executesql   @SQLtext
GO
/* Partial results
 
Store (Freight Summary) 2001        2002        2003        2004
Sundry Sporting Goods   1074.02     4609.31     4272.94     1569.04
Sunny Place Bikes       193.95      802.70      1095.83     411.62
Super Sports Store      102.15      743.51      427.80      301.68
Superb Sales and Repair 1063.69     1547.73     37.28       13.23
*/

------------

-- Simple Dynamic SQL Statement Execution - Dynamic SQL Tutorial 
EXEC sp_executeSQL N'SELECT TOP(7) * FROM Northwind.dbo.Orders ORDER BY NEWID()'
------------ Dynamic SQL WHERE clause
DECLARE @Predicate varchar(128) = 'ProductID=800'
EXEC ('SELECT * FROM AdventureWorks2008.Production.Product WHERE '+@Predicate)
------------ Dynamic view name / table name SELECT
DECLARE @SQL nvarchar(max), @View sysname='Northwind.dbo.Invoices'
SELECT @SQL = 'SELECT * FROM ' + @View
EXEC sp_executeSQL @SQL 
------------

-- Dynamic SQL - dynamic table name - dynamic sql SQL Server - sp_executeSQL
DECLARE @SQL nvarchar(max), @Table sysname='AdventureWorks2008.Production.Product'
SELECT @SQL = 'SELECT Rows=count(*) FROM '      -- count rows dynamic SQL statement 
SELECT @SQL = @SQL + @Table                     -- concatenate string variables 
EXEC (@SQL)                     -- Original dynamic SQL execution command
-- 504                          -- SQL execute dynamic SQL result
EXEC sp_executeSQL @SQL         -- Improved transact-SQL dynamic SQL execute
-- 504
------------

Dynamic SQL script generates static (hardwired) T-SQL statement(s) at runtime. We can use the PRINT command to see the final SQL script and test it prior to execution.

-- SQL Server 2008 dynamic SQL query stored procedure - quick syntax - dynamic T-SQL
USE AdventureWorks2008; 
GO 
CREATE PROCEDURE uspCountAnyKeyInAnyTable 
               @TableName  SYSNAME, 
               @ColumnName SYSNAME,
               @Wildcard   NVARCHAR(64) 
AS 
  DECLARE  @SQL  NVARCHAR(MAX)=' SELECT FrequencyCount=count(*) ' + ' FROM ' + 
                @TableName + ' WHERE ' + @ColumnName + ' LIKE ' + 
                CHAR(39)+@Wildcard + CHAR(39)
  PRINT @SQL -- for testing and debugging 
  EXEC sp_executesql  @SQL 
GO 
EXECUTE uspCountAnyKeyInAnyTable 'Production.Product', 'Color', '%Blue%' 
--  26
------------

Dynamic SQL is a powerful database programming technology that enables you to concatenate and execute T-SQL statements dynamically in a string variable at runtime. You can create robust data / parameter driven queries and stored procedures. For example, the PIVOT crosstab column list changes as the data grows, therefore it has to be built dynamically at runtime, and it cannot be hardwired. When rebuilding indexes in a cursor WHILE loop, the table name varies, it necessitates the use of dynamic SQL.
Static SQL stays the same in each execution. Dynamic SQL strings contain the text of a DML or DDL T-SQL script and can also contain placeholders for binding parameters. In the following example @pCountryCode is a placeholder for a parameter which is supplied at execution time.

------------
-- Example for declaring & passing parameter (@pCountryCode) to sp_executesql
------------
CREATE PROC sprocListStatesByCountry @CountryCode varchar(32) AS
DECLARE @SQL nvarchar(max)
DECLARE @Columns varchar(128) =                  'StateProvinceCode,CountryRegionCode,State=Name'
SET @SQL = 'SELECT ' + @Columns + 
           ' FROM AdventureWorks2008.Person.StateProvince' +
           ' WHERE CountryRegionCode = @pCountryCode'
EXEC sp_executesql @SQL, 
                   N'@pCountryCode nvarchar(32)',@pCountryCode = @CountryCode
GO
EXEC sprocListStatesByCountry 'DE'
-- (partial results) BY   DE    Bayern 
------------

The QUOTENAME function returns a Unicode string with the square brackets added to make the input string a valid Microsoft SQL Server delimited identifier. SELECT QUOTENAME ('Order Details') returns [Order Details], a valid identifier with space. If an identifier is obtained from metadata, the use of QUOTENAME ensures validity. 

-- T-SQL dynamic query example with QUOTENAME - count rows in all tables in database
USE AdventureWorks2008;
DECLARE @SQLtext nvarchar(max) = '', @Schema sysname, @Table sysname;
SELECT @SQLtext = @SQLtext + 'SELECT '''+QUOTENAME(TABLE_SCHEMA)+'.'+
  QUOTENAME(TABLE_NAME)+''''+
  '= COUNT(*) FROM '+ QUOTENAME(TABLE_SCHEMA)+'.'+QUOTENAME(TABLE_NAME) +';'
FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME
PRINT @SQLtext -- test & debug
  /* .... ;SELECT '[Production].[ProductDescription]'= COUNT(*)
           FROM [Production].[ProductDescription]; ....   */
EXEC sp_executesql @SQLtext  -- sql server exec dynamic sql

-- Equivalent code with the undocumented sp_MSforeachtable - dynamic query
EXEC sp_MSforeachtable 'select ''?'', count(*) from AdventureWorks2008.?'
-- Related undocumented sp_MSforeachdb
EXEC sp_MSforeachdb 'select  ''?'''

The T-SQL PIVOT operator rotates rows into columns with the application an aggregate function such as SUM (crosstab). However, the PIVOT statement requires a static (hardwired) column list which on the other hand maybe data-driven, not known in advance, not known for the future, like YEARs for the columns which change with the data content of a database. The solution is dynamic SQL PIVOT with dynamic columns list preparation and usage in the PIVOT.
 
------------
-- SQL Server dynamic PIVOT Query - T-SQL Dynamic Pivot Crosstab - Dynamic Columns
------------
-- Unknown number of columns - Dynamic sql example - t sql dynamic query
USE AdventureWorks;
DECLARE @SQLtext AS NVARCHAR(MAX)
DECLARE @ReportColumnNames AS NVARCHAR(MAX)
-- SQL pivot list generation dynamically -  Dynamic pivot list - pivot dynamic
SELECT @ReportColumnNames = Stuff( (
SELECT ', ' + QUOTENAME(YYYY) AS [text()]
FROM (SELECT DISTINCT YYYY=CAST (Year(OrderDate) as VARCHAR)
      FROM Sales.SalesOrderHeader ) x
ORDER BY YYYY
FOR XML PATH ('')), 1, 1, '') -- SQL xml path for comma-limited list generation
PRINT @ReportColumnNames
-- [2001], [2002], [2003], [2004]
SET @SQLtext = N'SELECT * FROM (SELECT [Store (Freight Summary)]=s.Name,
    YEAR(OrderDate) AS OrderYear,
    Freight = convert(money,convert(varchar, Freight))
    FROM Sales.SalesOrderHeader soh
    INNER JOIN Sales.Store s
    ON soh.CustomerID = s.CustomerID) as Header
    PIVOT (SUM(Freight) FOR OrderYear
    IN(' + @ReportColumnNames + N')) AS Pvt
    ORDER BY 1'
PRINT @SQLtext -- Testing & debugging - displays query prior to execution
-- SQL Server t sql execute dynamic sql
EXEC sp_executesql @SQLtext -- Execute dynamic SQL command
GO
/*  Partial results
Store (Freight Summary)       2001        2002        2003        2004
Neighborhood Store            NULL        2289.75     1120.64     NULL
New and Used Bicycles         1242.99     4594.51     4390.48     1671.98
*/

-- SQL injection dynamic SQL - protect from SQL injection attacks 
Important security article related to dynamic SQL: 
How To: Protect From SQL Injection in ASP.NET

-- Dynamic SQL with in / out parameters:

sp_executeSQL system stored procedure supports input and output parameter usage. With parameters, dynamic SQL execute statement resembles stored procedure execution with parameters. Readability, functionality and performance (query plan cached) are improved with parameters application.
 
-- Dynamic SQL execution with input / output parameters
-- SQL Server dynamic query - QUOTENAME - mssql dynamic sql variables
USE AdventureWorks2008;
DECLARE  @ParmDefinition NVARCHAR(1024) = N'@pFirstLetterOfLastName char(1),
      @pLastFirstNameOUT nvarchar(50) OUTPUT'
DECLARE @FirstLetter CHAR(1) = 'E', @LastFirstName NVARCHAR(50)
DECLARE @SQL NVARCHAR(MAX) = N'SELECT @pLastFirstNameOUT = max(QUOTENAME(FirstName))
      FROM Person.Person'+CHAR(13)+
      'WHERE left(LastName,1) = @pFirstLetterOfLastName'
PRINT @SQL+CHAR(13)
/*
SELECT @pLastFirstNameOUT = max(QUOTENAME(FirstName))
      FROM Person.Person
WHERE left(LastName,1) = @pFirstLetterOfLastName
*/
PRINT @ParmDefinition
/*
@pFirstLetterOfLastName char(1),
      @pLastFirstNameOUT nvarchar(50) OUTPUT
*/
-- Dynamic SQL with parameters, including OUTPUT parameter
EXECUTE sp_executeSQL
      @SQL,
      @ParmDefinition,
      @pFirstLetterOfLastName = @FirstLetter,
      @pLastFirstNameOUT=@LastFirstName OUTPUT
 
SELECT
      [Last First Name] = @LastFirstName,
      Legend='of last names starting with',
      Letter=@FirstLetter
GO
/* Results
Last First Name   Legend                        Letter
[Xavier]          of last names starting with   E
*/

-- Dynamic SQL execution of OPENQUERY:

Readability of dynamic SQL code is a challenge. The reason is that the building T-SQL code (concatenations) mingles with dynamic code. Formatting both codes is helpful. Using CHAR(39) for single quote reduces single quote sequence like ''''''.
 
-- OPENQUERY Dynamic SQL execution - SQL Server 2008 T-SQL code
DECLARE @SQLtext nvarchar(max) =
     'SELECT * 
      FROM OPENQUERY(' + QUOTENAME(CONVERT(sysname, @@SERVERNAME))+ ',
      ''EXECUTE [AdventureWorks2008].[dbo].[uspGetWhereUsedProductID] 400,
      ''''2003-11-21'''''')' 
PRINT @SQLtext 
  /*
  SELECT * 
  FROM OPENQUERY([YOURSERVER\SQL2008],
  'EXECUTE [AdventureWorks2008].[dbo].[uspGetWhereUsedProductID] 3,
  ''2003-12-01''')
  */
 
EXEC sp_executeSQL @SQLtext
-- (64 row(s) affected)
------------
 
A table name or column name may include space. If we do not enclose such a db object name in square brackets, the generated dynamic SQL string will be invalid. We can explicitly concatenate '[' and ']' or use the special function QUOTENAME.

-- Forming proper database object names :

-- T-SQL QUOTENAME function will add square bracket delimiters to system names
USE Adventureworks;
 
SELECT DatabaseObject = QUOTENAME(table_schema) + '.' + QUOTENAME(table_name),
       t.*
FROM   INFORMATION_SCHEMA.TABLES t
WHERE  table_type IN ('VIEW','BASE TABLE')
       AND Objectproperty(Object_id(QUOTENAME(table_schema) + '.' +
           QUOTENAME(table_name)), 'IsMSShipped') = 0
GO
/* Partial results
 
DatabaseObject
[Production].[ProductProductPhoto]
[Sales].[StoreContact]
[Person].[Address]
[Production].[ProductReview]
[Production].[TransactionHistory]
*/

-- Forming proper database object names within a 
-- dynamic SQL query stored procedure with QUOTENAME:
-- QUOTENAME will make dynamic SQL execute correctly
USE Northwind;
GO
-- SQL create stored procedure - SQL dynamic SQL - SQL QUOTENAME usage
CREATE PROCEDURE SelectFromAnyTable @table sysname
AS
BEGIN
      DECLARE @sql nvarchar(512)
      SET @sql = 'select * from '+ QUOTENAME(@table)
      PRINT @sql
      EXECUTE sp_executeSQL @sql
END
GO
 
-- SQL execute script - SQL execute dynamic sql stored procedure
exec SelectFromAnyTable 'Order Details'
/* Messages
 
select * from [Order Details]
(2155 row(s) affected)
*/
 
-- Forming Year column header in dynamic crosstab query:
 
-- SQL pivot crosstab report - SQL QUOTENAME - SQL dynamic pivot
-- SQL dynamic crosstab report with pivot - SQL dynamic sql
USE AdventureWorks
GO
DECLARE  @OrderYear  AS  TABLE(
                               YYYY INT    NOT NULL    PRIMARY KEY
                               )
DECLARE  @SQLtext  AS NVARCHAR(4000)
 
INSERT INTO @OrderYear
SELECT DISTINCT Year(OrderDate)
FROM   Sales.SalesOrderHeader
 
DECLARE  @ReportColumnNames  AS NVARCHAR(MAX),
         @IterationYear      AS INT
 
SET @IterationYear = (SELECT Min(YYYY)
                      FROM   @OrderYear)
 
SET @ReportColumnNames = N''
 
-- Assemble pivot list dynamically
WHILE (@IterationYear IS NOT NULL)
  BEGIN
    SET @ReportColumnNames = @ReportColumnNames + N', ' +
         QUOTENAME(Cast(@IterationYear AS NVARCHAR(10)))
    
    SET @IterationYear = (SELECT Min(YYYY)
                          FROM   @OrderYear
                          WHERE  YYYY > @IterationYear)
  END
 
SET @ReportColumnNames = Substring(@ReportColumnNames,2,Len(@ReportColumnNames))
 
SET @SQLtext = N'SELECT * FROM (SELECT [Store (Freight Summary)]=s.Name, 
YEAR(OrderDate) AS OrderYear,  Freight = convert(money,convert(varchar, Freight))
  FROM Sales.SalesOrderHeader soh  JOIN Sales.Store s 
ON soh.CustomerID = s.CustomerID) as Header 
PIVOT (SUM(Freight) FOR OrderYear IN(' + @ReportColumnNames + N')) 
AS Pvt ORDER BY 1'
 
PRINT @SQLtext -- Testing & debugging
-- SQL QUOTENAME placed the square brackets around the year (YYYY)
 
/*
SELECT * FROM (SELECT [Store (Freight Summary)]=s.Name, 
YEAR(OrderDate) AS OrderYear,  Freight = convert(money,convert(varchar, Freight)) 
FROM Sales.SalesOrderHeader soh  JOIN Sales.Store s 
ON soh.CustomerID = s.CustomerID) as Header 
PIVOT (SUM(Freight) FOR OrderYear IN([2001],[2002],[2003],[2004])) 
AS Pvt ORDER BY 1
*/
 
— Execute dynamic sql query
EXEC Sp_executesql   @SQLtext
GO
/* Partial results
 
Store (Freight Summary)             2001        2002        2003        2004
Grease and Oil Products Company     104.02      555.02      726.75     272.28
Great Bicycle Supply                4430.26     3871.35     NULL        NULL
Great Bikes                         1653.89     7445.16     7525.98    584.63
Greater Bike Store                  489.79      1454.78     864.08     245.22
*/
 
-- Forming database name in dynamic SQL:
 
-- Return objects count in all databases on the server - SQL Server dynamic SQL
-- SQL Server QUOTENAME - SQL stored procedure - SQL dynamic query
USE AdventureWorks;
GO
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[dbo].[sprocAllDBsSysobjectCounts]')
                  AND TYPE IN (N'P',N'PC'))
  DROP PROCEDURE [dbo].[sprocAllDBsSysobjectCounts]
GO
 
CREATE PROC sprocAllDBsSysobjectCounts
AS
  BEGIN
      SET NOCOUNT ON
    DECLARE  @dbName      SYSNAME,
             @ObjectCount INT
    DECLARE  @SQLtext NVARCHAR(MAX)
-- SQL Server table variable
    DECLARE  @DBObjectStats  TABLE(
                                   DBName    SYSNAME,
                                   DBObjects INT
                                   )
-- SQL Server cursor
    DECLARE curAllDBs CURSOR  FOR
    SELECT   name
    FROM     MASTER.dbo.sysdatabases
-- SQL NOT IN set operator - exclude system db-s
    WHERE    name NOT IN ('master','tempdb','model','msdb')
    ORDER BY name
    
    OPEN curAllDBs
    FETCH  curAllDBs
    INTO @dbName
    WHILE (@@FETCH_STATUS = 0)  -- loop through all db-s
      BEGIN
        -- Build valid yet hard-wired SQL statement
        SET @SQLtext = 'select @dbObjects = count(*)' + char(13) + 'from ' +
         -- SQL QUOTENAME
         QUOTENAME(@dbName) + '.dbo.sysobjects'
        PRINT @SQLtext  -- Use it for debugging
/* Partial listing
 
select @dbObjects = count(*)
from [AdventureWorks].dbo.sysobjects
*/
        -- Dynamic sql call with output parameter(s)
        EXEC sp_executesql
          @SQLtext,
          N'@dbObjects int output' ,
          @dbObjects = @ObjectCount OUTPUT
        
        INSERT @DBObjectStats
        SELECT @dbName,
               @ObjectCount
        
        FETCH  curAllDBs
        INTO @dbName
      END -- while
     CLOSE curAllDBs
    DEALLOCATE curAllDBs
    -- Return results
    SELECT *
    FROM   @DBObjectStats
    ORDER BY DBName
  END -- sproc
GO
 
-- Test stored procedure - sproc
-- Execute stored procedure statement
EXEC sprocAllDBsSysobjectCounts
GO
/* Partial results
 
DBName            DBObjects
AdventureWorks    748
AdventureWorks3NF 749
AdventureWorksDW  169
AdvWorksDWX       137
Audit             48
*/
 
-- Forming schema & table id in dynamic SQL:
 
------------
-- SQL Server dbreindex fragmented indexes - using cursor, QUOTENAME & dynamic SQL
-- SQL Server BUILD indexes
-- Reindex all indexes over 35% logical fragmentation with 90% fillfactor
------------
USE AdventureWorks2008;
GO
-- Create temporary table to hold meta data information about indexes
CREATE TABLE #IndexFragmentation (
  ObjectName     CHAR(255),         ObjectId       INT,
  IndexName      CHAR(255),         IndexId        INT,
  Lvl            INT,               CountPages     INT,
  CountRows      INT,               MinRecSize     INT,
  MaxRecSize     INT,               AvgRecSize     INT,
  ForRecCount    INT,               Extents        INT,
  ExtentSwitches INT,               AvgFreeBytes   INT,
  AvgPageDensity INT,               ScanDensity    DECIMAL,
  BestCount      INT,               ActualCount    INT,
  LogicalFrag    DECIMAL,           ExtentFrag     DECIMAL)
 
INSERT #IndexFragmentation
EXEC( 'DBCC SHOWCONTIG WITH TABLERESULTS , ALL_INDEXES')
 
GO
 
DELETE #IndexFragmentation
WHERE  left(ObjectName,3) = 'sys'
GO
 
ALTER TABLE #IndexFragmentation
ADD SchemaName SYSNAME    NULL
GO
 
UPDATE [if]
SET    SchemaName = SCHEMA_NAME(schema_id)
FROM   #IndexFragmentation [if]
       INNER JOIN sys.objects o
         ON [if].ObjectName = o.name
WHERE  o.TYPE = 'U'
 
-- select * from #IndexFragmentation 
-- SQL cursor 
-- SQL dynamic SQL 
-- SQL while loop
DECLARE  @MaxFragmentation DECIMAL = 35.0
 
DECLARE  @Schema     SYSNAME,
         @Table      SYSNAME,
         @SQLtext NVARCHAR(512)
DECLARE  @objectid INT,
         @indexid  INT
DECLARE  @Fragmentation    DECIMAL
-- T-SQL cursor declaration
DECLARE curIndexFrag CURSOR  FOR
SELECT   SchemaName,
         ObjectName,
         LogicalFrag = max(LogicalFrag)
FROM     #IndexFragmentation
WHERE    LogicalFrag >= @MaxFragmentation
         AND indexid != 0
         AND indexid != 255
GROUP BY SchemaName,  ObjectName
 
OPEN curIndexFrag
FETCH NEXT FROM curIndexFrag
INTO @Schema,
     @Table,
     @Fragmentation
 
WHILE @@FETCH_STATUS = 0
  BEGIN
    -- T-SQL QUOTENAME
    SELECT @SQLtext = 'DBCC DBREINDEX (''' +
    QUOTENAME(RTRIM(@Schema)) + '.' + QUOTENAME(RTRIM(@Table)) + ''', '''', 90)'
    
    PRINT @SQLtext -- debug & test
-- Dynamic sql execution    
    EXEC( @SQLtext)
-- Alternate (new way): EXEC sp_executeSQL @SQLtext
    
    FETCH NEXT FROM curIndexFrag
    INTO @Schema,
         @Table,
         @Fragmentation
  END
CLOSE curIndexFrag
DEALLOCATE curIndexFrag
GO
 
/* Partial messages
 
DBCC DBREINDEX ('[Person].[StateProvince]', '', 90)
DBCC execution completed. If DBCC printed error messages, 
contact your system administrator.
DBCC DBREINDEX ('[Sales].[Store]', '', 90)
DBCC execution completed. If DBCC printed error messages, 
contact your system administrator.
DBCC DBREINDEX ('[Purchasing].[Vendor]', '', 90)
DBCC execution completed. If DBCC printed error messages, 
contact your system administrator.
*/
 
-- Cleanup
DROP TABLE #IndexFragmentation
GO
------------
 
-- Forming schema & sproc id in dynamic SQL:
 
------------
-- SQL Server T-SQL script generator dynamic SQL stored procedure
------------
-- SQL sproc dynamic parameter - when omitted, ALL is selected
-- SQL QUOTENAME
SET nocount  ON
USE AdventureWorks;
GO
CREATE PROCEDURE ListAllSprocsInfo
                @SchemaPattern SYSNAME  = NULL
-- set results to TEXT mode for execution
AS
  BEGIN
    SET nocount  ON
    
    DECLARE  @SQLtext NVARCHAR(4000)
    
    SET @SQLtext='SELECT ''EXEC sp_help '' +''''''''+QUOTENAME(ROUTINE_SCHEMA) +
            ''.''  + QUOTENAME(ROUTINE_NAME) +'''''''' + CHAR(13)
            FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE =''PROCEDURE'''
    
    IF @SchemaPattern IS NOT NULL
      SET @SQLtext = @SQLtext + N' AND ROUTINE_SCHEMA LIKE ''' +
            @SchemaPattern + ''''
    
    -- print @SQLtext -- test & debug
    EXEC sp_executeSQL @SQLtext
    -- EXECUTE( @SQLtext) -- old way
  END
 
GO
 
-- Execute stored procedure
-- Set Query Results to Text in Management Studio Query Editor
-- Copy and paste results to new query window for execution
EXEC ListAllSprocsInfo
GO
 
EXEC ListAllSprocsInfo   'Production'
GO
/* Partial results
 
EXEC sp_help '[dbo].[uspPrintError]'
 
EXEC sp_help '[dbo].[sprocPingLinkedServer]'
 
EXEC sp_help '[dbo].[uspLogError]'
*/
 
------------
 
-- Forming database name in dynamic SQL sproc:
 
------------
-- MSSQL assign table count in database to variable - QUOTENAME function
------------
-- Microsoft T-SQL dynamic sql stored procedure with input / output parameters
ALTER PROCEDURE uspViewCount
                @DatabaseName SYSNAME,
                @Tables       INT  OUTPUT
AS
  BEGIN
    DECLARE  @SQLtext NVARCHAR(256), @Count INT
    SET @SQLtext = N'SELECT @Count = COUNT(*) FROM ' +
                              QUOTENAME(@DatabaseName) +
                     '.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE=''VIEW'''
    PRINT @SQLtext  -- Debug & test
 /* SELECT @Count = COUNT(*) FROM [AdventureWorks2008].INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE='VIEW' */
 
    -- Dynamic SQL execution with output parameters
    EXEC sp_executesql
      @Query = @SQLtext ,
      @Params = N'@Count INT OUTPUT' ,
      @Count = @Count OUTPUT
    SET @Tables = @Count
  END
GO
 
-- Microsoft SQL Server T-SQL execute stored procedure
-- SQL Assign sproc result to variable
DECLARE  @AWtables INT
EXEC uspViewCount  'AdventureWorks2008' ,   @AWtables OUTPUT
SELECT 'AdventureWorks2008 view count' = @AWtables
GO
/* Results
 
AdventureWorks2008 view count
20
*/

------------
 
-- Forming servername in dynamic SQL sproc:
 
------------
-- Find where ProductID=3 is being used by select into from sproc execution
------------
-- SQL select into table create from sproc
-- T-SQL dynamic SQL OPENQUERY
/* 
DATA ACCESS to current instance can be setup the following way
 
exec sp_serveroption @server = 'PRODSVR\SQL2008'
      ,@optname = 'DATA ACCESS'
      ,@optvalue = 'TRUE'
 
This way, OPENQUERY can be used against current instance
(Usually OPENQUERY is used to access linked server.)     
*/
DECLARE @sqlQuery nvarchar(max) =
      'SELECT *
       INTO   BikePartsInAssembly
       FROM   OPENQUERY(' + QUOTENAME(CONVERT(sysname, @@SERVERNAME))+ ',
                ''EXECUTE [AdventureWorks2008].[dbo].[uspGetWhereUsedProductID]  3,
            ''''2003-12-01'''''')'
PRINT @sqlQuery
/*
SELECT *
       INTO   BikePartsInAssembly
       FROM   OPENQUERY([PRODSVR\SQL2008],
                'EXECUTE [AdventureWorks2008].[dbo].[uspGetWhereUsedProductID]  3,
            ''2003-12-01''')
*/
 
EXEC sp_executeSQL @sqlQuery
 
SELECT   TOP ( 5 ) *
FROM    BikePartsInAssembly
ORDER BY NEWID()
GO
 
/* Partial results
 
ProductAssemblyID ComponentID       ComponentDesc
966               996               Touring-1000 Blue, 46
762               994               Road-650 Red, 44
956               996               Touring-1000 Yellow, 54
994               3                 LL Bottom Bracket
983               994               Mountain-400-W Silver, 46
*/
-- Cleanup
DROP TABLE BikePartsInAssembly
GO
------------
 
-- Changing database context in dynamic SQL:
 
------------
-- Dynamic SQL change database context
-- Executing dynamic SQL in a different database - USE dbname workaround
------------
USE AdventureWorks2008;
DECLARE @SQL nvarchar(max) = 'SELECT Tables=count(*) FROM sys.tables'
DECLARE @dbName sysname = 'AdventureWorks'
DECLARE @dbContext nvarchar(256)=@dbName+'.dbo.'+'sp_executeSQL'
EXEC @dbContext @SQL
-- 72
------------

------------
-- Nested dynamic SQL - create database object in another database
------------
USE AdventureWorks2008;
GO
 
CREATE PROCEDURE sprocAlpha  @DatabaseName SYSNAME
AS
  BEGIN
    SET NOCOUNT  ON
    IF NOT EXISTS (SELECT 1 FROM sys.databases    -- SQL Injection attack prevention
                   WHERE name=@DatabaseName)      -- Filter & user input
      RETURN (0)
    DECLARE  @SQL       NVARCHAR(MAX),
             @nestedSQL NVARCHAR(MAX)
    SET @nestedSQL = 'CREATE FUNCTION fnAlpha (@text varchar(16))                   
                      RETURNS varchar(64)     AS                   
                      BEGIN                     
                        DECLARE @output varchar(64)                    
                        SET @output = @text+''/''+@text                    
                        RETURN (@output)                  
                      END'
    SET @nestedSQL = REPLACE(@nestedSQL,char(39),char(39) + CHAR(39))
    PRINT @nestedSQL
    SET @SQL = 'EXEC ' + @DatabaseName + '..sp_executeSQL N''' + @nestedSQL + ''''
    PRINT @SQL
    EXEC sp_executeSQL   @SQL
    RETURN (1)
  END
GO
 
EXEC sprocAlpha   'pubs'
GO
 
SELECT pubs.dbo.fnAlpha('London')
-- London/London
 
------------
-- Nested dynamic SQL - change database context - USE usage
------------
USE AdventureWorks2008;
DECLARE @SQL nvarchar(max)='use Northwind;
DECLARE @nestedSQL nvarchar(max)= ''create trigger trgEmpInsert
  on Employees
  for insert
  as
  begin
    select LinesInserted = count(*) from inserted
  end
'';
PRINT @nestedSQL
EXEC sp_executesql @nestedSQL;'
PRINT @SQL -- test & debug
EXEC sp_executesql @SQL
GO
 
-- Cleanup
USE Northwind; DROP TRIGGER trgEmpInsert;
------------
 
-- Default & parameterized use of QUOTENAME:
/* Typically square brackets (in dynamic SQL queries), single quotes and double quotes are used with QUOTENAME. */
 
-- SQL QUOTENAME default usage - SQL brackets - SQL square brackets
select QUOTENAME('Factory Order Detail')
-- Result: [Factory Order Detail]
 
-- SQL QUOTENAME equivalent use - MSSQL server quote name - bracketing name
select QUOTENAME('Factory Order Detail','[]')
-- Result: [Factory Order Detail]
 
-- The second argument is: single quote, double quote, single quote
select QUOTENAME('Factory Order Detail','"')
-- Result: "Factory Order Detail"
 
select QUOTENAME('Factory Order Detail','()')
-- Result: (Factory Order Detail)

-- Search wildcard preparation to be used in dynamic SQL text search
DECLARE @SearchKeyword nvarchar(32) = 'O''Reilly'
DECLARE @SearchWildcard nvarchar(32) =
        QUOTENAME('%' + @SearchKeyword + '%',CHAR(39)+CHAR(39))
PRINT @SearchKeyword
PRINT @SearchWildcard
/*
O'Reilly
'%O''Reilly%'
*/
------------