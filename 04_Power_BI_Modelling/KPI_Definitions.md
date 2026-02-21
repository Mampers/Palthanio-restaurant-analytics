# KPI Definitions

This document defines the key metrics used within the Palthanio Restaurant Analytics dashboard.

---

## Revenue & Volume Metrics

### Total Net Revenue
Total sales revenue after discounts.

**Purpose:** Measures top-line performance.

---

### Total Orders
Total number of customer transactions.

**Purpose:** Tracks sales volume and demand.

---

### Average Order Value (AOV)
Net Revenue / Total Orders

**Purpose:** Measures average customer spend per transaction.

---

### Avg Basket Size
Units Sold / Total Orders

**Purpose:** Identifies purchasing behaviour and cross-sell effectiveness.

---

## Profitability Metrics

### Gross Profit
Net Revenue − COGS

**Purpose:** Core product profitability before operational costs.

---

### Gross Margin %
Gross Profit / Net Revenue

**Purpose:** Indicates profitability efficiency.

---

### Net Profit
Revenue minus all applicable costs (COGS, Labour, Waste depending on calculation logic).

**Purpose:** Measures bottom-line profitability.

---

### Profit After Labour
Gross Profit − Labour Cost

**Purpose:** Measures operational profitability after staffing expenses.

---

### Profit After Labour and COGS
Net Revenue − COGS − Labour Cost

**Purpose:** Store-level operational health indicator.

---

## Cost & Efficiency Metrics

### Total COGS
Total cost of goods sold.

**Purpose:** Measures direct product cost.

---

### Total Labour Cost
Total staffing expenses.

**Purpose:** Major controllable operational cost.

---

### Labour Cost %
Labour Cost / Net Revenue

**Purpose:** Indicates staffing efficiency.

---

### Total Waste Cost
Total cost of wasted inventory.

**Purpose:** Highlights operational inefficiencies.

---

### Waste Cost %
Waste Cost / Net Revenue

**Purpose:** Measures revenue lost to waste.

---

### Total Cost (Labour + Waste)
Labour Cost + Waste Cost

**Purpose:** Combined operational cost impact.

---

### Total Cost %
(Labour Cost + Waste Cost) / Net Revenue

**Purpose:** Benchmark operational cost efficiency.

---

## Promotion & Discount Metrics

### Total Discount Given
Total value of discounts applied.

**Purpose:** Measures promotional spend intensity.

---

### Discount Rate %
Total Discount Given / Gross Revenue

**Purpose:** Tracks discount dependency.

---

### Promo Units Sold
Units sold under promotion.

**Purpose:** Measures promotional sales volume.

---

### Total Promo Revenue
Revenue attributed to promotional sales.

**Purpose:** Evaluates sales uplift from promotions.

---

### Total Promo Profit
Profit generated from promotional sales.

**Purpose:** Assesses promotion profitability.

---

### Total Promo Profit Margin %
Total Promo Profit / Total Promo Revenue

**Purpose:** Measures promotion efficiency.

---

### Profit per Discount (£)
Total Profit / Total Discount Given

**Purpose:** Indicates return on discount investment.

---

## Product Performance Metrics

### Product Margin %
Product-Level Profit / Product-Level Revenue

**Purpose:** Identifies high and low margin products.

---

### Top 5 Product Revenue Share %
Revenue from Top 5 Products / Total Revenue

**Purpose:** Measures product concentration risk.

---

### Top Profit Product (Name)
Product with highest profit in current filter context.

**Purpose:** Identifies best-performing product.

---

### Lowest Margin Product (Name)
Product with lowest margin in current filter context.

**Purpose:** Flags underperforming products for review.

---

## Channel Performance Metrics

### Total Units Sold (Channel)
Total units sold by channel (e.g., In-store vs Delivery).

**Purpose:** Enables channel mix analysis.

---

## Notes

- All percentage KPIs use DIVIDE() to prevent divide-by-zero errors.
- Business logic is centralised within Derived measures to ensure consistency.
- Presentation measures are separated from core KPIs to maintain semantic integrity.
