
# Power BI Semantic Model

## Overview

This layer represents the analytical semantic model built on top of the Gold data warehouse layer.

The model follows a Kimball Constellation Schema (Galaxy Schema) design using conformed dimensions to enable cross-functional reporting across sales, labour, promotions, channel performance and store profitability.

The semantic layer was designed to:

- Prevent fact-to-fact joins
- Enforce single-direction filtering
- Optimise DAX performance
- Support scalable KPI reporting
- Enable executive and operational dashboards

---

## Dimensional Model Design

### Conformed Dimensions
- Dim Date
- Dim Store
- Dim Product
- Dim Category (snowflaked from Product)
- Dim Promotion
- Dim Channel

### Fact Tables
- Fact Sales (transaction grain)
- Fact Store Daily PnL
- Fact Labour Daily
- Fact Orders
- Fact Channel Performance
- Fact Product Profitability
- Fact Promo Profitability
- Fact Promo Daily Store Product

All relationships are 1-to-many (Dimension → Fact) with single-direction filtering.

---

## Grain Definitions

| Fact Table | Grain |
|------------|-------|
| Fact Sales | 1 row per SalesLineID |
| Fact Store Daily PnL | 1 row per Store per Date |
| Fact Labour Daily | 1 row per Store per Date |
| Fact Orders | 1 row per Order |
| Fact Channel Performance | 1 row per Channel per Date |
| Fact Product Profitability | 1 row per Product |
| Fact Promo Profitability | 1 row per Promotion |
| Fact Promo Daily Store Product | 1 row per Store, Product, Promotion, Date |

---

## Relationship Strategy

- Single direction (Dim → Fact)
- No bi-directional filters
- No fact-to-fact relationships
- Snowflake only where required (Category → Product)

---

## Performance Optimisations

- Surrogate key relationships
- Numeric DateKey joins
- Indexing applied in SQL Gold layer
- Measures stored in dedicated measure table
- Hidden technical columns

---

## Governance & Best Practices

- Star/Constellation modelling
- Clear grain definition per fact
- Separation of transformation (SQL) and calculation (DAX)
- Reusable semantic layer for multiple reports

---

## Diagram

![Constellation Schema](./Constellation_Schema_Diagram.png)
