-- Get date only from datetime - QUICK SYNTAX
SELECT DATEADD(dd, 0, DATEDIFF(dd, 0, CURRENT_TIMESTAMP)) -- 2016-10-23 00:00:00.000
------------
-- SQL Server T-SQL date & datetime formats - Gregorian calendar - Christian calendar 
-- getdate() / CURRENT_TIMESTAMP(ANSI) returns system date & time in standard format
-- SQL datetime formats with century (YYYY or CCYY format)- sql date & time format 
SELECT convert(varchar, getdate(), 100) -- mon dd yyyy hh:mmAM (or PM)                                        -- Oct  2 2010 11:01AM          
SELECT convert(varchar, getdate(), 101) -- mm/dd/yyyy - 10/02/2010                  
SELECT convert(varchar, getdate(), 102) -- yyyy.mm.dd - 2010.10.02           
SELECT convert(varchar, getdate(), 103) -- dd/mm/yyyy
SELECT convert(varchar, getdate(), 104) -- dd.mm.yyyy
SELECT convert(varchar, getdate(), 105) -- dd-mm-yyyy
SELECT convert(varchar, getdate(), 106) -- dd mon yyyy
SELECT convert(varchar, getdate(), 107) -- mon dd, yyyy
SELECT convert(varchar, getdate(), 108) -- hh:mm:ss
SELECT convert(varchar, getdate(), 109) -- mon dd yyyy hh:mm:ss:mmmAM (or PM)
                                        -- Oct  2 2010 11:02:44:013AM   
SELECT convert(varchar, getdate(), 110) -- mm-dd-yyyy
SELECT convert(varchar, getdate(), 111) -- yyyy/mm/dd
-- yyyymmdd - ISO date format - international standard - works with any language setting
SELECT convert(varchar, getdate(), 112) -- yyyymmdd
SELECT convert(varchar, getdate(), 113) -- dd mon yyyy hh:mm:ss:mmm
                                        -- 02 Oct 2010 11:02:07:577     
SELECT convert(varchar, getdate(), 114) -- hh:mm:ss:mmm(24h)
SELECT convert(varchar, getdate(), 120) -- yyyy-mm-dd hh:mm:ss(24h)
SELECT convert(varchar, getdate(), 121) -- yyyy-mm-dd hh:mm:ss.mmm
SELECT convert(varchar, getdate(), 126) -- yyyy-mm-ddThh:mm:ss.mmm - ISO8601
                                        -- 2010-10-02T10:52:47.513
SELECT convert(varchar, getdate(), 127) -- yyyy-mm-ddThh:mm:ss.mmmZ - with time zone
SELECT convert(nvarchar(64), getdate(), 130) -- Arabic Hijri date
-- 29 جمادى الاولى 1433 1:13:04:633AM:
SELECT convert(nvarchar, getdate(), 131) -- Arabic Hijri date - Islamic calendar
-- 29/05/1433 12:57:26:690AM

-- Without century (YY) date / datetime conversion - there are exceptions!
SELECT convert(varchar, getdate(), 0)   -- mon dd yyyy hh:mmAM (or PM)
SELECT convert(varchar, getdate(), 1)   -- mm/dd/yy
SELECT convert(varchar, getdate(), 2)   -- yy.mm.dd          
SELECT convert(varchar, getdate(), 3)   -- dd/mm/yy
SELECT convert(varchar, getdate(), 4)   -- dd.mm.yy
SELECT convert(varchar, getdate(), 5)   -- dd-mm-yy
SELECT convert(varchar, getdate(), 6)   -- dd mon yy
SELECT convert(varchar, getdate(), 7)   -- mon dd, yy
SELECT convert(varchar, getdate(), 8)   -- hh:mm:ss
SELECT convert(varchar, getdate(), 9)   -- mon dd yyyy hh:mm:ss:mmmAM (or PM)
SELECT convert(varchar, getdate(), 10)  -- mm-dd-yy
SELECT convert(varchar, getdate(), 11)  -- yy/mm/dd
SELECT convert(varchar, getdate(), 12)  -- yymmdd
SELECT convert(varchar, getdate(), 13)  -- dd mon yyyy hh:mm:ss:mmm
SELECT convert(varchar, getdate(), 14)  -- hh:mm:ss:mmm(24h)
SELECT convert(varchar, getdate(), 20)  -- yyyy-mm-dd hh:mm:ss(24h)
SELECT convert(varchar, getdate(), 21)  -- yyyy-mm-dd hh:mm:ss.mmm
SELECT convert(varchar, getdate(), 22)  -- mm/dd/yy hh:mm:ss AM (or PM)
SELECT convert(varchar, getdate(), 23)  -- yyyy-mm-dd
SELECT convert(varchar, getdate(), 24)  -- hh:mm:ss
SELECT convert(varchar, getdate(), 25)  -- yyyy-mm-dd hh:mm:ss.mmm 
-- SQL create different date styles with t-sql string functions
SELECT replace(convert(varchar, getdate(), 111), '/', ' ') -- yyyy mm dd
SELECT convert(varchar(7), getdate(), 126)                 -- yyyy-mm
SELECT right(convert(varchar, getdate(), 106), 8)          -- mon yyyy
SELECT substring(convert(varchar, getdate(), 120),6, 11)   -- mm-dd hh:mm
----------

