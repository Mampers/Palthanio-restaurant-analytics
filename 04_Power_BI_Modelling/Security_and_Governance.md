# Security & Governance – Palthanio Restaurant Analytics

---

# 1. Security Model Overview

The Palthanio Restaurant Analytics solution is designed with enterprise-grade governance and access control principles in mind.

Security is implemented at the semantic model level and supported by warehouse-level referential integrity.

---

# 2. Row-Level Security (RLS)

The model supports Row-Level Security based on:

- Store
- Region
- Business Function

RLS filters are applied to **dimension tables only**, allowing filter propagation to related fact tables.

## Example RLS Pattern

```DAX
Store[Region] = USERPRINCIPALNAME()
