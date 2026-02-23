# 📁 2️⃣ Performance_Strategy.md  
**Location:**  
`04_Power_BI_Modelling/Performance_Strategy.md`

---

```markdown
# Performance Strategy – Palthanio Restaurant Analytics

---

# 1. Dimensional Model Optimisation

- Star schema enforced
- Conformed dimensions across facts
- No fact-to-fact joins
- Single-direction filtering only

This ensures predictable filter propagation and stable query plans.

---

# 2. Cardinality Management

- Integer surrogate keys used for joins
- Avoided GUIDs or text-based relationships
- Limited high-cardinality columns in fact tables
- Transaction references not used in relationships

---

# 3. DAX Performance Design

- Base measures reused across derived calculations
- Avoided unnecessary iterators (SUMX where SUM sufficient)
- Variables used in complex measures
- No calculated columns where measures suffice

---

# 4. Filter Context Control

- No bi-directional relationships
- No ambiguous filter paths
- Context transition explicitly handled in CALCULATE

---

# 5. Scaling Strategy

If scaled to enterprise volumes:

- Incremental refresh implemented
- Partitioning strategy applied to large fact tables
- Aggregation tables introduced for summary reporting
- Migration to Microsoft Fabric Lakehouse recommended

---

# 6. Monitoring & Diagnostics

Tools used for performance validation:

- Power BI Performance Analyzer
- DAX Studio
- VertiPaq Analyzer

---

# 7. Enterprise Considerations

Designed for:

- Predictable query performance
- Reduced memory footprint
- Scalable analytical workloads
- Maintainable DAX logic

---
