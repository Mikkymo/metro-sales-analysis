
--TDI ONYX COHORT SQL CAPSTONE PROJECT

SELECT *
FROM Sales;

SELECT * 
FROM Product;

SELECT *
FROM Region;

SELECT * 
FROM Salesperson;

SELECT *
FROM Reseller;

SELECT * 
FROM SalespersonRegion;

SELECT *
FROM Targets;


SELECT *
FROM sales s
JOIN Targets t ON
s.OrderDate = t.TargetMonth

ALTER TABLE [Product]
ADD CONSTRAINT PK_Product PRIMARY KEY ([ProductKey]);

ALTER TABLE [Sales]
ADD CONSTRAINT PK_Sales PRIMARY KEY ([SalesOrderNumber]);


-------------------------------------------------------
-- CLEANING PRODUCT TABLE
-------------------------------------------------------

-- 1. Check for null values
SELECT 
    SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END) AS Missing_ProductID,
    SUM(CASE WHEN Product IS NULL THEN 1 ELSE 0 END) AS Missing_ProductName
FROM Product;

-- 2. Remove duplicates
WITH Product_CTE AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY ProductKey, Category, SubCategory ORDER BY ProductKey) AS rn
    FROM Product
)
DELETE FROM Product_CTE WHERE rn > 1;


-------------------------------------------------------
-- CLEANING RESELLER TABLE
-------------------------------------------------------

-- 1. Check for missing data
SELECT 
    SUM(CASE WHEN ResellerKey IS NULL THEN 1 ELSE 0 END) AS Missing_ResellerID,
    SUM(CASE WHEN Reseller IS NULL THEN 1 ELSE 0 END) AS Missing_ResellerName
FROM Reseller;

-- 2. Remove duplicates
WITH Reseller_CTE AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY ResellerKey ORDER BY Resellerkey) AS rn
    FROM Reseller
)
DELETE FROM Reseller_CTE WHERE rn > 1;

-- 3. Standardize reseller names (example)
UPDATE Reseller
SET Reseller = TRIM(Reseller);

-------------------------------------------------------
-- CLEANING SALES TABLE
-------------------------------------------------------

-- 1. Check nulls
SELECT 
    SUM(CASE WHEN SalesOrderNumber IS NULL THEN 1 ELSE 0 END) AS Missing_SalesID,
    SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END) AS Missing_ProductID,
    SUM(CASE WHEN ResellerKey IS NULL THEN 1 ELSE 0 END) AS Missing_ResellerID,
    SUM(CASE WHEN EmployeeKey IS NULL THEN 1 ELSE 0 END) AS Missing_EmployeeID,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Missing_Quantity,
    SUM(CASE WHEN SalesTerritoryKey IS NULL THEN 1 ELSE 0 END) AS Missing_TerritoryKey
FROM Sales;

-- 2. Remove duplicates
WITH Sales_CTE AS (
    SELECT *, ROW_NUMBER() OVER(
        PARTITION BY SalesOrderNumber
        ORDER BY SalesOrderNumber
    ) AS rn
    FROM Sales
)
DELETE FROM Sales_CTE WHERE rn > 1;

---------------------------------------------
    --Removing Duplicates From Target Table
---------------------------------------------
WITH CTE AS (
    SELECT 
        [EmployeeID],
        [TargetMonth],
        [Target],
        ROW_NUMBER() OVER (PARTITION BY [EmployeeID], [TargetMonth] ORDER BY [EmployeeID]) AS rn
    FROM [Targets]
)
DELETE FROM CTE WHERE rn > 1;


-------------------------------------------------------
-- CLEANING SALESPERSON TABLE
-------------------------------------------------------

-- 1. Check nulls
SELECT 
    SUM(CASE WHEN EmployeeKey IS NULL THEN 1 ELSE 0 END) AS Missing_employeekey,
    SUM(CASE WHEN Salesperson IS NULL THEN 1 ELSE 0 END) AS Missing_SalespersonName 
