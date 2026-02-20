# 🥇 Gold Layer – Business Semantic Model  
**Project:** Palthanio Restaurants Data Warehouse  
**Database:** PalthanioRestaurants  
**Layer Type:** Curated Business Layer (Star Schema + Aggregates)

---

# 📌 Purpose of the Gold Layer

The Gold layer represents the **business-ready semantic model** of the Palthanio Restaurants data warehouse.

It is:

- Clean
- Curated
- Aggregated where required
- Optimised for Power BI
- Designed using Star Schema principles
- Safe for executive reporting

The Gold layer is built from the **Silver layer** and contains:

- Business-facing dimensions
- Atomic fact tables
- Derived aggregate fact tables
- Commercial KPIs

---

# 🧱 Gold Layer Architecture

The Gold layer follows a Star Schema model.

## 🔷 Dimensions

| Table | Purpose |
|--------|---------|
| `01_dim_date` | Calendar dimension (YYYYMMDD key) |
| `02_dim_store` | Store information + active status |
| `03_dim_product` | Product commercial attributes |
| `04_dim_category` | Category hierarchy + revenue classification |
| `05_dim_channel` | Sales channel dimension |
| `06_dim_promotion` | Promotion attributes + classification |

---

## 🔶 Atomic Fact Tables

These represent lowest-level transaction grain.

| Table | Grain | Description |
|--------|--------|-------------|
| `07_fact_sales` | 1 row per SalesLineID | Core sales transactions |
| `fact_orders` | 1 row per OrderID | Order-level revenue |
| `fact_inventory_waste` | 1 row per waste event | Waste tracking |
| `fact_labour_daily` | Date x Store | Daily labour aggregation |

---

## 🔶 Derived / Aggregated Facts

These are built from atomic facts for performance and reporting.

| Table | Grain | Description |
|--------|--------|-------------|
| `fact_store_daily_pnl` | Date x Store | Daily P&L view |
| `fact_channel_performance` | Channel x PaymentMethod | Channel profitability |
| `fact_product_profitability` | Product | Product-level margin |
| `fact_promo_profitability` | Promotion | Promotion ROI |
| `fact_promo_performance` | PromoDate x Store x Product | Promotion performance |

---

# 📊 Key Business KPIs

The Gold layer enables:

- Gross Revenue
- Net Revenue
- Gross Profit
- Gross Margin %
- Units Sold
- Labour Cost
- Profit After Labour
- Waste Cost
- Promotion ROI
- Profit per Discount Pound
- Channel Profitability
- Store Daily P&L

All calculations use safe division logic (`NULLIF`) to prevent divide-by-zero errors.

---

# 🧠 Design Principles

The Gold layer follows:

✔ Kimball dimensional modelling  
✔ Clean surrogate-style keys (codes aligned across dims/facts)  
✔ Separation of concerns (Bronze → Silver → Gold)  
✔ No raw text conversions  
✔ No transformation logic left in Gold  
✔ Business-friendly column naming  
✔ Indexed for Power BI performance  

---

# 🔗 Referential Integrity

Where applicable, foreign keys are enforced between:

- `fact_orders` → date, store, channel
- Fact tables → dimension codes

This ensures:

- Data consistency
- Reliable joins
- BI model stability

---

# 🚀 Power BI Integration

The Gold layer is designed to:

- Be imported directly into Power BI
- Support a star-schema model
- Minimise DAX complexity
- Improve report performance
- Enable drill-down by date, store, product, promotion, channel

Recommended Power BI model:

01_dim_date
02_dim_store
03_dim_product
04_dim_category
05_dim_channel
06_dim_promotion
↓
07_fact_sales


Aggregate facts can be used for:

- Executive dashboards
- CFO reporting
- Performance monitoring
- Commercial analysis

---

# 🏗 Development Pattern

Each Gold table is built using:

DROP TABLE IF EXISTS
CREATE TABLE
INSERT INTO ... SELECT FROM Silver
CREATE INDEX


This ensures:

- Idempotent scripts
- Safe reruns
- Clean deployments

---

# 📁 Folder Structure

04_Gold_Layer/
├── 01_dim_date_gold.sql
├── 02_dim_store_gold.sql
├── 03_dim_product_gold.sql
├── 04_dim_category_gold.sql
├── 05_dim_channel_gold.sql
├── 06_dim_promotion_gold.sql
├── 07_fact_sales_gold.sql
├── fact_orders_gold.sql
├── fact_store_daily_pnl_gold.sql
├── fact_channel_performance_gold.sql
├── fact_product_profitability_gold.sql
├── fact_promo_profitability_gold.sql
├── fact_inventory_waste_gold.sql
├── fact_labour_daily_gold.sql
└── README.md


---

# 🎯 Why This Layer Matters

The Gold layer demonstrates:

- Advanced SQL transformation logic
- Business KPI modelling
- Performance optimisation
- Dimensional modelling expertise
- Production-style deployment scripts

This layer is **ready for executive analytics and BI consumption.**

---

# 👤 Author

Paul Mampilly  
Power BI Developer | Data Analyst | Analytics Engineer  
PL-300 Certified  

