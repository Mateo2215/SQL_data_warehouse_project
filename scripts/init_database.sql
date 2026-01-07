/****************************************************************************************
* Script Name : Create_DataWarehouse.sql
* Description : 
*   Script drops (if exists) and recreates the DataWarehouse database.
*   It also creates logical schemas used in a medallion architecture:
*     - bronze  : raw / source data
*     - silver  : cleaned and transformed data
*     - gold    : business-ready / aggregated data
*
* Author      : Mateo2215
* Created On  : 2026-01-07
*
* WARNING:
*   This script will permanently delete the DataWarehouse database
*   and all contained objects if it already exists.
*
****************************************************************************************/


USE master;
GO

-- DROP and RECREATE the 'DateWarehouse' database

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

--- CREATE the DataWarehouse database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- CREATE Schemas

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
