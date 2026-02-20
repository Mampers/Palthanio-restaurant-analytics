# 🥈 Silver Layer – Data Transformation

## Overview

The **Silver layer** represents the cleansed, standardised and enriched data layer within the Palthanio Restaurant Analytics solution.

It transforms raw Bronze data into structured, analytics-ready tables by:

- Cleaning and trimming text fields  
- Standardising casing and formats  
- Converting data types (varchar → int / decimal / date / time)  
- Removing unnecessary columns  
- Deduplicating records  
- Deriving calculated business metrics  
- Enforcing consistent business keys  

The Silver layer prepares data for the **Gold star schema model**.

---

## 🏗 Architecture Context

CSV Files
↓
Bronze (Raw + Staging)
↓
Silver (Cleaned + Enriched)
↓
Gold (Star Schema)
↓
Power BI Semantic Model


---

# 📂 Tables in the Silver Layer

---

## 🔹 Fact Tables

### 1️⃣ `fact_sales`

**Source:** `bronze.fact_sales_raw`

**Key Transformations**
- Converts monetary columns to `decimal(12,2)`
- Converts `TransactionTime` to `time`
- Renames technical keys to business codes
- Calculates:
  - `GrossProfit`
  - `GrossMargin`
  - `GrossMarginPct`

**Purpose**
Provides clean transactional sales data ready for financial and operational reporting.

---

### 2️⃣ `fact_labour_costs`

**Source:** `bronze.fact_labor_costs_raw`

**Key Transformations**
- Converts numeric fields correctly
- Standardises store codes
- Calculates:
  - `CalcLabourCost`
  - `LabourCostVariance`
  - `LabourCostVariancePct`
  - `EffectiveHourlyRate`

**Purpose**
Supports labour efficiency and cost control analysis.

---

### 3️⃣ `fact_inventory_waste`

**Source:** `bronze.fact_inventory_waste_stage_wide`

**Key Transformations**
- Converts waste quantities and cost fields
- Standardises waste reasons
- Adds KPI flags:
  - `WasteUnitCost`
  - `IsExpired`
  - `IsDamaged`
  - `IsPrepError`
  - `IsHighCostWaste`
  - `IsHighQtyWaste`

**Purpose**
Enables operational waste monitoring and cost reduction insights.

---

### 4️⃣ `fact_orders_2025`

**Source:** `bronze.fact_orders_2025_raw`

**Key Transformations**
- Converts revenue fields to decimals
- Standardises keys
- Ensures date integrity

**Purpose**
Supports order-level performance analysis.

---

### 5️⃣ `fact_promo_performance`

**Source:** `bronze.fact_promo_performance_raw`

**Key Transformations**
- Converts `PromoDate` to `date`
- Creates `PromoDateKey`
- Converts financial metrics to decimal
- Calculates:
  - `NetRevenueAfterDiscount`
  - `DiscountPct`

**Purpose**
Enables promotion ROI and campaign effectiveness analysis.

---

## 🔹 Dimension Tables

---

### 6️⃣ `dim_date`

**Source:** `bronze.dim_date_stage`

**Enrichments**
- YearMonth labels
- Quarter labels
- Offset calculations
- YTD flag
- IsCurrentMonth / IsLastMonth
- DayType (Weekday / Weekend)

**Purpose**
Provides a robust analytical date dimension for time intelligence.

---

### 7️⃣ `dim_product`

**Source:** `bronze.dim_product_stage`

**Enrichments**
- `GrossMargin`
- `GrossMarginPct`
- `PrepTimeMinutes`
- `PriceBand`
- `CostBand`
- `IsHighMargin`

**Purpose**
Supports profitability and product performance analysis.

---

### 8️⃣ `dim_store`

**Source:** `bronze.dim_store_stage`

**Enrichments**
- Parsed `OpenDate`
- `OpenDateKey`
- `StoreAgeDays`
- `StoreSizeBand`

**Purpose**
Enables regional, store maturity, and size-based reporting.

---

### 9️⃣ `dim_category`

**Source:** `bronze.dim_category_stage`

**Enrichments**
- Standardised department naming
- Flags:
  - `IsFood`
  - `IsBeverage`
  - `IsOther`

**Purpose**
Supports hierarchical category reporting.

---

### 🔟 `dim_channel`

**Source:** `bronze.dim_channel_paymentmethod_raw`

**Transformations**
- Trimmed and standardised channel/payment values
- Deduplicated rows

**Purpose**
Supports sales segmentation by channel and payment method.

---

### 1️⃣1️⃣ `dim_promotion`

**Source:** `bronze.dim_promotion_raw`

**Enrichments**
- `PromotionDurationDays`
- `IsActiveToday`
- `IsValidDateRange`

**Purpose**
Supports promotion lifecycle and effectiveness analysis.

---

# 🎯 Design Principles

The Silver layer follows these principles:

- Idempotent scripts (safe to rerun)
- Deterministic transformations
- Explicit datatype conversion
- Minimal business logic (heavy aggregations reserved for Gold)
- Clean separation between ingestion (Bronze) and modelling (Gold)

---

# 📊 What This Layer Enables

The Silver layer ensures:

- Reliable financial calculations  
- Clean dimensional joins  
- Accurate KPI derivation  
- High-quality Power BI semantic modelling  

It acts as the **trusted analytical foundation** before star schema modelling.

---

# 🚀 Next Stage

The next stage is the **Gold Layer**, where:

- Star schema fact/dimension tables are structured
- Surrogate keys may be introduced
- Aggregated KPIs are materialised
- Business-facing data marts are built