-- Current (today) midnight calculation - remove time part of datetime
-- Today's date without time - datetime without time
DECLARE @CurrentMidnight datetime =
      dateadd(day, datediff(day,0, CURRENT_TIMESTAMP), 0)
SELECT @CurrentMidnight
-- 2012-03-15 00:00:00.000
----------

------------
-- SQL Server date formatting function - convert datetime to string
------------
-- SQL datetime functions - SQL date functions - SQL server datetime formatting
-- T-SQL convert dates - T-SQL date formats - Transact-SQL date formats
CREATE FUNCTION dbo.fnFormatDate (@Datetime DATETIME, @FormatMask VARCHAR(32))
RETURNS VARCHAR(32)
AS
BEGIN
    DECLARE @StringDate VARCHAR(32)
    SET @StringDate = @FormatMask
    IF (CHARINDEX ('YYYY',@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, 'YYYY', DATENAME(YY, @Datetime))
    IF (CHARINDEX ('YY',@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, 'YY', RIGHT(DATENAME(YY, @Datetime),2))
    IF (CHARINDEX ('Month',@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, 'Month', DATENAME(MM, @Datetime))
    IF (CHARINDEX ('MON',@StringDate COLLATE SQL_Latin1_General_CP1_CS_AS)>0)
       SET @StringDate = REPLACE(@StringDate, 'MON',
                         LEFT(UPPER(DATENAME(MM, @Datetime)),3))
    IF (CHARINDEX ('Mon',@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, 'Mon', LEFT(DATENAME(MM, @Datetime),3))
    IF (CHARINDEX ('MM',@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, 'MM',
                  RIGHT('0'+CONVERT(VARCHAR,DATEPART(MM, @Datetime)),2))
    IF (CHARINDEX ('M',@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, 'M',
                         CONVERT(VARCHAR,DATEPART(MM, @Datetime)))
    IF (CHARINDEX ('DD',@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, 'DD',
                         RIGHT('0'+DATENAME(DD, @Datetime),2))
    IF (CHARINDEX ('D',@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, 'D', DATENAME(DD, @Datetime))   
RETURN @StringDate
END
GO
 
-- Microsoft SQL Server date format function test - MSSQL formatting date - sql datetime
SELECT dbo.fnFormatDate (getdate(), 'MM/DD/YYYY')           -- 01/03/2012
SELECT dbo.fnFormatDate (getdate(), 'DD/MM/YYYY')           -- 03/01/2012
SELECT dbo.fnFormatDate (getdate(), 'M/DD/YYYY')            -- 1/03/2012
SELECT dbo.fnFormatDate (getdate(), 'M/D/YYYY')             -- 1/3/2012
SELECT dbo.fnFormatDate (getdate(), 'M/D/YY')               -- 1/3/12
SELECT dbo.fnFormatDate (getdate(), 'MM/DD/YY')             -- 01/03/12
SELECT dbo.fnFormatDate (getdate(), 'MON DD, YYYY')         -- JAN 03, 2012
SELECT dbo.fnFormatDate (getdate(), 'Mon DD, YYYY')         -- Jan 03, 2012
SELECT dbo.fnFormatDate (getdate(), 'Month DD, YYYY')       -- January 03, 2012
SELECT dbo.fnFormatDate (getdate(), 'YYYY/MM/DD')           -- 2012/01/03
SELECT dbo.fnFormatDate (getdate(), 'YYYYMMDD')             -- 20120103
SELECT dbo.fnFormatDate (getdate(), 'YYYY-MM-DD')           -- 2012-01-03
-- CURRENT_TIMESTAMP returns current system date and time in standard internal format
SELECT dbo.fnFormatDate (CURRENT_TIMESTAMP,'YY.MM.DD')      -- 12.01.03

-- Convert date into integer format
DECLARE @date as DATETIME = CURRENT_TIMESTAMP;
SELECT CONVERT(int, CONVERT(char(8), @date, 112)) AS DateInt
-- 20120312
------------

/***** SELECTED SQL DATE/DATETIME FORMATS WITH NAMES *****/
 
-- SQL format datetime - - sql hh mm ss - sql yyyy mm dd
-- Default format: Oct 23 2006 10:40AM
SELECT [Default]=CONVERT(varchar,GETDATE(),100)
 
-- US-Style format: 10/23/2006
SELECT [US-Style]=CONVERT(char,GETDATE(),101)
 
-- ANSI format: 2006.10.23
SELECT [ANSI]=CONVERT(char,CURRENT_TIMESTAMP,102)
 
-- UK-Style format: 23/10/2006
SELECT [UK-Style]=CONVERT(char,GETDATE(),103)
 
-- German format: 23.10.2006
SELECT [German]=CONVERT(varchar,GETDATE(),104)
 
-- ISO format: 20061023
SELECT ISO=CONVERT(varchar,GETDATE(),112)
 
-- ISO8601 format: 2010-10-23T19:20:16.003
SELECT [ISO8601]=CONVERT(varchar,GETDATE(),126)
------------
 
------------
-- Islamic date conversion
------------
-- Gregorian date
SELECT CONVERT(VARCHAR(36), GETDATE(), 109)
-- Mar 17 2012  9:27:19:027PM
-- Islamic / Hijri date
SELECT CONVERT(NVARCHAR(36), GETDATE(), 130)
-- 24 ربيع الثاني 1433  9:27:19:030PM
SELECT CONVERT(VARCHAR(36), GETDATE(), 131)
-- 24/04/1433  9:27:19:030PM
------------
 
-- SQL Server datetime formats - Format dates SQL Server 2005 / 2008 
-- Century date format MM/DD/YYYY usage in a query
SELECT TOP (1)
      SalesOrderID,
      OrderDate = CONVERT(char(10), OrderDate, 101),
      OrderDateTime = OrderDate
FROM AdventureWorks.Sales.SalesOrderHeader
/*
SalesOrderID      OrderDate               OrderDateTime
43697             07/01/2001          2001-07-01 00:00:00.000
*/
 
-- SQL update datetime column - SQL datetime DATEADD - datetime function
UPDATE Production.Product
SET ModifiedDate=DATEADD(dd,1, ModifiedDate)
WHERE ProductID = 1001

 
-- MM/DD/YY date format - Datetime format sql
SELECT TOP (1)
      SalesOrderID,
      OrderDate = CONVERT(varchar(8), OrderDate, 1),
      OrderDateTime = OrderDate
FROM AdventureWorks.Sales.SalesOrderHeader
ORDER BY SalesOrderID desc
/*
SalesOrderID      OrderDate         OrderDateTime
75123             07/31/04          2004-07-31 00:00:00.000
*/
------------
 
-- Converting UNIX timestamp to datetime
DECLARE @Date  BIGINT = 1477180800
/* (UNIX time = 1477180800 --> midnight, OCT 23, 2016) */
SELECT DATEADD(ss, @Date, '19700101')
-- 2016-10-23 00:00:00.000
------------
  
-- SQL convert datetime to char - sql date string concatenation: + (plus) operator
PRINT 'Style 110: '+CONVERT(CHAR(10),GETDATE(),110)         -- Style 110: 07-10-2012
PRINT 'Style 111: '+CONVERT(CHAR(10),GETDATE(),111)         -- Style 111: 2012/07/10
PRINT 'Style 112: '+CONVERT(CHAR(8), GETDATE(),112)         -- Style 112: 20120710   
------------

-- Combining different style formats for date & time
-- Datetime formats - sql times format - datetime formats sql
DECLARE @Date DATETIME
SET @Date = '2015-12-22 03:51 PM'
SELECT CONVERT(CHAR(10),@Date,110) + SUBSTRING(CONVERT(varchar,@Date,0),12,8)
-- Result: 12-22-2015  3:51PM

 
-- Microsoft SQL Server cast datetime to string
SELECT stringDateTime=CAST (getdate() as varchar)
-- Result: Dec 29 2012  3:47AM

------------
-- SQL Server date and time functions overview
------------
-- SQL Server CURRENT_TIMESTAMP function - SQL Server datetime functions
-- Local NYC - EST - Eastern Standard Time zone
-- SQL DATEADD function - SQL DATEDIFF function
SELECT CURRENT_TIMESTAMP                        -- 2012-01-05 07:02:10.577
-- SQL Server DATEADD function
SELECT DATEADD(month,2,'2012-12-09')            -- 2013-02-09 00:00:00.000
-- SQL Server DATEDIFF function
SELECT DATEDIFF(day,'2012-12-09','2013-02-09')  -- 62
-- SQL Server DATENAME function
SELECT DATENAME(month,   '2012-12-09')          -- December
SELECT DATENAME(weekday, '2012-12-09')          -- Sunday
-- SQL Server DATEPART function
SELECT DATEPART(month, '2012-12-09')            -- 12
-- SQL Server DAY function
SELECT DAY('2012-12-09')                        -- 9
-- SQL Server GETDATE function
-- local NYC - EST - Eastern Standard Time zone
SELECT GETDATE()                                -- 2012-01-05 07:02:10.577
-- SQL Server GETUTCDATE function
-- London - Greenwich Mean Time
SELECT GETUTCDATE()                             -- 2012-01-05 12:02:10.577
-- SQL Server MONTH function
SELECT MONTH('2012-12-09')                      -- 12
-- SQL Server YEAR function
SELECT YEAR('2012-12-09')                       -- 2012
 
Technical Job Search: CLICK HERE FOR HIGH PAID JOBS!

------------
-- Universal CONVERT function - datetime conversion UDF
------------
CREATE FUNCTION fnCONVERT( @Input datetimeoffset, @StyleNo int)
RETURNS nvarchar(35)  AS
BEGIN
  RETURN (CONVERT(nvarchar(35), @Input, @StyleNo))
END
GO
 
DECLARE @dt DATE=getdate(); SELECT dbo.fnCONVERT( @dt,106) -- 23 Dec 2010
GO
DECLARE @dt DATE=getdate(); SELECT dbo.fnCONVERT( @dt,156) -- 23 Dec 2010
GO
/* Msg 281, Level 16, State 1, Line 1
156 is not a valid style number when converting from datetimeoffset
to a character string. */
DECLARE @dt DATETIME=getdate(); SELECT dbo.fnCONVERT( @dt,112) -- 20101223
GO
DECLARE @dt SMALLDATETIME=getdate(); SELECT dbo.fnCONVERT( @dt,101) -- 12/23/2010
GO
------------

------------
-- SQL calculate the number of business days function - exclude Saturdays & Sundays
------------
CREATE FUNCTION fnBusinessDaysCount (@StartDate DATE, @EndDate  DATE)
RETURNS INT AS
  BEGIN
    IF (@StartDate IS NULL OR @EndDate IS NULL)  RETURN (0)
    DECLARE  @i INT = 0;
    WHILE (@StartDate <= @EndDate)
      BEGIN
        SET @i = @i + CASE
                        WHEN datepart(dw,@StartDate) BETWEEN 2 AND 6 THEN 1
                        ELSE 0
                      END 
        SET @StartDate = DATEADD(dd,1,@StartDate)
      END  -- while 
    RETURN (@i)
  END -- function
GO
SELECT dbo.fnBusinessDaysCount('2016-01-01','2016-12-31')
-- 261
------------

------------
-- T-SQL Date and time function application
-- CURRENT_TIMESTAMP and getdate() are the same in T-SQL
------------
-- T-SQL first day of week and last day of week
SELECT FirstDateOfWeek = dateadd(dd,-DATEPART(dw,GETDATE()) + 1,GETDATE())
SELECT LastDateOfWeek = dateadd(dd,7 - DATEPART(dw,GETDATE()),GETDATE())

-- SQL first day of the month - SQL first date of the month
-- SQL first day of current month - 2012-01-01 00:00:00.000
SELECT DATEADD(dd,0,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP),0))
-- SQL last day of the month - SQL last date of the month
-- SQL last day of current month - 2012-01-31 00:00:00.000
SELECT DATEADD(dd,-1,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP)+1,0))
-- SQL first day of last month
-- SQL first day of previous month - 2011-12-01 00:00:00.000
SELECT DATEADD(mm,-1,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP),0))
-- SQL last day of last month
-- SQL last day of previous month - 2011-12-31 00:00:00.000
SELECT DATEADD(dd,-1,DATEADD(mm, DATEDIFF(mm,0,DATEADD(MM,-1,GETDATE()))+1,0))
-- SQL first day of next month - 2012-02-01 00:00:00.000
SELECT DATEADD(mm,1,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP),0))
-- SQL last day of next month - 2012-02-28 00:00:00.000
SELECT DATEADD(dd,-1,DATEADD(mm, DATEDIFF(mm,0,DATEADD(MM,1,GETDATE()))+1,0))
GO
-- SQL first day of a month - 2012-10-01 00:00:00.000
DECLARE @Date datetime; SET @Date = '2012-10-23'
SELECT DATEADD(dd,0,DATEADD(mm, DATEDIFF(mm,0,@Date),0))
GO
-- SQL last day of a month - 2012-03-31 00:00:00.000
DECLARE @Date datetime; SET @Date = '2012-03-15'
SELECT DATEADD(dd,-1,DATEADD(mm, DATEDIFF(mm,0,@Date)+1,0))
GO
-- SQL first day of year - SQL first day of the year - 2012-01-01 00:00:00.000
SELECT DATEADD(yy, DATEDIFF(yy,0,CURRENT_TIMESTAMP), 0)
-- SQL last day of year - SQL last day of the year - 2012-12-31 00:00:00.000
SELECT DATEADD(yy,1, DATEADD(dd, -1, DATEADD(yy,
                     DATEDIFF(yy,0,CURRENT_TIMESTAMP), 0)))
