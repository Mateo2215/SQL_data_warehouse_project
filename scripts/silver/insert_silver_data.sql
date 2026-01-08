/****************************************************************************************
* Script Name : Load_Silver_Tables_From_Bronze.sql
* Description :
*   Script loads data from the BRONZE layer into the SILVER layer.
*   Applies data cleansing, standardization, deduplication
*   and basic business rules during transformation.
*
*   Source Layer : BRONZE
*   Target Layer : SILVER
*
* WARNING:
*   This script performs INSERT operations into SILVER tables.
*   Ensure target tables are empty or prepared before execution.
*
* Author      : <Your Name>
* Created On  : 2026-01-07
*
****************************************************************************************/


/* ================================================================================
   TARGET TABLE: silver.crm_cust_info
   Description :
     - Customer master data from CRM
     - Deduplication based on cst_id
     - Normalization of marital status and gender
   Source Table:
     - bronze.crm_cust_info
================================================================================ */

INSERT INTO silver.crm_cust_info(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_martial_status,
    cst_gndr,
    cst_create_date
)
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_martial_status)) = 'M' THEN 'Married'
        WHEN UPPER(TRIM(cst_martial_status)) = 'S' THEN 'Signle'
        ELSE 'n/a'
    END AS cst_martial_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE flag_last = 1;



/* ================================================================================
   TARGET TABLE: silver.crm_prd_info
   Description :
     - Product master data from CRM
     - Category ID and product key extraction
     - Handling NULL costs
     - Product line normalization
     - Derivation of product end date
   Source Table:
     - bronze.crm_prd_info
================================================================================ */

INSERT INTO silver.crm_prd_info(
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT 
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE 
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(
        LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
        AS DATE
    ) AS prd_end_date
FROM bronze.crm_prd_info;



/* ================================================================================
   TARGET TABLE: silver.crm_sales_details
   Description :
     - Sales transaction data from CRM
     - Date validation and casting
     - Sales and price recalculation logic
   Source Table:
     - bronze.crm_sales_details
================================================================================ */

INSERT INTO silver.crm_sales_details(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
    CASE 
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
    CASE 
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,
    CASE 
        WHEN sls_sales <= 0 THEN ABS(sls_price) / sls_quantity
        WHEN sls_sales IS NULL THEN ABS(sls_price) / sls_quantity
        WHEN sls_sales != sls_price / sls_quantity THEN ABS(sls_price) / sls_quantity
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE 
        WHEN sls_price = 0 THEN ABS(sls_sales) * sls_quantity
        WHEN sls_price IS NULL THEN ABS(sls_sales) * sls_quantity
        WHEN sls_price < 0 THEN ABS(sls_price)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;



/* ================================================================================
   TARGET TABLE: silver.erp_cust_az12
   Description :
     - Customer demographic data from ERP
     - Cleanup of customer ID
     - Validation of birth date
     - Gender normalization
   Source Table:
     - bronze.erp_cust_az12
================================================================================ */

INSERT INTO silver.erp_cust_az12(
    cid,
    bdate,
    gen
)
SELECT 
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    CASE 
        WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male'
        WHEN UPPER(TRIM(gen)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('', NULL) THEN 'n/a'
        WHEN UPPER(TRIM(gen)) IN ('MALE', 'FEMALE') THEN TRIM(gen)
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;



/* ================================================================================
   TARGET TABLE: silver.erp_loc_a101
   Description :
     - Customer location data from ERP
     - Country code normalization
   Source Table:
     - bronze.erp_loc_a101
================================================================================ */

INSERT INTO silver.erp_loc_a101(
    cid,
    cntry
)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE 
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE cntry
    END AS cntry
FROM bronze.erp_loc_a101;



/* ================================================================================
   TARGET TABLE: silver.erp_px_cat_g1v2
   Description :
     - Product category hierarchy from ERP
     - Direct load (no transformation)
   Source Table:
     - bronze.erp_px_cat_g1v2
================================================================================ */

INSERT INTO silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintenance
)
SELECT 
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;


