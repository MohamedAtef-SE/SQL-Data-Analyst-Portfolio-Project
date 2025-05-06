USE DataWarehouseAnalytics;

-- Change Overtime Analysis
-- TASK: Analyse sales performance overtime.
SELECT
EOMONTH(order_date) 'order_month',
SUM(sales_amount) 'total_sales',
COUNT(DISTINCT customer_key) as 'total_customers'
FROM gold.fact_sales
WHERE order_date is not null
GROUP BY EOMONTH(order_date)
ORDER BY order_month