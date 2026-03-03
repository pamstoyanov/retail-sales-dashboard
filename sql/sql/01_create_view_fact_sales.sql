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
