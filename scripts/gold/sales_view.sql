/****************************************************************************************
* View Name   : gold.fact_sales
* Description :
*   Sales fact view built in the GOLD layer.
*
*   The view represents transactional sales data enriched with
*   surrogate keys from dimension tables.
*
*   Business Rules:
*     - One row represents one sales transaction line
*     - Sales data is sourced from CRM sales details
*     - Product and customer surrogate keys are resolved via GOLD dimensions
*     - LEFT JOINs are used to preserve all sales records
*       even if dimension lookups fail
*
*   Grain:
*     - One row per order number, product, and customer combination
*
*   Measures:
*     - sales_amount
*     - quantity
*     - price
*
*   Foreign Keys:
*     - product_key  → gold.dim_products
*     - customer_key → gold.dim_customers
*
*   Source Tables:
*     - silver.crm_sales_details
*
*   Dimension References:
*     - gold.dim_products
*     - gold.dim_customers
*
*   Target Layer:
*     - GOLD (Dimensional Model – Fact Table)
*
* Notes:
*   - This fact table is designed for analytical workloads
*   - Missing dimension matches will result in NULL surrogate keys
*   - Date columns are stored at day-level granularity
*
* Author      : <Your Name>
* Created On  : 2026-01-07
*
****************************************************************************************/

CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount, 
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
ON pr.product_number = sd.sls_prd_key
LEFT JOIN gold.dim_customers AS cu
ON sd.sls_cust_id = cu.customer_id
