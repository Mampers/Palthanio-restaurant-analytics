# Architecture Decisions – Palthanio Restaurant Analytics

## Purpose

This document outlines the key architectural decisions made when designing the Palthanio Restaurant Analytics solution.

The goal was to build a scalable, maintainable, and enterprise-ready analytical model aligned with dimensional modelling best practices.

---

## 1. Medallion Architecture (Bronze → Silver → Gold)

The solution follows a layered medallion architecture:

- **Bronze** – Raw ingestion from CSV source files (no transformations)
- **Silver** – Data cleansing, validation, standardisation
- **Gold** – Dimensional star schema optimised for reporting
- **Power BI** – Semantic layer for KPI logic and visualisation

### Why?

- Separation of concerns
- Improved data quality control
- Clear transformation lineage
- Production-ready warehouse pattern

---

## 2. Dimensional Modelling Approach

A **constellation schema** was selected instead of a single fact star schema.

### Why Constellation?

- Multiple business processes (Sales, Labour, Waste, Promotions)
- Shared conformed dimensions (Date, Store, Product, Promotion)
- Clear grain separation per fact
- Reduced ambiguity across reporting domains

No fact-to-fact joins are permitted.

---

## 3. Explicit Grain Definition

Each fact table defines its grain:

- Sales → Line Item Level
- Waste → Event Level
- Labour → Store-Day Level
- Promotion → Store-Day-Promotion Level

This prevents:
- Double counting
- Ambiguous aggregations
- Filter propagation errors

---

## 4. Surrogate Keys

All dimension tables use surrogate integer keys.

### Why?

- Improved join performance
- Stability against business key changes
- Referential integrity enforcement

---

## 5. Relationship Design

- Single-direction filtering (Dimension → Fact)
- No bi-directional relationships
- No circular relationships

This ensures:
- Predictable filter behaviour
- Better performance
- Reduced ambiguity in multi-fact models

---

## 6. DAX Strategy

DAX measures are layered:

- Base Measures (aggregations)
- Derived Measures (financial logic)
- KPI Measures (business definitions)
- Presentation Measures (formatting / switching logic)

This prevents circular dependencies and improves maintainability.

---

## 7. Business Logic Location

All data transformation logic is implemented in SQL (Silver layer).

Power BI contains:
- Measures
- Calculated KPI logic
- No transformation of raw data

This maintains a clean separation between data engineering and reporting.

---