-- SQL last day of last year - SQL last day of previous year - 2011-12-31 00:00:00.000
SELECT DATEADD(dd,-1,DATEADD(yy,DATEDIFF(yy,0,CURRENT_TIMESTAMP), 0))
GO
------------
 
-- First and last day of date periods
DECLARE @Date DATETIME; SET = @Date = '20161023';
SELECT ReferenceDate      = @Date 
SELECT FirstDayOfYear     = DATEADD(YY, DATEDIFF(YY,0, @Date),0)
SELECT LastDayOfYear      = DATEADD(YY, DATEDIFF(YY,0, @Date)+1,-1)
SELECT FirstDayOfSemester = DATEADD(QQ,((DATEDIFF(QQ,0,@Date)/2)*2),0)
SELECT LastDayOfSemester  = DATEADD(QQ,((DATEDIFF(QQ,0,@Date)/2)*2)+2,-1)
SELECT FirstDayOfQuarter  = DATEADD(QQ, DATEDIFF(QQ,0, @Date),0)
-- 2016-10-01 00:00:00.000
SELECT LastDayOfQuarter   = DATEADD(QQ, DATEDIFF(QQ,0, @Date)+1,-1)
-- 2016-12-31 00:00:00.000
SELECT FirstDayOfMonth    = DATEADD(MM, DATEDIFF(MM,0, @Date),0)
SELECT LastDayOfMonth     = DATEADD(MM, DATEDIFF(MM,0, @Date)+1,-1)
SELECT FirstDayOfWeek     = DATEADD(WK, DATEDIFF(WK,0, @Date),0)
SELECT LastDayOfWeek      = DATEADD(WK, DATEDIFF(WK,0, @Date)+1,-1)
-- 2016-10-30 00:00:00.000
------------

