# KPI Definitions

This document defines the standardised KPIs used across the BI solution.

All metrics are calculated from the Gold layer of the data warehouse to ensure consistency and governance.

---

# 1. Total Revenue

## Definition
Total net revenue generated from completed transactions.

## Calculation
SUM(gold.fact_store_daily_pnl.NetRevenue)

## Grain
Store, Date

---

# 2. Cost of Goods Sold (COGS)

## Definition
Total direct product cost associated with revenue.

## Calculation
SUM(gold.fact_store_daily_pnl.CostOfGoods)

---

# 3. Gross Profit

## Definition
Revenue after deducting Cost of Goods Sold.

## Calculation
Gross Profit = Net Revenue – Cost of Goods Sold

---

# 4. Total Labour Cost

## Definition
Total labour expense incurred per store per day.

## Calculation
SUM(gold.fact_labour_daily.TotalLabourCost)

---

# 5. Profit After Labour

## Definition
Operational profitability after accounting for labour costs.

## Calculation
Profit After Labour = Gross Profit – Total Labour Cost

---

# 6. Labour % of Revenue

## Definition
Proportion of revenue consumed by labour costs.

## Calculation
Labour % = Total Labour Cost / Net Revenue

---

# 7. Average Order Value (AOV)

## Definition
Average revenue generated per order.

## Calculation
AOV = Net Revenue / Total Orders

---

# 8. Waste Cost %

## Definition
Proportion of revenue lost due to waste.

## Calculation
Waste % = Waste Cost / Net Revenue

