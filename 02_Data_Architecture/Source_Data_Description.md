
# Source Data Description – Palthanio Restaurant Analytics

This document describes the source data inputs used in the Restaurant Analytics solution.

The solution uses structured CSV extracts representing operational systems. These files are ingested into the Bronze layer before cleansing and transformation into the Silver and Gold layers.

---

# 1. Overview

| Source Type | Format | Ingestion Method | Refresh Frequency |
|-------------|--------|-----------------|------------------|
| Transaction Data | CSV | Bulk Load (SQL Server) | Daily |
| Labour Data | CSV | Bulk Load | Daily |
| Inventory Waste | CSV | Bulk Load | Daily |
| Product Master | CSV | Bulk Load | As Required |
| Store Master | CSV | Bulk Load | As Required |
| Promotion Master | CSV | Bulk Load | As Required |

---

# 2. Source Files

---

## orders.csv

### Description
Transactional sales data captured at order line level.

### Grain
One row per sales line item.

### Expected Volume
High volume (transactional).

### Key Fields

| Column | Description |
|--------|------------|
| OrderID | Unique order identifier |
| OrderDate | Date of transaction |
| StoreID | Store identifier |
| ProductID | Product sold |
| PromotionID | Promotion applied (nullable) |
| Quantity | Units sold |
| NetRevenue | Revenue after discount |
| DiscountAmount | Discount applied |
| CostOfGoods | Direct product cost |

### Data Quality Considerations

- OrderDate must be valid and non-null
- NetRevenue should not be negative
- StoreID and ProductID must exist in master tables

---

## labour.csv

### Description
Daily labour cost data by store and role.

### Grain
One row per StoreID, Date, Role.

### Key Fields

| Column | Description |
|--------|------------|
| StoreID | Store identifier |
| LabourDate | Date |
| Role | Staff role |
| LabourHours | Hours worked |
| TotalLabourCost | Total labour cost |

### Data Quality Considerations

- Labour hours must be non-negative
- Labour cost should reconcile with payroll totals

---

## inventory_waste.csv

### Description
Inventory waste events recorded per product and store.

### Grain
One row per StoreID, Date, ProductID waste event.

### Key Fields

| Column | Description |
|--------|------------|
| WasteID | Unique waste event ID |
| StoreID | Store identifier |
| ProductID | Product wasted |
| WasteDate | Date |
| WasteQuantity | Quantity wasted |
| WasteCost | Cost impact |

### Data Quality Considerations

- WasteQuantity must be non-negative
- WasteCost must align with product standard cost

---

## products.csv

### Description
Product master reference data.

### Grain
One row per ProductID.

### Key Fields

| Column | Description |
|--------|------------|
| ProductID | Unique product identifier |
| ProductName | Product description |
| CategoryID | Product category |
| StandardCost | Cost per unit |
| StandardPrice | Selling price |

---

## stores.csv

### Description
Store master data.

### Grain
One row per StoreID.

### Key Fields

| Column | Description |
|--------|------------|
| StoreID | Unique store identifier |
| StoreName | Store name |
| Region | Geographic region |
| OpeningDate | Store opening date |

---

## promotions.csv

### Description
Promotion master data.

### Grain
One row per PromotionID.

### Key Fields

| Column | Description |
|--------|------------|
| PromotionID | Unique promotion identifier |
| PromotionName | Promotion description |
| StartDate | Promotion start |
| EndDate | Promotion end |
| DiscountType | Percentage or fixed |

---

# 3. Data Ingestion Approach

All source files are:

- Loaded into Bronze schema without transformation
- Type-cast and cleansed in Silver layer
- Modelled into star schema in Gold layer

No transformations are performed at ingestion stage.

---

# 4. Assumptions

- Files are delivered as structured CSV extracts
- No real-time streaming required
- Daily batch processing is sufficient
- Master data updates are periodic and controlled

---

# 5. Known Limitations

- No customer-level data included
- No real-time POS streaming
- No historical SCD tracking in source layer
