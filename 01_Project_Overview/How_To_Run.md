# How To Run – Palthanio Restaurant Analytics

---

# Prerequisites

- SQL Server installed
- Power BI Desktop
- Access to project repository
- SSMS or equivalent SQL client

---

# Step 1 – Load Bronze Layer

Navigate to:

03_SQL_Data_Warehouse/Bronze_Load/

Execute all scripts in order.

This loads raw CSV data into bronze schema tables.

---

# Step 2 – Transform to Silver Layer

Navigate to:

03_SQL_Data_Warehouse/Silver_Transform/

Execute transformation scripts.

This performs:
- Data cleansing
- Standardisation
- Validation
- Deduplication

---

# Step 3 – Build Gold Layer

Navigate to:

03_SQL_Data_Warehouse/Gold_Model/

Execute dimensional model scripts.

Ensure:
- All dimension tables created first
- Fact tables loaded after
- Foreign key constraints validated

---

# Step 4 – Run QA Checks

Execute:

03_SQL_Data_Warehouse/QA_Reconciliation_Checks.sql

Validate:
- Row counts
- Revenue totals
- No orphan keys
- No duplicates

---

# Step 5 – Open Power BI

- Open PBIX file
- Confirm SQL connection
- Refresh dataset

---

# Expected Output

- Constellation semantic model
- Conformed dimensions
- Financial & operational dashboards
- KPI-driven reporting

---

# Notes

- All transformations occur in SQL
- Power BI contains presentation logic only
- Model designed for scalability and governance

---