-- Start of week SUNDAY - US_english language setting -
SELECT CURRENT_TIMESTAMP, DATEADD (week, DATEDIFF(week,6, CURRENT_TIMESTAMP),6)
-- End of week SATURDAY
SELECT CURRENT_TIMESTAMP, DATEADD (week, DATEDIFF(week,5, CURRENT_TIMESTAMP),5)

-- SQL calculate age in years, months, days - Format dates SQL Server 2008
-- SQL table-valued function - SQL user-defined function - UDF
-- SQL Server age calculation - date difference
USE AdventureWorks2008;
GO
CREATE FUNCTION fnAge  (@BirthDate DATETIME)
RETURNS @Age TABLE(Years  INT,
                   Months INT,
                   Days   INT)
AS
  BEGIN
    DECLARE  @EndDate     DATETIME, @Anniversary DATETIME
    SET @EndDate = Getdate()
    SET @Anniversary = Dateadd(yy,Datediff(yy,@BirthDate,@EndDate),@BirthDate)
    INSERT @Age
    SELECT Datediff(yy,@BirthDate,@EndDate) - (CASE
                                                 WHEN @Anniversary > @EndDate THEN 1
                                                 ELSE 0
                                               END), 0, 0
     UPDATE @Age     SET    Months = Month(@EndDate - @Anniversary) - 1
    UPDATE @Age     SET    Days = Day(@EndDate - @Anniversary) - 1
    RETURN
  END
