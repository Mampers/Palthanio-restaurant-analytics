# Bronze Layer – Data Ingestion

## Purpose

The Bronze layer represents the raw ingestion layer of the Palthanio Restaurant Analytics solution.

Its purpose is to:
- Land source CSV data into SQL Server
- Preserve raw data without transformation
- Maintain full traceability to source systems
- Provide a controlled hand-off point to the Silver layer

---

## Architecture Pattern

Each dataset follows a two-step ingestion approach:

Stage → Raw

### 1️⃣ Stage Tables
- Mirror the exact structure of source CSV files
- Used as temporary landing tables
- Populated via BULK INSERT
- No transformations applied

### 2️⃣ Raw Tables
- Persisted bronze storage layer
- Include metadata columns:
  - `SourceSystem`
  - `SourceFile`
  - `LoadDts`
- Minimal cleansing only (e.g. TRIM)
- No joins
- No business logic
- No data type conversions

---

## Design Principles

- Data is stored as-is from source
- Numeric fields remain VARCHAR where appropriate
- No surrogate keys generated
- No dimensional modelling performed
- Full lineage preserved

This ensures:
- Reproducibility
- Auditability
- Debugging capability
- Clear separation of concerns

---

## Load Process

1. Create stage table
2. Execute BULK INSERT into stage
3. Insert from stage into raw
4. Add metadata
5. Silver layer performs cleansing and typing

---

## Included Entities

### Dimensions
- dim_category
- dim_date
- dim_product
- dim_store
- dim_channel_paymentmethod

### Facts
- fact_sales
- fact_orders_2025
- fact_inventory_waste
- fact_labor_costs
- fact_promo_performance

---

## What Happens Next

The Silver layer performs:
- Data type conversion
- Deduplication
- Key standardisation
- Null handling
- Business rule enforcement

