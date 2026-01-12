SQL Data Warehouse Project 🚀
📌 Project Overview

This project demonstrates the design and implementation of a modern SQL-based Data Warehouse using a layered architecture (Bronze → Silver → Gold).
It covers the full data pipeline: raw data ingestion, data cleansing & transformation, and analytical data modeling using fact and dimension tables.

The repository is intended as:

a learning project for Data Engineering / Analytics Engineering

a portfolio-ready example of end‑to‑end SQL data warehousing

a reference for best practices in data modeling and SQL transformations

🏗️ Architecture

The warehouse follows a Medallion Architecture:

🥉 Bronze Layer – Raw Data

Raw ingestion of CRM and ERP source files (CSV)

Minimal transformation

Schema closely matches source systems

Acts as a data landing zone

🥈 Silver Layer – Clean & Conformed Data

Data cleansing and standardization

Deduplication and validation

Type casting and business rule application

Integration of CRM and ERP datasets

🥇 Gold Layer – Analytics & Reporting

Dimensional model (Star Schema)

Business-friendly naming

Fact and dimension tables optimized for BI and analytics

📊 Data Model (Gold Layer)
Dimensions
gold.dim_customers

Customer master dimension

Combines CRM and ERP customer data

Handles conflicting gender information using defined precedence rules

gold.dim_products

Product master dimension

Enriched with category hierarchy from ERP

Filters out historical product versions

Fact Table
gold.fact_sales

Central sales fact table

Grain: one row per order, product, and customer

Measures:

Sales amount

Quantity

Price

Linked to customer and product dimensions via surrogate keys

🔄 ETL / ELT Flow

Load (Bronze)

CSV files loaded using BULK INSERT

Tables truncated before each load

Transform (Silver)

Data normalization (gender, country, product lines)

Date validation and correction

Deduplication using window functions

Derived fields (e.g. product end date)

Model (Gold)

Creation of analytical views

Surrogate keys using ROW_NUMBER()

Fact-to-dimension relationships

🧠 Key SQL Concepts Used

Window Functions (ROW_NUMBER, LEAD)

Data Cleansing with CASE, TRIM, UPPER

Deduplication logic

Slowly Changing Dimension handling (type‑2‑like logic for products)

Star Schema design

Defensive SQL (NULL handling, invalid date handling)

🛠️ Tech Stack

SQL Server (T‑SQL)

CSV source files

Git / GitHub

✅ Data Quality Rules Implemented

Removal of duplicate customer records

Validation of date formats

Standardization of categorical values

Handling of missing or invalid numeric values

Preservation of referential integrity in fact tables

🎯 Use Cases

Sales performance analysis

Customer segmentation

Product and category reporting

BI dashboarding (Power BI / Tableau ready)

📈 Future Improvements

Add incremental loads

Implement Slowly Changing Dimensions (SCD Type 2)

Add audit and reconciliation tables

Introduce automated data quality checks

Create sample BI dashboards

👤 Author

Created by Mateusz
This project was built as part of a learning journey in Data Engineering & Analytics Engineering.

⭐ If you find this useful

Feel free to star the repository, fork it, or use it as inspiration for your own data warehouse projects!