GO
 
-- Test table-valued UDF
SELECT * FROM   fnAge('1956-10-23')
SELECT * FROM   dbo.fnAge('1956-10-23')
/* Results
Years       Months      Days
52          4           1
*/

 
----------
-- SQL date range between
----------
-- SQL between dates
USE AdventureWorks;
-- SQL between
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate BETWEEN '20040301' AND '20040315'
-- Result: 108
 
-- BETWEEN operator is equivalent to >=...AND....<=
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate
BETWEEN '2004-03-01 00:00:00.000' AND '2004-03-15  00:00:00.000'
/*
Orders with OrderDates
'2004-03-15  00:00:01.000'  - 1 second after midnight (12:00AM)
'2004-03-15  00:01:00.000'  - 1 minute after midnight
'2004-03-15  01:00:00.000'  - 1 hour after midnight
 
are not included in the two queries above.
*/
-- To include the entire day of 2004-03-15 use the following two solutions
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate >= '20040301' AND OrderDate < '20040316'
 
-- SQL between with DATE type (SQL Server 2008)
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE CONVERT(DATE, OrderDate) BETWEEN '20040301' AND '20040315'
----------

-- Non-standard format conversion: 2011 December 14
-- SQL datetime to string
SELECT [YYYY Month DD] =
CAST(YEAR(GETDATE()) AS VARCHAR(4))+ ' '+
DATENAME(MM, GETDATE()) + ' ' +
CAST(DAY(GETDATE()) AS VARCHAR(2))
 
-- Converting datetime to YYYYMMDDHHMMSS format: 20121214172638
SELECT replace(convert(varchar, getdate(),111),'/','') +
replace(convert(varchar, getdate(),108),':','')
 
-- Datetime custom format conversion to YYYY_MM_DD
select CurrentDate=rtrim(year(getdate())) + '_' +
right('0' + rtrim(month(getdate())),2) + '_' +
right('0' + rtrim(day(getdate())),2)
 
-- Converting seconds to HH:MM:SS format
declare @Seconds int
set @Seconds = 10000
select TimeSpan=right('0' +rtrim(@Seconds / 3600),2) + ':' +
right('0' + rtrim((@Seconds % 3600) / 60),2) + ':' +
right('0' + rtrim(@Seconds % 60),2)
-- Result: 02:46:40
 
-- Test result
select 2*3600 + 46*60 + 40
-- Result: 10000

-- Set the time portion of a datetime value to 00:00:00.000
-- SQL strip time from date
-- SQL strip time from datetime
SELECT CURRENT_TIMESTAMP ,DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)
-- Results: 2014-01-23 05:35:52.793 2014-01-23 00:00:00.000

/* VALID DATE RANGES FOR DATE/DATETIME DATA TYPES
 
SMALLDATETIME (4 bytes) date range:
January 1, 1900 through June 6, 2079
 
DATETIME (8 bytes) date range:
January 1, 1753 through December 31, 9999
 
DATETIME2 (8 bytes) date range (SQL Server 2008):
January 1,1 AD through December 31, 9999 AD
 
DATE (3 bytes) date range (SQL Server 2008):
January 1, 1 AD through December 31, 9999 AD
 
*******/

-- Selecting with CONVERT into different styles
-- Note: Only Japan & ISO styles can be used in ORDER BY
SELECT TOP(1)
     Italy  = CONVERT(varchar, OrderDate, 105)
   , USA    = CONVERT(varchar, OrderDate, 110)
   , Japan  = CONVERT(varchar, OrderDate, 111)
   , ISO    = CONVERT(varchar, OrderDate, 112)
FROM AdventureWorks.Purchasing.PurchaseOrderHeader
ORDER BY PurchaseOrderID DESC
/* Results
Italy       USA         Japan       ISO
25-07-2004  07-25-2004  2004/07/25  20040725
*/

-- SQL Server convert date to integer
DECLARE @Datetime datetime
SET @Datetime = '2012-10-23 10:21:05.345'
SELECT DateAsInteger = CAST (CONVERT(varchar,@Datetime,112) as INT)
-- Result: 20121023
 
