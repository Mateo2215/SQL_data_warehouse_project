/****************************************************************************************
* Script Name : Load_Bronze_Tables_From_CSV.sql
* Description :
*   Script truncates and reloads BRONZE layer tables using BULK INSERT
*   from CSV files originating from CRM and ERP source systems.
*
*   Loading approach:
*     - TRUNCATE TABLE to ensure full refresh
*     - BULK INSERT with FIRSTROW = 2 to skip CSV headers
*
*   Source systems & files:
*     - CRM:
*         cust_info.csv        -> bronze.crm_cust_info
*         prd_info.csv         -> bronze.crm_prd_info
*         sales_details.csv    -> bronze.crm_sales_details
*     - ERP:
*         cust_az12.csv        -> bronze.erp_cust_az12
*         loc_a101.csv         -> bronze.erp_loc_a101
*         px_cat_g1v2.csv      -> bronze.erp_px_cat_g1v2
*
* Author      : <Your Name>
* Created On  : 2026-01-07
*
* WARNING:
*   This script performs a FULL REFRESH of BRONZE tables.
*   All existing data in the target tables will be permanently removed.
*
* NOTES:
*   - Ensure SQL Server has access to the source file paths.
*   - BULK INSERT requires appropriate file system permissions.
*
****************************************************************************************/

TRUNCATE TABLE bronze.crm_cust_info;

BULK INSERT bronze.crm_cust_info
FROM -- (Please insert file path here)
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

TRUNCATE TABLE bronze.crm_prd_info;

BULK INSERT bronze.crm_prd_info
FROM  -- (Please insert file path here)
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

TRUNCATE TABLE bronze.crm_sales_details;

BULK INSERT bronze.crm_sales_details
FROM  -- (Please insert file path here)
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

TRUNCATE TABLE bronze.erp_cust_az12;

BULK INSERT bronze.erp_cust_az12
FROM  -- (Please insert file path here)
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

TRUNCATE TABLE bronze.erp_loc_a101;

BULK INSERT bronze.erp_loc_a101
FROM  -- (Please insert file path here)
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

TRUNCATE TABLE bronze.erp_px_cat_g1v2;

BULK INSERT bronze.erp_px_cat_g1v2
FROM -- (Please insert file path here)
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
