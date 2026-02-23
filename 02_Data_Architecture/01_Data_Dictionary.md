# Data Dictionary – Palthanio Restaurant Analytics

---

# 1. Overview

## 1.1 Purpose

This document defines the logical and physical structure of the **Gold layer dimensional model** used in the Palthanio Restaurant Analytics solution.

The model supports financial, operational, promotional and performance reporting via Power BI.

---

# 2. Architecture

## 2.1 Medallion Architecture


CSV Source Data
→ Bronze Layer (Raw ingestion)
→ Silver Layer (Cleansed & validated)
→ Gold Layer (Dimensional star schema)
→ Power BI Semantic Model


## 2.2 Design Principles

- Single version of truth for all KPIs  
- Explicit grain defined for every fact table  
- No mixed-grain tables permitted  
- Surrogate integer keys used for dimensional joins  
- Conformed dimensions across fact tables  
- No business logic implemented in Power BI (logic resides in SQL)  
- Fact tables contain additive measures at lowest possible grain  
- Referential integrity enforced at Gold layer  

---

# 3. Gold Layer – Dimensional Model

---

## 3.1 Dimension Tables

---

### dim_date

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Dimension |
| Grain | One row per calendar date |
| Primary Key | DateKey (INT, YYYYMMDD) |
| SCD Type | Type 0 (Static) |
| Business Owner | All Departments |
| Refresh Frequency | Static |

#### Key Columns

| Column | Data Type | Nullable | Description |
|--------|----------|----------|------------|
| DateKey | INT | No | Surrogate date key |
| FullDate | DATE | No | Calendar date |
| Year | INT | No | Calendar year |
| Quarter | INT | No | Calendar quarter |
| Month | INT | No | Month number |
| WeekNumber | INT | No | ISO week |
| DayOfWeek | VARCHAR(10) | No | Day name |

---

### dim_store

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Dimension |
| Grain | One row per store |
| Primary Key | StoreKey (INT) |
| SCD Type | Type 1 |
| Business Owner | Operations |
| Refresh Frequency | As required |

#### Key Columns

| Column | Data Type | Nullable | Description |
|--------|----------|----------|------------|
| StoreKey | INT | No | Surrogate key |
| StoreName | VARCHAR(100) | No | Store name |
| Region | VARCHAR(50) | No | Geographic region |
| OpeningDate | DATE | Yes | Opening date |
| StoreType | VARCHAR(50) | Yes | Format classification |

---

### dim_product

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Dimension |
| Grain | One row per product |
| Primary Key | ProductKey (INT) |
| SCD Type | Type 2 (Planned Enhancement) |
| Business Owner | Merchandising |
| Refresh Frequency | As required |

#### Key Columns

| Column | Data Type | Nullable | Description |
|--------|----------|----------|------------|
| ProductKey | INT | No | Surrogate key |
| ProductName | VARCHAR(150) | No | Product name |
| CategoryKey | INT | No | Category FK |
| StandardCost | DECIMAL(18,2) | No | Standard cost |
| StandardPrice | DECIMAL(18,2) | No | Selling price |

---

### dim_category

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Dimension |
| Grain | One row per category |
| Primary Key | CategoryKey |
| SCD Type | Type 1 |
| Business Owner | Merchandising |
| Refresh Frequency | As required |

---

### dim_promotion

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Dimension |
| Grain | One row per promotion |
| Primary Key | PromotionKey |
| SCD Type | Type 1 |
| Business Owner | Marketing |
| Refresh Frequency | As required |

---

## 3.2 Fact Tables

---

### fact_sales

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Transaction Fact |
| Grain | One row per sales line item |
| Primary Key | SalesLineID |
| Foreign Keys | DateKey, StoreKey, ProductKey, PromotionKey |
| Business Owner | Finance |
| Refresh Frequency | Daily |

#### Measures

| Column | Data Type | Additivity | Description |
|--------|----------|------------|------------|
| Quantity | INT | Additive | Units sold |
| NetRevenue | DECIMAL(18,2) | Additive | Revenue after discount |
| DiscountAmount | DECIMAL(18,2) | Additive | Applied discount |
| CostOfGoods | DECIMAL(18,2) | Additive | Product cost |
| GrossProfit | DECIMAL(18,2) | Additive | Revenue minus COGS |

---

### fact_inventory_waste

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Event Fact |
| Grain | One row per waste event (Store, Date, Product) |
| Primary Key | WasteID |
| Foreign Keys | DateKey, StoreKey, ProductKey |
| Business Owner | Operations |
| Refresh Frequency | Daily |

#### Measures

| Column | Data Type | Additivity | Description |
|--------|----------|------------|------------|
| WasteQuantity | INT | Additive | Units wasted |
| WasteCost | DECIMAL(18,2) | Additive | Cost impact |

---

### fact_labour_costs

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Snapshot Fact |
| Grain | One row per Store, Date |
| Primary Key | LabourID |
| Foreign Keys | DateKey, StoreKey |
| Business Owner | Operations |
| Refresh Frequency | Daily |

#### Measures

| Column | Data Type | Additivity | Description |
|--------|----------|------------|------------|
| LabourHours | DECIMAL(10,2) | Additive | Total labour hours |
| TotalLabourCost | DECIMAL(18,2) | Additive | Daily labour cost |

---

### fact_promo_performance

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Aggregate Fact |
| Grain | One row per Date, Store, Promotion |
| Primary Key | Composite (DateKey, StoreKey, PromotionKey) |
| Foreign Keys | DateKey, StoreKey, PromotionKey |
| Business Owner | Marketing |
| Refresh Frequency | Daily |

#### Measures

| Column | Data Type | Additivity | Description |
|--------|----------|------------|------------|
| PromoRevenue | DECIMAL(18,2) | Additive | Revenue from promotion |
| PromoDiscount | DECIMAL(18,2) | Additive | Discount value |
| PromoGrossProfit | DECIMAL(18,2) | Additive | Profit from promotion |

---

# 4. Grain Definitions

All fact tables explicitly define their grain. No fact table contains mixed grain.

- Sales = Line Item  
- Waste = Event Level  
- Labour = Store-Day Level  
- Promotion = Store-Day-Promotion Level  

This ensures additive behaviour and prevents double counting.

---

# 5. Conformed Dimensions

The following dimensions are shared across fact tables:

- dim_date  
- dim_store  
- dim_product  
- dim_promotion  

This enables cross-domain reporting such as:

- Profit after labour by store  
- Waste impact on margin  
- Promotion ROI by product  
- Labour efficiency by day  

---

# 6. Data Governance & Quality

- All KPIs are calculated from Gold layer tables only  
- Surrogate keys enforce referential integrity  
- Business transformations occur in SQL (Silver layer)  
- Power BI contains presentation logic only  
- Validation checks performed during Silver processing  
- Null handling and standardisation applied before Gold load  

---

# 7. Future Enhancements

- Role dimension for labour modelling  
- Channel dimension (online vs in-store)  
- Inventory snapshot fact table  
- Full SCD Type 2 implementation for product price changes  
- Automated data quality audit framework  

---
