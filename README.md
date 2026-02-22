# Palthanio Restaurant Analytics

An end-to-end enterprise Business Intelligence solution demonstrating dimensional modelling, data warehousing architecture, KPI governance, and semantic model design using SQL Server and Power BI.

---

## Executive Summary

Palthanio Restaurant Analytics is a production-style BI solution built to support financial and operational decision-making across a multi-site restaurant environment.

The project demonstrates how raw operational data can be transformed into a governed, scalable analytics platform using a Bronze → Silver → Gold data warehouse architecture and a structured Power BI semantic model.

The focus of this solution is not only dashboard design, but enterprise modelling principles including:

- Explicit fact table grain definition
- Conformed dimensions
- Surrogate key strategy
- Layered DAX architecture
- Governance and reconciliation controls
- Performance-aware semantic modelling

---

## Business Objectives

- Monitor Revenue, Gross Profit and Profit After Labour
- Track Labour Cost % and Waste Impact
- Analyse Store-Level Performance
- Evaluate Promotion Effectiveness
- Replace manual Excel reporting with governed dashboards
- Provide a single version of truth for KPI reporting

---

## Architecture Overview

### Data Warehouse (SQL Server)

The solution follows a medallion architecture:


CSV Source Data
→ Bronze (Raw ingestion)
→ Silver (Cleansed & validated)
→ Gold (Dimensional star schema)
→ Power BI Semantic Model


### Gold Layer Model

The Gold layer implements a constellation schema with multiple fact tables and shared conformed dimensions.

**Fact Tables**
- fact_sales
- fact_labour_costs
- fact_inventory_waste
- fact_promo_performance

**Conformed Dimensions**
- dim_date
- dim_store
- dim_product
- dim_promotion
- dim_category

Each fact table has explicitly defined grain to prevent double counting and ensure additive behaviour.

---

## Power BI Semantic Model

The Power BI layer is designed using a structured DAX strategy:

- Base Measures (aggregations)
- Derived Measures (financial logic)
- KPI Measures (business definitions)
- Presentation Measures (visual logic)

Model design principles:

- Single-direction relationships
- No fact-to-fact joins
- No business transformations in Power BI
- Performance-aware DAX implementation

---

## Governance & Quality Controls

- Surrogate keys enforce referential integrity
- Explicit Slowly Changing Dimension strategy
- QA reconciliation checks between layers
- No duplicated KPI logic
- Centralised semantic model approach

---

## Key KPIs Delivered

- Total Revenue
- Gross Profit
- Profit After Labour
- Labour Cost %
- Waste Cost %
- Promotion ROI
- Time Intelligence (MoM / YoY)

---

## Technology Stack

- SQL Server (T-SQL)
- Dimensional Modelling (Kimball methodology)
- Bronze / Silver / Gold architecture
- Power BI
- DAX
- Power Query

---

## Repository Structure


01_Project_Overview
02_Data_Architecture
03_SQL_Data_Warehouse
04_Power_BI_Modelling
/images


---

## Author

**Paul Mampilly**  
PL-300 Certified Power BI Developer  
Enterprise Data Modelling | Analytics Engineering | Power BI

---
🎯 Why This Version
