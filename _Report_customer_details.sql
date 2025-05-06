USE DataWarehouseAnalytics;

/*
====================================================================
							Customer Report							
====================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors
Highlights:
	1. Gathers essential fields such as names, ages, and transaction details. 
	2. Aggregates customer-level metrics:
	-total orders
	-total sales
	- total quantity purchased
	-total products
	- lifespan (in months)
	3. Segments customers into categories (VIP, Regular, New) and age groups. 
	4. Calculates valuable KPIs:
	- recency (months since last order)
	- average order value
	- average monthly spend
*/

GO
CREATE OR ALTER VIEW gold.reports_customers_view
WITH ENCRYPTION 
As
-- 1) Base Query: Retrieves core columns from tables

WITH CTE_base_query As(
SELECT
S.order_number,
S.product_key,
S.order_date,
S.sales_amount,
S.quantity,
C.customer_key,
C.customer_number,
CONCAT_WS(' ',C.first_name,C.last_name) 'customer_name',
DATEDIFF(YEAR,C.birthdate,GETDATE()) 'age'
FROM gold.dim_customers C
LEFT JOIN gold.fact_sales S
ON C.customer_key = S.customer_key
WHERE S.order_date IS NOT NULL)


/*
	-2 Aggregates customer-level metrics:
		-total orders
		-total sales
		- total quantity purchased
		-total products
		- lifespan (in months)
*/

,CTE_aggregation_query As(
SELECT
customer_key,
customer_name,
customer_number,
age,
COUNT(distinct order_number) 'total_orders',
SUM(sales_amount) 'total_sales',
SUM(quantity) 'total_quantity',
COUNT(distinct product_key) 'total_products',
MAX(order_date) 'last_order',
DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) 'lifespan'
FROM CTE_base_query
GROUP BY customer_key, customer_name, customer_number, age)

-- 3. Segments customers into categories (VIP, Regular, New) and age groups.
-- 4. Calculates valuable KPIs:
--	- recency (months since last order)
--	- average order value
--	- average monthly spend

SELECT
customer_key,
customer_number,
customer_name,
age,
CASE WHEN Age < 20 THEN 'Under 20'
			  WHEN age between 20 and 29 THEN '20-29'
			  WHEN age between 30 and 39 THEN '30-39'
			  WHEN age between 40 and 49 THEN '40-49'
			  ELSE '50 and above'
END as age_group,
lifespan,
CASE WHEN lifespan >= 12 AND total_sales >= 5000 THEN 'VIP'
	 WHEN lifespan >= 12 THEN 'Regular'
	 ELSE 'New'
END as segment,
total_orders,
total_sales,
CASE WHEN total_orders = 0 THEN 0
	 ELSE total_sales / total_orders
END As avg_order_sales,
total_quantity,
total_products,
last_order,
DATEDIFF(MONTH,last_order,GETDATE()) 'recency',
CASE WHEN lifespan = 0 THEN total_sales / 1 
	 ELSE total_sales / lifespan
END As avg_monthly_spend
FROM CTE_aggregation_query
GO

SELECT
*
FROM gold.reports_customers_view