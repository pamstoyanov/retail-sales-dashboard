USE SalesDW;
GO

CREATE OR ALTER VIEW dbo.vw_FactSales AS
SELECT
    od.OrderDetailID,
    o.OrderID,
    o.OrderDate,
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Country,
    p.ProductID,
    p.ProductName,
    p.Category,
    od.Quantity,
    od.DiscountPct,
    p.Price,
    p.UnitCost,

    CAST(od.Quantity * p.Price * (1 - od.DiscountPct) AS DECIMAL(12,2)) AS Revenue,
    CAST(od.Quantity * p.UnitCost AS DECIMAL(12,2)) AS Cost,
    CAST(
        (od.Quantity * p.Price * (1 - od.DiscountPct))
        - (od.Quantity * p.UnitCost)
    AS DECIMAL(12,2)) AS Profit,
    CAST(
        CASE 
            WHEN od.Quantity * p.Price * (1 - od.DiscountPct) = 0 THEN NULL
            ELSE (
                (
                    (od.Quantity * p.Price * (1 - od.DiscountPct))
                    - (od.Quantity * p.UnitCost)
                )
                /
                (od.Quantity * p.Price * (1 - od.DiscountPct))
            )
        END
    AS DECIMAL(12,4)) AS MarginPct
FROM dbo.OrderDetails od
JOIN dbo.Orders o     ON o.OrderID = od.OrderID
JOIN dbo.Customers c  ON c.CustomerID = o.CustomerID
JOIN dbo.Products p   ON p.ProductID = od.ProductID
WHERE od.Quantity > 0
  AND p.Price >= 0
  AND od.DiscountPct BETWEEN 0 AND 1;
GO


/* =====================================================
   2) AGGREGATIONS
   ===================================================== */

 --Top products by Revenue
SELECT
    ProductName,
    Category,
    SUM(Revenue) AS TotalRevenue
FROM dbo.vw_FactSales
GROUP BY ProductName, Category
ORDER BY TotalRevenue DESC;
GO

 --Top customers by Revenue
SELECT
    CustomerID,
    FirstName,
    LastName,
    SUM(Revenue) AS TotalRevenue
FROM dbo.vw_FactSales
GROUP BY CustomerID, FirstName, LastName
ORDER BY TotalRevenue DESC;
GO

/* =====================================================
   3) WINDOW FUNCTIONS
   ===================================================== */

-- Customer revenue ranking
WITH CustomerSpend AS (
    SELECT
        CustomerID,
        FirstName,
        LastName,
        SUM(Revenue) AS TotalRevenue
    FROM dbo.vw_FactSales
    GROUP BY CustomerID, FirstName, LastName
)
SELECT
    *,
    DENSE_RANK() OVER (ORDER BY TotalRevenue DESC) AS RevenueRank
FROM CustomerSpend;
GO

-- Monthly running revenue
WITH Monthly AS (
    SELECT
        DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS MonthStart,
        SUM(Revenue) AS TotalRevenue
    FROM dbo.vw_FactSales
    GROUP BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
)
SELECT
    MonthStart,
    TotalRevenue,
    SUM(TotalRevenue) OVER (ORDER BY MonthStart) AS RunningRevenue
FROM Monthly
ORDER BY MonthStart;
GO

-- Order sequence per customer
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    ROW_NUMBER() OVER (
        PARTITION BY CustomerID 
        ORDER BY OrderDate, OrderID
    ) AS OrderSequence
FROM dbo.Orders
ORDER BY CustomerID, OrderSequence;
GO

/* =====================================================
   4) JOIN TYPES + CASE LOGIC
   ===================================================== */

-- INNER JOIN + CASE (Product classification)
SELECT
    p.ProductName,
    SUM(od.Quantity) AS QuantitySold,
    SUM(od.Quantity * p.Price) AS Revenue,
    CASE
        WHEN SUM(od.Quantity) > 2 THEN 'Top Product'
        ELSE 'Normal Product'
    END AS ProductStatus
FROM dbo.OrderDetails od
INNER JOIN dbo.Products p ON p.ProductID = od.ProductID
GROUP BY p.ProductName
ORDER BY Revenue DESC;
GO

-- LEFT JOIN (all customers, even without orders)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.OrderDate
FROM dbo.Customers c
LEFT JOIN dbo.Orders o 
    ON o.CustomerID = c.CustomerID
ORDER BY c.CustomerID, o.OrderDate;
GO

-- LEFT JOIN + aggregation (Orders per customer)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(o.OrderID) AS OrdersCount
FROM dbo.Customers c
LEFT JOIN dbo.Orders o 
    ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY OrdersCount DESC;
GO

