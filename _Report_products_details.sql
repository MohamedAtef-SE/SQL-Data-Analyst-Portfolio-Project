USE DataWarehouseAnalytics;

/*
===========================================================================================
									Product Report
===========================================================================================
Purpose:
 - This report consolidates key product metrics and behaviors.
Highlights:
1. Gathers essential fields such as product name, category, subcategory, and cost.
2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers. 
3. Aggregates product-level metrics:
	-total orders
	- total sales
	- total quantity sold
	- total customers (unique)
	- lifespan (in months)
4. Calculates valuable KPIs:
	- recency (months since last sale)
	- average order revenue (AOR)
	- average monthly revenue
*/


-- 1. Gathers essential fields such as product name, category, subcategory, and cost.
GO
CREATE OR ALTER View gold.report_products_details
WITH ENCRYPTION
As
WITH CTE_baseQuery As(
SELECT
S.order_number,
S.order_date,
S.customer_key,
S.sales_amount,
S.quantity,
P.product_key,
P.product_name,
P.category,
P.subcategory,
P.cost
FROM gold.dim_products P
LEFT JOIN gold.fact_sales S
ON P.product_key = S.product_key
WHERE order_number is not null )

-- 3. Aggregates product-level metrics:
--	- total orders
--	- total sales
--	- total quantity sold
--	- total customers (unique)
--	- lifespan (in months)

, CTE_product_aggregation As (
SELECT
product_key,
product_name,
category,
subcategory,
cost,
DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) 'lifespan',
MAX(order_date) 'last_order_date',
COUNT(distinct order_number) 'total_orders',
COUNT(distinct customer_key) 'total_customers',
SUM(sales_amount) 'total_sales',
SUM(quantity) 'total_quntity'
FROM CTE_baseQuery
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)
-- 2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers. 
-- 4. Calculates valuable KPIs:
--	- recency (months since last sale)
--	- average order revenue (AOR)
--	- average monthly revenue

SELECT
product_key,
product_name,
category,
subcategory,
cost,
last_order_date,
DATEDIFF(MONTH,last_order_date,GETDATE()) 'recency_in_months',
CASE WHEN total_sales >= 400000 THEN 'High-Performers'
	 WHEN total_sales between 100000 and 399999 THEN 'Mid-Range'
	 ELSE 'Low Performers'
END as 'product_segments',
lifespan,
total_orders,
total_sales,
total_quntity,
total_customers,
CASE WHEN total_orders = 0 THEN 0
	 ELSE total_sales / total_orders
END as avg_order_revenue,
CASE WHEN  lifespan = 0 THEN total_sales / 1
     ELSE total_sales / lifespan
END As avg_month_revenue
FROM CTE_product_aggregation
GO

SELECT
*
FROM gold.report_products_details
ORDER BY total_sales DESC