FROM Salesperson;

-- 2. Remove duplicates
WITH SP_CTE AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY EmployeeID ORDER BY EmployeeKey) AS rn
    FROM Salesperson
)
DELETE FROM SP_CTE WHERE rn > 1;

-------------------------------------------------------
-- CLEANING REGION TABLE
-------------------------------------------------------

-- 1. Check for nulls
SELECT 
    SUM(CASE WHEN SalesTerritoryKey IS NULL THEN 1 ELSE 0 END) AS Missing_RegionID
FROM Region;

-- 2. Remove duplicates
WITH Region_CTE AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY RegionName ORDER BY RegionID) AS rn
    FROM Region
)
DELETE FROM Region_CTE WHERE rn > 1;


WITH CTE AS (
    SELECT 
        [EmployeeKey],
        [SalesTerritoryKey],
        ROW_NUMBER() OVER (PARTITION BY [SalesTerritoryKey] ORDER BY [EmployeeKey]) AS rn
    FROM [SalespersonRegion]
)
DELETE FROM CTE WHERE rn > 1;




-- Find inconsistent reseller names
SELECT DISTINCT Reseller
FROM Reseller
ORDER BY Reseller;



-- Sales without matching Product
SELECT s.*
FROM Sales s
LEFT JOIN Product p ON s.ProductKey = p.ProductKey
WHERE p.ProductKey IS NULL;



-- Sales without matching Reseller
SELECT s.*
FROM Sales s
LEFT JOIN Reseller r ON s.ResellerKey = r.ResellerKey
WHERE r.ResellerKey IS NULL;


-- Very high or negative quantities (Outliers)
SELECT * FROM Sales
WHERE Quantity < 0 OR Quantity > 10000;


-- Find duplicate sales entries
SELECT SalesOrderNumber, ProductKey, ResellerKey, OrderDate, COUNT(*) AS DupCount
FROM Sales
GROUP BY SalesOrderNumber, ProductKey, ResellerKey, OrderDate
HAVING COUNT(*) > 1;



-- Calculate the total sales for each product 

SELECT
	ProductKey,
	SUM(Sales) OVER (PARTITION BY ProductKey ORDER BY Sales) AS TotalSalesByProduct
FROM sales


-- Rank the orders based on their sales from the highest to the lowest

SELECT  sales.SalesOrderNumber,
		ProductKey,
		Sales,
		ROW_NUMBER () OVER(ORDER BY  sales DESC) AS sales_rank_row
FROM sales


-- Find and Rank the top sales for each product 

SELECT *
FROM (
SELECT 
	sales.SalesOrderNumber,
	ProductKey,
	sales.Sales,
	ROW_NUMBER () OVER (PARTITION BY ProductKey ORDER BY sales DESC) RankbyProduct
FROM sales
)t
WHERE 
RankbyProduct = 1

-- Segment all sales into 3 categories
SELECT 
*,
CASE 
	WHEN Salesbuckets = 1 THEN 'High'
	WHEN salesbuckets = 2 THEN 'Medium'
	WHEN salesbuckets = 3 THEN 'Low'
END segmentation

FROM
(
SELECT  sales.SalesOrderNumber,
		Sales.Sales,
NTILE (3) OVER (ORDER BY Sales DESC) SalesBuckets
FROM Sales
)t


-- Analyze the Month Over Month (MoM) Perfomance by finding the percentage change in sales between the previous and current month

SELECT
*,
CurrentMSales - PreviousMSales AS MoM_Change,
(CurrentMSales - PreviousMSales) / PreviousMSales * 100 AS Grwoth_Percent
FROM
(
SELECT 
	MONTH (OrderDate) OrderMonth,
    DATENAME(MONTH, OrderDate) MonthName,
    SUM(Sales) CurrentMSales,
	LAG(SUM(Sales)) OVER (ORDER BY MONTH (OrderDate)) PreviousMSales
FROM Sales
GROUP BY
	MONTH(OrderDate), DATENAME(MONTH, OrderDate)
    )t


