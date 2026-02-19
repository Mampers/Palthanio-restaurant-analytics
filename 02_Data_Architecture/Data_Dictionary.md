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
| D