-- SQL Server convert integer to datetime
DECLARE @intDate int
SET @intDate = 20120315
SELECT IntegerToDatetime = CAST(CAST(@intDate as varchar) as datetime)
-- Result: 2012-03-15 00:00:00.000

-------------
-- Julian date (YYYYDDD) to date / datetime converter
------------
CREATE FUNCTION dbo.fnJulianToDate (@JulianDt char(7))
RETURNS date AS
BEGIN
    RETURN (SELECT DATEADD(day, CAST(RIGHT(@JulianDt,3) AS int) - 1,
    CONVERT(datetime, LEFT(@JulianDt,4) + '0101', 112)))
END
GO
SELECT dbo.fnJulianToDate ('2016040')
-- 2016-02-09
------------

-----------
-- SQL Server CONVERT script applying table INSERT/UPDATE
------------
-- SQL Server convert date
-- Datetime column is converted into date only string column
USE tempdb;
GO
CREATE TABLE sqlConvertDateTime   (
            DatetimeCol datetime,
            DateCol char(8));
INSERT sqlConvertDateTime (DatetimeCol) SELECT GETDATE()
 
UPDATE sqlConvertDateTime
SET DateCol = CONVERT(char(10), DatetimeCol, 112)
SELECT * FROM sqlConvertDateTime
 
-- SQL Server convert datetime
-- The string date column is converted into datetime column
UPDATE sqlConvertDateTime
SET DatetimeCol = CONVERT(Datetime, DateCol, 112)
SELECT * FROM sqlConvertDateTime
 
-- Adding a day to the converted datetime column with DATEADD
UPDATE sqlConvertDateTime
SET DatetimeCol = DATEADD(day, 1, CONVERT(Datetime, DateCol, 112))
SELECT * FROM sqlConvertDateTime
 
-- Equivalent formulation - SQL Server CAST datetime
UPDATE sqlConvertDateTime
SET DatetimeCol = DATEADD(dd, 1, CAST(DateCol AS datetime))
SELECT * FROM sqlConvertDateTime
GO
DROP TABLE sqlConvertDateTime
GO
/* First results
DatetimeCol                   DateCol
2014-12-25 16:04:15.373       20141225 */
 
/* Second results:
DatetimeCol                   DateCol
2014-12-25 00:00:00.000       20141225  */
 
/* Third results:
DatetimeCol                   DateCol
2014-12-26 00:00:00.000       20141225  */
------------

-- SQL month sequence - SQL date sequence generation with table variable
-- SQL Server cast string to datetime - SQL Server cast datetime to string
-- SQL Server insert default values method
DECLARE @Sequence table (Sequence int identity(1,1))
DECLARE @i int; SET @i = 0
DECLARE @StartDate datetime;
SET @StartDate = CAST(CONVERT(varchar, year(getdate()))+
                 RIGHT('0'+convert(varchar,month(getdate())),2) + '01' AS DATETIME)
WHILE ( @i < 120)
BEGIN
      INSERT @Sequence DEFAULT VALUES
      SET @i = @i + 1
END
SELECT MonthSequence = CAST(DATEADD(month, Sequence,@StartDate) AS varchar)
FROM @Sequence
GO
/* Partial results:
MonthSequence
Jan  1 2012 12:00AM
Feb  1 2012 12:00AM
Mar  1 2012 12:00AM
Apr  1 2012 12:00AM
*/
------------
 
 ------------
-- SQL Server Server datetime internal storage - SQL Server datetime formats
------------
-- SQL Server datetime to hex
SELECT Now=CURRENT_TIMESTAMP, HexNow=CAST(CURRENT_TIMESTAMP AS BINARY(8))
/* Results
 
Now                     HexNow
2009-01-02 17:35:59.297 0x00009B850122092D
*/
-- SQL Server date part - left 4 bytes - Days since 1900-01-01
SELECT Now=DATEADD(DAY, CONVERT(INT, 0x00009B85), '19000101')
GO
-- Result: 2009-01-02 00:00:00.000
 
-- SQL time part - right 4 bytes - milliseconds since midnight
-- 1000/300 is an adjustment factor
-- SQL dateadd to Midnight
SELECT Now=DATEADD(MS, (1000.0/300)* CONVERT(BIGINT, 0x0122092D), '2009-01-02')
GO
-- Result: 2009-01-02 17:35:59.290
------------

------------
-- String date and datetime date&time columns usage
-- SQL Server datetime formats in tables
------------
USE tempdb;
SET NOCOUNT ON;
-- SQL Server select into table create
SELECT TOP (5)
      FullName=convert(nvarchar(50),FirstName+' '+LastName),
      BirthDate = CONVERT(char(8), BirthDate,112),
      ModifiedDate = getdate()
