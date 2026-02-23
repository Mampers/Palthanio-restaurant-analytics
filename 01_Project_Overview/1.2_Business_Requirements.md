# Business Requirements

## 1. Project Objective

The objective of this project is to design and implement a scalable Business Intelligence solution that enables financial and operational visibility across multiple restaurant locations.

The solution must transform raw operational data into governed, reliable, and performance-optimised reporting assets to support strategic and operational decision-making.

---

## 2. Business Context

Palthanio Restaurant operates multiple sites and generates daily transactional, labour, and cost data.

Management currently lacks:
- Centralised visibility of financial performance
- Consistent KPI definitions
- Clear understanding of labour cost impact
- Store-level performance benchmarking
- Insight into product-level profitability

The BI solution must address these gaps.

---

## 3. Key Business Questions

### Financial Performance
- What is total revenue by store, day, and month?
- What is Gross Profit?
- What is Profit After Labour?
- What is Labour % of Revenue?
- What is cost of waste and its impact on margin?

### Operational Performance
- Which stores are underperforming?
- Which products generate the highest margin?
- What is Average Order Value (AOV)?
- What are peak sales periods?

### Executive Insight
- Which locations require intervention?
- Where can labour costs be optimised?
- Which revenue streams are driving profitability?

---

## 4. Success Criteria

The solution will be considered successful if:

- All KPIs are documented and consistently defined
- Data reconciles with source totals
- The data warehouse follows Bronze/Silver/Gold architecture
- Power BI dashboards load in under 5 seconds
- Stakeholders can independently analyse performance

---

## 5. Assumptions & Constraints

### Assumptions
- Source data is provided via structured CSV extracts
- Historical data is complete and accurate
- Daily batch refresh is sufficient

### Constraints
- No real-time streaming required
- No predictive modelling included
- No external API integrations

---

## 6. High-Level Solution Architecture

Data Source (CSV)
→ Bronze Layer (Raw Load)
→ Silver Layer (Cleaned & Transformed)
→ Gold Layer (Star Schema)
→ Power BI Semantic Model
→ Executive & Operational Dashboards
