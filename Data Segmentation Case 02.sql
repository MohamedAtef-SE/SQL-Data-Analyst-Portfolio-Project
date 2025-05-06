USE DataWarehouseAnalytics;

-- Data Segmentation Case 02
-- Group customers into three segments based on their spending behavior:
-- VIP: at least 12 months of history and spending more than 5,000.
-- Regular: at least 12 months of history but spending 5,000 or less.
-- NEW: Lifespan less than 12 months.
-- And find the total number of customers by each group.

WITH CTE_customer_details As(
SELECT
C.customer_id,
MIN(S.order_date) 'first_order',
MAX(S.order_date) 'latest_order',
DATEDIFF(MONTH,MIN(S.order_date),MAX(S.order_date)) lifespan,
SUM(S.sales_amount) 'total_spending'
FROM gold.dim_customers as C
LEFT JOIN gold.fact_sales as S
ON C.customer_key = S.customer_key
WHERE order_date is not null
GROUP BY C.customer_id)

SELECT
customer_segments,
COUNT(customer_id) 'total_customers'
FROM(SELECT
customer_id,
CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP-Customers'
     WHEN lifespan >= 12 THEN 'Regular-Customers'
	 ELSE 'NEW-Customers'
END as customer_segments
FROM CTE_customer_details) as T
GROUP BY customer_segments
ORDER BY total_customers DESC