INTO Employee
FROM AdventureWorks.HumanResources.Employee e
INNER JOIN AdventureWorks.Person.Contact c
ON c.ContactID = e.ContactID
ORDER BY EmployeeID
GO
-- SQL Server alter table
ALTER TABLE Employee ALTER COLUMN FullName nvarchar(50) NOT NULL
GO
ALTER TABLE Employee
ADD CONSTRAINT [PK_Employee] PRIMARY KEY (FullName )
GO
/* Results
 
Table definition for the Employee table
Note: BirthDate is string date (only)
 
CREATE TABLE dbo.Employee(
      FullName nvarchar(50) NOT NULL PRIMARY KEY,
      BirthDate char(8) NULL,
      ModifiedDate datetime NOT NULL
      )
*/
SELECT * FROM Employee ORDER BY FullName
GO
/* Results
FullName                BirthDate   ModifiedDate
Guy Gilbert             19720515    2009-01-03 10:10:19.217
Kevin Brown             19770603    2009-01-03 10:10:19.217
Rob Walters             19650123    2009-01-03 10:10:19.217
Roberto Tamburello      19641213    2009-01-03 10:10:19.217
Thierry D'Hers          19490829    2009-01-03 10:10:19.217
*/
 
-- SQL Server age
SELECT FullName, Age = DATEDIFF(YEAR, BirthDate, GETDATE()),
       RowMaintenanceDate = CAST (ModifiedDate AS varchar)
FROM Employee ORDER BY FullName
GO
/* Results
FullName                Age   RowMaintenanceDate
Guy Gilbert             37    Jan  3 2009 10:10AM
Kevin Brown             32    Jan  3 2009 10:10AM
Rob Walters             44    Jan  3 2009 10:10AM
Roberto Tamburello      45    Jan  3 2009 10:10AM
Thierry D'Hers          60    Jan  3 2009 10:10AM
*/
 
-- SQL Server age of Rob Walters on specific dates
-- SQL Server string to datetime implicit conversion with DATEADD
SELECT AGE50DATE = DATEADD(YY, 50, '19650123')
GO
-- Result: 2015-01-23 00:00:00.000
 
-- SQL Server datetime to string, Italian format for ModifiedDate
-- SQL Server string to datetime implicit conversion with DATEDIFF
SELECT FullName,
         AgeDEC31 = DATEDIFF(YEAR, BirthDate, '20141231'),
         AgeJAN01 = DATEDIFF(YEAR, BirthDate, '20150101'),
         AgeJAN23 = DATEDIFF(YEAR, BirthDate, '20150123'),
         AgeJAN24 = DATEDIFF(YEAR, BirthDate, '20150124'),
       ModDate = CONVERT(varchar, ModifiedDate, 105)
FROM Employee
WHERE FullName = 'Rob Walters'
ORDER BY FullName
GO
/* Results
Important Note: age increments on Jan 1 (not as commonly calculated)
 
FullName    AgeDEC31    AgeJAN01    AgeJAN23    AgeJAN24    ModDate
Rob Walters 49          50          50          50          03-01-2009 */
 
------------
-- SQL combine integer date & time into datetime
------------
-- Datetime format sql
-- SQL stuff
DECLARE @DateTimeAsINT TABLE ( ID int identity(1,1) primary key, 
   DateAsINT int, 
   TimeAsINT int 
) 
-- NOTE: leading zeroes in time is for readability only!  
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 235959)  
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 010204)  
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 002350)
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 000244)  
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 000050)  
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 000006)  
 
SELECT DateAsINT, TimeAsINT,
  CONVERT(datetime, CONVERT(varchar(8), DateAsINT) + ' '+
  STUFF(STUFF ( RIGHT(REPLICATE('0', 6) + CONVERT(varchar(6), TimeAsINT), 6),
                  3, 0, ':'), 6, 0, ':'))  AS DateTimeValue
FROM   @DateTimeAsINT 
ORDER BY ID
GO
/* Results
DateAsINT   TimeAsINT   DateTimeValue
20121023    235959      2012-10-23 23:59:59.000
20121023    10204       2012-10-23 01:02:04.000
20121023    2350        2012-10-23 00:23:50.000
20121023    244         2012-10-23 00:02:44.000
20121023    50          2012-10-23 00:00:50.000
20121023    6           2012-10-23 00:00:06.000
*/
------------

-- SQL Server string to datetime, implicit conversion with assignment
UPDATE Employee SET ModifiedDate = '20150123'
WHERE FullName = 'Rob Walters'
GO
SELECT ModifiedDate FROM Employee WHERE FullName = 'Rob Walters'
GO
-- Result: 2015-01-23 00:00:00.000
 
/* SQL string date, assemble string date from datetime parts  */
-- SQL Server cast string to datetime - sql convert string date
-- SQL Server number to varchar conversion
-- SQL Server leading zeroes for month and day
-- SQL Server right string function
UPDATE Employee SET BirthDate =
      CONVERT(char(4),YEAR(CAST('1965-01-23' as DATETIME)))+
      RIGHT('0'+CONVERT(varchar,MONTH(CAST('1965-01-23' as DATETIME))),2)+
      RIGHT('0'+CONVERT(varchar,DAY(CAST('1965-01-23' as DATETIME))),2)
      WHERE FullName = 'Rob Walters'
GO
SELECT BirthDate FROM Employee WHERE FullName = 'Rob Walters'
GO
-- Result: 19650123
 
-- Perform cleanup action
DROP TABLE Employee
-- SQL nocount
SET NOCOUNT OFF;
GO
------------