-- Find the total sales across all orders
-- Find the total sales for each product
-- Provide details such as the SalesOrderNumber and the OrderDate

SELECT 
Sales.SalesOrderNumber,
ProductKey,
OrderDate,
Sales,
	SUM(Sales) OVER () AS  Total_Sales,
	SUM(Sales) OVER (PARTITION BY Productkey ORDER BY sales) AS TotalSalesByProduct,
	SUM(sales) OVER (ORDER BY Orderdate,Sales.SalesOrderNumber) AS TotalSalesByDate
FROM 
Sales


-- Rank the salespersons by their total sales.
SELECT
Sp.EmployeeKey,
	SUM(Sales) AS TotalSales,
	RANK () OVER (ORDER BY SUM(Sales)DESC) SpRank
FROM Salesperson Sp
JOIN Sales S ON sp.EmployeeKey = s.EmployeeKey
GROUP BY Sp.EmployeeKey



-- Find the total number of orders for each product.

SELECT
s.SalesOrderNumber,
p.ProductKey,
COUNT(s.salesOrderNumber) OVER (ORDER BY s.salesordernumber DESC)  AS TotalOrders
FROM Sales s
JOIN Product p ON p.ProductKey = p.ProductKey

-- Find the total number of orders 
-- Find the total number of orders by each salesperson
-- Provide the order date and the SalesOrderNumber


SELECT 
s.SalesOrderNumber,
Orderdate,
sp.employeekey,
    COUNT (*) OVER () AS totalorders,
    COUNT (*) OVER (PARTITION BY sp.employeekey) AS OrdersBySp
FROM Sales s
JOIN Salesperson sp ON s.EmployeeKey = sp.EmployeeKey

-- Find the total number of customers and provide their customer id
-- Where the cucstomers here are the resellers.

SELECT 
	resellerkey,
	COUNT (*) OVER () TotalCustomers
FROM
reseller


-- The total revenue generated from all the sales made.
SELECT 
Sales.SalesOrderNumber,
ProductKey,
OrderDate,
Sales,
	SUM(Sales) OVER () AS  Total_Sales
FROM sales


-- Top Performing Customer (Reseller)
SELECT TOP 1
    R.ResellerKey,
    R.Reseller,
    SUM(S.Quantity) AS Total_Quantity_Sold,
    SUM(S.Quantity * S.[Unit_Price]) AS Total_Revenue
FROM Sales AS S
JOIN Reseller AS R
    ON S.ResellerKey = R.ResellerKey
GROUP BY R.ResellerKey, R.Reseller
ORDER BY Total_Revenue DESC;

-- Top Performing Salesperson
SELECT TOP 1
    E.EmployeeKey,
    E.Salesperson,
    SUM(S.Quantity) AS Total_Quantity_Sold,
    SUM(S.Quantity * S.[Unit_Price]) AS Total_Revenue
FROM Sales AS S
JOIN Salesperson AS E
    ON S.EmployeeKey = E.EmployeeKey
GROUP BY E.EmployeeKey, E.Salesperson
ORDER BY Total_Revenue DESC;

-- Top Performing Product
SELECT TOP 1
    P.ProductKey,
    P.Product,
    SUM(S.Quantity) AS Total_Quantity_Sold,
    SUM(S.Quantity * S.[Unit_Price]) AS Total_Revenue
FROM Sales AS S
JOIN Product AS P
    ON S.ProductKey = P.ProductKey
GROUP BY P.ProductKey, P.Product
ORDER BY Total_Revenue DESC;

-- Top Performing Region
SELECT TOP 1
    Rg.SalesTerritoryKey,
    Rg.Region,
    SUM(S.Quantity) AS Total_Quantity_Sold,
    SUM(S.Quantity * S.[Unit_Price]) AS Total_Revenue
