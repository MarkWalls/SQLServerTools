-- Create table with SELECT INTO for testing - Price is increased with $1.00
USE tempdb;
SELECT      ProductID=CONVERT(int, ProductID),
            ProductName = Name,
            ListPrice = ListPrice + 1.00
INTO Product
FROM AdventureWorks2008.Production.Product
WHERE ListPrice > 0.0
GO
-- (304 row(s) affected)
 
-- Insert full row (line) duplicates
INSERT INTO Product
SELECT      TOP (100) ProductID=CONVERT(int, ProductID),
            ProductName = Name,
            ListPrice = ListPrice + 1.00
FROM AdventureWorks2008.Production.Product
WHERE ListPrice > 0.0
ORDER BY NEWID()
-- (100 row(s) affected)
SELECT COUNT(*) FROM Product
-- 404
 
------------
-- Eliminate identical duplicates (entire row identical) with SELECT DISTINCT INTO
------------
SELECT DISTINCT *
INTO dedupProduct
FROM Product
GO
-- (304 row(s) affected)
 
------------
-- Eliminate duplicates with GROUP BY
------------
SELECT *
INTO dedupProductGROUPBY
FROM Product
GROUP BY ProductID, ProductName, ListPrice
-- (304 row(s) affected)
------------
 
------------
-- Eliminating / deleting duplicates based on duplicate keys - CTE / ROW_NUMBER
------------
;WITH CTE AS (
     SELECT RN=ROW_NUMBER() OVER (PARTITION BY ProductID
     ORDER BY ModifiedDate DESC )
     FROM Product)
DELETE CTE
WHERE RN > 1
GO
-- (100 row(s) affected)
SELECT COUNT(ProductID) FROM Product
GO
-- 304
 
DROP TABLE tempdb.dbo.Product
DROP TABLE tempdb.dbo.dedupProduct