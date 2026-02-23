# DAX Strategy

## Overview

The Power BI semantic model follows a layered DAX design pattern to ensure scalability, maintainability, and performance.

Measures are structured into four logical layers:

1. **Base Measures**
2. **Derived Measures**
3. **KPI Measures**
4. **Presentation Measures**

This modular architecture prevents duplication, improves readability, and ensures consistent business logic across all report pages.

---

## Measure Layering Approach

### 1️⃣ Base Measures

Base measures are simple aggregations directly from fact tables.

They:
- Use SUM, COUNT, COUNTROWS, DISTINCTCOUNT
- Do not reference other measures
- Represent atomic business quantities

**Examples:**
- Total Net Revenue
- Total Orders
- Total COGS
- Total Labour Cost
- Total Waste Cost
- Total Discount Given
- Promo Units Sold

**Design Rule:**  
Base measures should never depend on other measures.

---

### 2️⃣ Derived Measures

Derived measures build business logic using base measures.

They:
- Combine base measures using arithmetic logic
- Represent meaningful financial values
- Centralise reusable business calculations

**Examples:**
- Gross Profit
- Net Profit
- Profit After COGS
- Profit After Labour
- Profit After Labour and COGS
- Total Cost (Labour + Waste)
- Profit per Discount (£)

**Design Rule:**  
Derived measures must reference base measures, not raw columns.

---

### 3️⃣ KPI Measures

KPI measures represent performance indicators, typically expressed as:

- Percentages
- Ratios
- Efficiency metrics
- Comparative measures

They:
- Use DIVIDE() to prevent divide-by-zero errors
- Enable benchmarking across stores, products, and time

**Examples:**
- Gross Margin %
- Labour Cost %
- Waste Cost %
- Discount Rate %
- Total Cost %
- Product Margin %
- Average Order Value (AOV)
- Total Promo Profit Margin %

**Design Rule:**  
KPI measures should be built on derived/base measures only.

---

### 4️⃣ Presentation Measures

Presentation measures exist purely for report visualisation and UX.

They:
- Power waterfall charts
- Return dynamic product/store names
- Control ranking outputs
- Provide dynamic titles

**Examples:**
- Waterfall Value
- Top Profit Product (Name)
- Lowest Margin Product (Name)

**Design Rule:**  
Presentation measures must not contain core business logic.

---

## Folder Structure

Measures are organised using Display Folders:

- 01 Base
- 02 Derived
- 03 KPI
- 04 Presentation

This ensures clarity and separation of concerns.

---

## Relationship & Model Strategy

- Constellation (Galaxy) schema design
- Conformed dimensions across all fact tables
- Single-direction filtering (Dimension → Fact)
- No fact-to-fact joins
- Snowflake used only where required (Category → Product)

---

## Performance Considerations

- Integer surrogate keys (DateKey, ProductKey, StoreKey)
- Reusable measure logic (avoid duplication)
- DIVIDE() instead of “/”
- Minimal calculated columns
- Iterators (SUMX, etc.) used only when required
- Business transformations handled in SQL (Gold layer)

---

## Summary

This DAX architecture:

- Enforces modular calculation design
- Separates aggregation from business logic
- Enables scalable KPI expansion
- Improves report performance
- Supports enterprise-level maintainability
