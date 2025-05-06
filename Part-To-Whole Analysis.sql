USE DataWarehouseAnalytics;

-- Part-To-Whole Analysis
-- Which categories contribute the most to overall sales.

WITH CTE_total_category_sales_per_year AS(
SELECT
YEAR(S.order_date) 'order_year',
P.category,
SUM(S.sales_amount) as total_category_sales
FROM gold.dim_products as P LEFT JOIN gold.fact_sales as S
ON P.product_key = S.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(S.order_date),P.category)

SELECT
*,
SUM(total_category_sales) OVER (PARTITION BY order_year) as 'yearly_total_sales',
CONCAT(ROUND(CAST(total_category_sales as float) / SUM(total_category_sales) OVER (PARTITION BY order_year) * 100,2),'%') 'part-to-all'
FROM CTE_total_category_sales_per_year