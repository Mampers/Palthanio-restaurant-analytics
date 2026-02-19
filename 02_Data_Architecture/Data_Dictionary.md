# Data Dictionary – Palthanio Restaurant Analytics

This document defines the logical data model used in the Restaurant Analytics solution.

The model follows a Bronze → Silver → Gold medallion architecture, with the Gold layer structured as a star schema optimised for analytical reporting.

---

# 1. Model Overview

## Architecture
CSV Source Data  
→ Bronze (Raw Load)  
→ Silver (Cleansed & Transformed)  
→ Gold (Star Schema)  
→ Power BI Semantic Model  

## Design Principles

- Single version of the truth for KPIs
- Clearly defined grain for all fact tables
- Surrogate keys used for dimensional modelling
- Fact tables are additive unless otherwise stated
- Dimensions support conformed reporting across domains

---

# 2. Dimension Tables (Gold Layer)

---

## dim_date

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Dimension |
| Grain | One row per calendar date |
| Primary Key | DateKey (YYYYMMDD integer) |
| Description | Calendar dimension used for all time-based analysis |
| Business Owner | All Departments |
| Refresh Frequency | Static |

### Key Columns

- DateKey
- FullDate
- Year
- Month
- Quarter
- WeekNumber
- DayOfWeek

---

## dim_store

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Dimension |
| Grain | One row per store |
| Primary Key | StoreKey |
| Description | Store master data |
| Business Owner | Operations |
| Refresh Frequency | As required |

### Key Columns

- StoreKey
- StoreName
- Region
- OpeningDate
- StoreType

---

## dim_product

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Dimension |
| Grain | One row per product |
| Primary Key | ProductKey |
| Description | Product master data |
| Business Owner | Merchandising |
| Refresh Frequency | As required |

### Key Columns

- ProductKey
- ProductName
- CategoryKey
- StandardCost
- StandardPrice

---

## dim_category

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Dimension |
| Grain | One row per category |
| Primary Key | CategoryKey |
| Description | Product category hierarchy |
| Business Owner | Merchandising |
| Refresh Frequency | As required |

---

## dim_promotion

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Dimension |
| Grain | One row per promotion |
| Primary Key | PromotionKey |
| Description | Promotion master data |
| Business Owner | Marketing |
| Refresh Frequency | As required |

---

# 3. Fact Tables (Gold Layer)

---

## fact_sales

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Fact |
| Grain | One row per sales line item |
| Primary Key | SalesLineID |
| Foreign Keys | DateKey, StoreKey, ProductKey, PromotionKey |
| Description | Transaction-level sales data |
| Business Owner | Finance |
| Refresh Frequency | Daily |

### Measures

- Quantity
- NetRevenue
- DiscountAmount
- CostOfGoods
- GrossProfit

---

## fact_inventory_waste

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Fact |
| Grain | One row per waste event (StoreKey, DateKey, ProductKey) |
| Primary Key | WasteID |
| Foreign Keys | DateKey, StoreKey, ProductKey |
| Description | Inventory waste tracking |
| Business Owner | Operations |
| Refresh Frequency | Daily |

### Measures

- WasteQuantity
- WasteCost

---

## fact_labour_costs

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Fact |
| Grain | One row per StoreKey, DateKey, Role |
| Primary Key | LabourID |
| Foreign Keys | DateKey, StoreKey |
| Description | Labour cost per store per day |
| Business Owner | Operations |
| Refresh Frequency | Daily |

### Measures

- LabourHours
- TotalLabourCost

---

## fact_promo_performance

| Attribute | Value |
|------------|--------|
| Layer | Gold |
| Table Type | Aggregate Fact |
| Grain | One row per DateKey, StoreKey, PromotionKey |
| Primary Key | Composite (DateKey, StoreKey, PromotionKey) |
| Foreign Keys | DateKey, StoreKey, PromotionKey |
| Description | Aggregated promotion performance metrics |
| Business Owner | Marketing |
| Refresh Frequency | Daily |

### Measures

- PromoRevenue
- PromoDiscount
- PromoGrossProfit

---

# 4. Grain Definitions

All fact tables explicitly define their grain. No fact table contains mixed grain.

- Sales = Line Item
- Waste = Event Level
- Labour = Store-Day Level
- Promotion = Store-Day-Promotion Level

This ensures additive behaviour and avoids double counting.

---

# 5. Conformed Dimensions

The following dimensions are conformed across all fact tables:

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

# 6. Data Governance Notes

- All KPIs are calculated from Gold layer tables only.
- Surrogate keys are used to maintain referential integrity.
- No business logic is implemented in Power BI; transformations occur in SQL.
- Data validation checks are performed during Silver layer processing.

---

# 7. Future Enhancements

- Role dimension for labour modelling
- Channel dimension for online vs in-store
- Snapshot fact for inventory levels
- Slowly Changing Dimension (SCD) handling for product price changes