FROM Sales AS S
JOIN Region AS Rg
    ON S.SalesTerritoryKey = Rg.SalesTerritoryKey
GROUP BY Rg.SalesTerritoryKey, Rg.Region
ORDER BY Total_Revenue DESC;

-- Find the average sales across all the orders
-- Find the average sales across each product

SELECT 
SalesOrderNumber,
OrderDate,
Sales,
p.Productkey,
    AVG(Sales) OVER () Avg_Sales,
    AVG(Sales) OVER (PARTITION BY p.productkey) Avg_SalesPrdct
FROM Sales S
JOIN Product p ON s.productkey = p.productkey

-- Find the orders where sales are hihger than the average sales across all orders

SELECT *
FROM
(
SELECT 
    SalesOrderNumber,
    OrderDate,
    p.Productkey,
    s.sales,
    AVG(Sales) OVER () AS Avg_Sales
FROM Sales S
JOIN Product p ON s.productkey = p.productkey
)t WHERE Sales > Avg_Sales

-- Find the highest and lowest sales for all orders
-- Find the highest and lowest sales across the products.
-- Also include the orderID, OrderDate and the ProductKey
SELECT 
SalesOrderNumber,
OrderDate,
p.Productkey,
sales,
    MAX(Sales) OVER () MaxSales,
    MIN(Sales) OVER () MinSales,
    MAX(Sales) OVER (PARTITION BY p.productkey) MaxSales,
    MIN(Sales) OVER (PARTITION BY p.productkey) MinSales
FROM Sales S
JOIN Product p ON s.productkey = p.productkey


-- Find the total sales by each salesperson
WITH CTE_Total_Sales AS
(
SELECT
    Sp.EmployeeKey,
    SUM(Sales) AS TotalSales
FROM Salesperson Sp
JOIN Sales S ON sp.EmployeeKey = s.EmployeeKey
GROUP BY Sp.EmployeeKey
),
-- Rank the salespersons by Total Sales
CTE_SP_Rank AS
(
SELECT
    EmployeeKey,
    Totalsales,
    RANK () OVER (ORDER BY TotalSales DESC) AS Sp_Rank
FROM CTE_Total_Sales
),
-- Find the last Order date per salesperson
CTE_Last_Order AS
(
SELECT
    MAX(Orderdate) AS last_order,
    DATENAME(WEEKDAY,Orderdate) DayName,
    sp.EmployeeKey
FROM Sales s
JOIN Salesperson sp ON s.EmployeeKey = sp.EmployeeKey
GROUP BY sp.EmployeeKey,s.OrderDate
)
-- Thw main query
SELECT 
    sp.employeekey,
    employeeID,
    Sp.Salesperson,
    cts.TotalSales,
    ctls.last_order,
    ctls.DayName,
    ctR.Sp_Rank
FROM Salesperson sp
LEFT JOIN CTE_Total_Sales cts ON sp.EmployeeKey = cts.EmployeeKey
LEFT JOIN CTE_Last_Order ctls ON sp.EmployeeKey = ctls.EmployeeKey
LEFT JOIN CTE_SP_Rank ctR ON sp.EmployeeKey = ctR.EmployeeKey

-- Customer (Reseller) loyalty segmentation using conditional logic
SELECT 
    rs.Resellerkey,
    rs.Reseller,
    COUNT(SalesOrderNumber) AS TotalOrders,
    CASE 
        WHEN COUNT(SalesOrderNumber) >= 10 THEN 'Loyal Customer'
        WHEN COUNT(SalesOrderNumber) BETWEEN 5 AND 9 THEN 'Moderate Customer'
        ELSE 'New Customer'
    END AS CustomerType
FROM Sales s
JOIN Reseller rs ON s.ResellerKey = rs.ResellerKey
GROUP BY Reseller,rs.Resellerkey


