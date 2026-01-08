---- Check for Nulls or Duplicates in Primary Key

SELECT * FROM(
SELECT prd_id,
ROW_NUMBER() OVER(PARTITION BY prd_id ORDER BY prd_ID DESC) AS Flag
FROM bronze.crm_prd_info)t
WHERE Flag !=1;


---- Check for unwanted spaces
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


---- CHECK for NULLS 
SELECT * FROM bronze.crm_prd_info
WHERE prd_cost IS NULL 

---- Check for Invalid Date Orders
SELECT * FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt



--- Check for Invalid Date
SELECT
NULLIF (sls_ship_dt,0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt < = 0
OR LEN(sls_ship_dt) !=8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101
