USE DataWarehouseAnalytics;


-- Data Segementation Case 01
-- Segment products into cost ranges and
-- count how many products fall into each segment.
GO
WITH CTE_product_cost_segmentation AS(
SELECT
product_id,
product_name,
cost,
CASE
	WHEN cost < 100 THEN 'Low-cost'
	WHEN cost < 400 THEN 'Medium-cost'
	ELSE 'High-cost'
END as segmentation
FROM gold.dim_products)

SELECT
segmentation,
COUNT(product_id) 'total_products'
FROM CTE_product_cost_segmentation
GROUP BY segmentation
ORDER BY total_products DESC
