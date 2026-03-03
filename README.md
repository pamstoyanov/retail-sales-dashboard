# Retail Sales Performance Dashboard

End-to-end Data Analysis project built using SQL and Power BI.

---

## Project Overview

This project analyzes retail sales performance using a star schema data model and business-focused KPIs.

The goal was to simulate a real business scenario and answer key analytical questions about revenue, profitability, and customer performance.

---

## Tech Stack

- SQL Server
- T-SQL (Views, CTEs, Window Functions)
- Power BI
- Star Schema Modeling

---

## Data Model

The model follows a star schema structure:

- FactSales (SQL View)
- Customers
- Products
- Orders

Full SQL script available in:

Full SQL script available in:

[01_retail_sales_dw.sql](sql/01_retail_sales_dw.sql)

---

## Dashboard KPIs

- Total Revenue
- Total Cost
- Total Profit
- Margin %
- Orders Count
- Average Order Value (AOV)

![Dashboard](images/dashboard.png)

---

## SQL Highlights

The SQL script includes:

- View creation (`vw_FactSales`)
- Revenue, Cost, Profit, Margin calculations
- Aggregations (Top Products, Top Customers)
- Window functions (DENSE_RANK, ROW_NUMBER)
- Running totals (Monthly Revenue)
- JOIN logic (INNER / LEFT JOIN)
- Business classification using CASE

Full SQL script available in:

`sql/01_retail_sales_dw.sql`

---

## Key Business Questions Answered

- Which products generate the most revenue?
- Which customers are the most valuable?
- How is revenue trending over time?
- What is the overall profit margin?
- How many orders does each customer place?

---

## Author

Pam Stoyanov  
Aspiring Junior Data Analyst
