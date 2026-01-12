/****************************************************************************************
* View Name   : gold.dim_customers
* Description :
*   Customer dimension view built in the GOLD layer.
*
*   The view consolidates customer master data from multiple SILVER sources:
*     - CRM customer master (primary / master source)
*     - ERP customer demographics
*     - ERP customer location
*
*   Business Rules:
*     - CRM customer table (silver.crm_cust_info) is treated as the MASTER source
*     - Gender is primarily taken from CRM;
*       if CRM gender = 'n/a', ERP gender is used as a fallback
*     - Customer key is generated using ROW_NUMBER()
*
*   Grain:
*     - One row per customer (business key: cst_id)
*
*   Source Tables:
*     - silver.crm_cust_info
*     - silver.erp_cust_az12
*     - silver.erp_loc_a101
*
*   Target Layer:
*     - GOLD (Dimensional Model)
*
* Notes:
*   - This view is intended to be used as a customer dimension
*     in analytical and reporting workloads.
*   - No data is persisted; view reflects current SILVER state.
*
* Author      : Mateo221
* Created On  : 2026-01-12
*
****************************************************************************************/

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (order by cst_id) AS customer_key,
	cst_id AS customer_id,
	cst_key AS customer_number,
	cst_firstname AS first_name,
	cst_lastname AS last_name, 
	la.cntry AS country,
	CASE 
		WHEN ci.cst_gndr = 'Female' THEN 'Female'
		WHEN ci.cst_gndr = 'Male' THEN 'Male'
		WHEN ci.cst_gndr = 'n/a' THEN COALESCE(ca.gen,'n/a')
		ELSE 'n/a'
		END As gender, ------ Gender was different in two sources, we have chose cst_info as a Master table.
	cst_martial_status AS martial_status,
	ca.bdate AS birthday,	
	cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid;