/*Which region, reseller, and salesperson generated the highest total revenue,
and what trends can be observed in their monthly sales performance?

Total Revenue by Region, Reseller, and Salesperson (Monthly Trend)*/

SELECT 
    rg.Region,
    r.Reseller,
    sp.Salesperson,
    DATENAME(MONTH, s.OrderDate) AS MonthName,
    SUM(s.Sales) AS TotalRevenue
FROM Sales AS s
JOIN Reseller AS r 
    ON s.ResellerKey = r.ResellerKey
JOIN Salesperson sp 
    ON s.EmployeeKey = sp.EmployeeKey
JOIN Region AS rg 
    ON s.SalesTerritoryKey = rg.SalesTerritoryKey
GROUP BY 
    rg.Region, r.Reseller, sp.Salesperson, DATENAME(MONTH, s.OrderDate)
ORDER BY 
    TotalRevenue DESC;


   /* Which product categories or subcategories contribute the most to total revenue,
    and which resellers purchase the most profitable products?*/

    --  Top Performing Products and Resellers (Customers)
SELECT 
    p.Category,
    p.Subcategory,
    p.Product,
    r.Reseller,
    SUM(s.Sales) AS TotalRevenue,
    SUM(s.Sales - s.Cost) AS Profit
FROM Sales AS s
JOIN Product AS p 
    ON s.ProductKey = p.ProductKey
JOIN Reseller AS r 
    ON s.ResellerKey = r.ResellerKey
GROUP BY 
    p.Category, p.Subcategory, p.Product, r.Reseller
ORDER BY 
    TotalRevenue DESC;

/*What are the monthly and weekday sales patterns, 
and which periods experience the highest or lowest sales activity?*/
    -- ?? Monthly and Weekday Sales Trends

SELECT 
    DATENAME(MONTH, s.OrderDate) AS MonthName,
    DATENAME(WEEKDAY, s.OrderDate) AS DayName,
    SUM(s.Sales) AS TotalRevenue,
    COUNT(s.SalesOrderNumber) AS TotalOrders
FROM Sales AS s
GROUP BY 
    DATENAME(MONTH, s.OrderDate),
    DATENAME(WEEKDAY, s.OrderDate)
ORDER BY 
     COUNT(s.SalesOrderNumber) DESC;

SELECT * 
FROM 
CleanSalesData;








WITH Distinct_Employee AS (
    SELECT DISTINCT EmployeeKey, EmployeeID, s.Salesperson, Title, UPN
    FROM salesperson s
),
Distinct_Reseller AS (
    SELECT DISTINCT ResellerKey, [Business_Type], Reseller, [City], [State_Province], [Country_Region]
    FROM Reseller
),
Distinct_Territory AS (
    SELECT DISTINCT SalesTerritoryKey, Region, Country, [Group]
    FROM Region r
)
SELECT 
    s.SalesOrderNumber,
    s.OrderDate,
    DATENAME(MONTH, s.OrderDate) AS MonthName,
    DATENAME(WEEKDAY, s.OrderDate) AS DayName,
    s.ProductKey,
    p.Product,
    p.Category,
    p.Subcategory,
    s.ResellerKey,
    r.Reseller,
    s.EmployeeKey,
    sp.Salesperson,
    t.Region,
    s.Quantity,
    s.[Unit_Price],
    s.Sales,
    s.Cost,
    (s.Sales - s.Cost) AS Profit
FROM Sales s
LEFT JOIN Distinct_Employee sp ON s.EmployeeKey = sp.EmployeeKey
LEFT JOIN Distinct_Reseller r ON s.ResellerKey = r.ResellerKey
LEFT JOIN Distinct_Territory t ON s.SalesTerritoryKey = t.SalesTerritoryKey
INNER JOIN Product p ON s.ProductKey = p.ProductKey;


-- Count check
SELECT COUNT(*) AS TotalRows_CleanSalesData FROM CleanSalesData;











