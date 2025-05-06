USE DataWarehouseAnalytics;

-- Cumulative Analysis
-- TASK: Calculate the total sales per year 
--	     and the running total of sales overtime.

SELECT
*,
SUM(total_sales) OVER (ORDER BY order_year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 'running_total', -- Default
AVG(total_sales) OVER (ORDER BY order_year) 'moving_average' -- Default Frame when use ORDER BY ( ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM (
	SELECT
	DATEPART(YEAR,order_date) 'order_year',
	SUM(sales_amount) 'total_sales'
	FROM gold.fact_sales
	WHERE order_date is not null
	GROUP BY DATEPART(YEAR,order_date)) as T