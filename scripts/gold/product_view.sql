/****************************************************************************************
* View Name   : gold.dim_products
* Description :
*   Product dimension view built in the GOLD layer.
*
*   The view represents the current (active) product master data and combines:
*     - CRM product information
*     - ERP product category hierarchy
*
*   Business Rules:
*     - Only active products are included (prd_end_dt IS NULL)
*     - Product key is generated using ROW_NUMBER() ordered by product start date
*     - Product attributes are sourced primarily from CRM
*     - Category attributes are enriched from ERP category hierarchy
*
*   Grain:
*     - One row per active product (business key: prd_id / prd_key)
*
*   Source Tables:
*     - silver.crm_prd_info
*     - silver.erp_px_cat_g1v2
*
*   Target Layer:
*     - GOLD (Dimensional Model)
*
* Notes:
*   - Historical product records are intentionally excluded
*   - This dimension is intended for use with fact tables
*     such as sales and orders
*
* Author      : Mateo221
* Created On  : 2026-01-12
*
****************************************************************************************/

CREATE VIEW gold.dim_products AS
	SELECT 
	ROW_NUMBER() OVER (Order BY pn.prd_start_dt) AS product_key,
		pn.prd_id AS product_id,
		pn.prd_key AS product_number,
		pn.prd_nm AS product_name,
		pn.cat_id AS category_id,
		pc.cat AS category,
		pc.subcat AS subcategory,
		pc.maintenance,
		pn.prd_cost AS cost,
		pn.prd_line AS product_line,
		pn.prd_start_dt AS start_date
	FROM silver.crm_prd_info AS pn
	LEFT JOIN silver.erp_px_cat_g1v2 AS pc
	ON pn.cat_id = pc.id
	WHERE prd_end_dt IS NULL ---- Filter out all historical data