------------
-- sql isdate function
------------
USE tempdb;
-- sql newid - random sort
SELECT top(3) SalesOrderID,
stringOrderDate = CAST (OrderDate AS varchar)
INTO DateValidation
FROM AdventureWorks.Sales.SalesOrderHeader
ORDER BY NEWID()
GO
SELECT * FROM DateValidation
/* Results
SalesOrderID      stringOrderDate
56720             Oct 26 2003 12:00AM
73737             Jun 25 2004 12:00AM
70573             May 14 2004 12:00AM
*/
-- SQL update with top
UPDATE TOP(1) DateValidation
SET stringOrderDate = 'Apb 29 2004 12:00AM'
GO
-- SQL string to datetime fails without validation
SELECT SalesOrderID, OrderDate = CAST (stringOrderDate as datetime)
FROM DateValidation
GO
/* Msg 242, Level 16, State 3, Line 1
The conversion of a varchar data type to a datetime data type resulted in an
out-of-range value.
*/
-- sql isdate - filter for valid dates
SELECT SalesOrderID, OrderDate = CAST (stringOrderDate as datetime)
FROM DateValidation
WHERE ISDATE(stringOrderDate) = 1
GO
/* Results
SalesOrderID      OrderDate
73737             2004-06-25 00:00:00.000
70573             2004-05-14 00:00:00.000
*/
-- SQL drop table
DROP TABLE DateValidation
Go
 
------------
-- SELECT between two specified dates - assumption TIME part is 00:00:00.000
------------
-- SQL datetime between
-- SQL select between two dates
SELECT EmployeeID, RateChangeDate
FROM AdventureWorks.HumanResources.EmployeePayHistory
WHERE RateChangeDate >= '1997-11-01' AND 
      RateChangeDate < DATEADD(dd,1,'1998-01-05')
GO
/* Results
EmployeeID  RateChangeDate
3           1997-12-12 00:00:00.000
4           1998-01-05 00:00:00.000
*/
 
/* Equivalent to
 
-- SQL datetime range
SELECT EmployeeID, RateChangeDate
FROM AdventureWorks.HumanResources.EmployeePayHistory
WHERE RateChangeDate >= '1997-11-01 00:00:00' AND 
      RateChangeDate <  '1998-01-06 00:00:00'
GO
*/
------------

-- SQL datetime language setting
-- SQL Nondeterministic function usage - result varies with language settings
SET LANGUAGE  'us_english';  –– Jan 12 2015 12:00AM 
SELECT US = convert(VARCHAR,convert(DATETIME,'01/12/2015'));
SET LANGUAGE  'British';     –– Dec  1 2015 12:00AM 
SELECT UK = convert(VARCHAR,convert(DATETIME,'01/12/2015'));
SET LANGUAGE  'German';      –– Dez  1 2015 12:00AM 
SET LANGUAGE  'Deutsch';     –– Dez  1 2015 12:00AM 
SELECT Germany = convert(VARCHAR,convert(DATETIME,'01/12/2015'));
SET LANGUAGE  'French';      –– déc  1 2015 12:00AM 
SELECT France = convert(VARCHAR,convert(DATETIME,'01/12/2015'));
SET LANGUAGE  'Spanish';     –– Dic  1 2015 12:00AM 
SELECT Spain = convert(VARCHAR,convert(DATETIME,'01/12/2015'));
from: http://www.sqlusa.com/bestpractices2005/centurydateformat/


SET LANGUAGE  'Hungarian';   –– jan 12 2015 12:00AM 
SELECT Hungary = convert(VARCHAR,convert(DATETIME,'01/12/2015'));
SET LANGUAGE  'us_english';
GO
------------

-- SQL Server 2008 T-SQL find next Monday for a given date
DECLARE @DateTime DATETIME = '2012-12-31'
SELECT NextMondaysDate=DATEADD(dd,(DATEDIFF(dd, 0, @DateTime) / 7 * 7) + 7, 0),
WeekDayName=DATENAME(dw,DATEADD(dd,(DATEDIFF(dd, 0, @DateTime) / 7 * 7) + 7, 0));
/*
NextMondaysDate         WeekDayName
2013-01-07 00:00:00.000 Monday
*/
------------

------------
-- Function for Monday dates calculation
------------
USE AdventureWorks2008;
GO
-- SQL user-defined function
-- SQL scalar function - UDF
CREATE FUNCTION fnMondayDate
               (@Year          INT,
                @Month         INT,
                @MondayOrdinal INT)
RETURNS DATETIME
AS
  BEGIN
    DECLARE  @FirstDayOfMonth CHAR(10),
             @SeedDate        CHAR(10)
    
    SET @FirstDayOfMonth = convert(VARCHAR,@Year) + '-' + convert(VARCHAR,@Month) + '-01'
    SET @SeedDate = '1900-01-01'
    
    RETURN DATEADD(DD,DATEDIFF(DD,@SeedDate,DATEADD(DD,(@MondayOrdinal * 7) - 1,
                  @FirstDayOfMonth)) / 7 * 7,  @SeedDate)
  END
GO
 
-- Test Datetime UDF - Third Monday in Feb, 2015
SELECT dbo.fnMondayDate(2016,2,3)
-- 2015-02-16 00:00:00.000
 
-- First Monday of current month
SELECT dbo.fnMondayDate(Year(getdate()),Month(getdate()),1)
-- 2009-02-02 00:00:00.000  

------------