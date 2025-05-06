USE DataWarehouseAnalytics;

-- Performance Analysis
-- TASK: Analyze the yearly performance of products
-- by comparing each product's sales to both it's average sales performance
-- and the previous year's sales.


-- Create CTE
WITH CTE_yearly_product_sales AS (
SELECT
YEAR(order_date) 'order_year',
P.product_name,
SUM(sales_amount) 'current_sales'
FROM gold.fact_sales as S
LEFT JOIN gold.dim_products as P
ON S.product_key = P.product_key
WHERE order_date is not null
GROUP BY YEAR(order_date),P.product_name)

SELECT
order_year,
product_name,
current_sales,
ISNULL(LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year),0) as 'previous_sales',
current_sales - ISNULL(LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year),0) as diff_previous,
CASE 
	WHEN current_sales - ISNULL(LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year),0) > 0 THEN 'Increased'
	WHEN current_sales - ISNULL(LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year),0) < 0 THEN 'Decreased'
	ELSE 'No Change'
END as previous_change,
AVG(current_sales) OVER(PARTITION BY product_name) as avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) as diff_avg,
CASE
	 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END as avg_change
FROM CTE_yearly_product_sales
ORDER BY product_name,order_year
