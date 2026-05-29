# Food Delivery Analytics Warehouse

End-to-end food delivery analytics built on Microsoft Fabric. Covers the full stack — raw data ingestion, warehouse modelling, SQL analysis, and business dashboards — on 197,430 real-pattern orders worth ₹53M across 10 Indian cities.

---

## The problem

Food delivery platforms collect millions of order records and do nothing with them. Analysts get handed flat CSVs and asked why revenue dipped in June. This project builds the infrastructure to actually answer that — a proper warehouse, a clean data model, and SQL that thinks in business terms.

---

## What I built

**Data pipeline** — 5 parallel Copy Data activities in Microsoft Fabric moving raw CSVs into a Lakehouse, then into a structured Data Warehouse. No manual steps.

**Star schema** — `fact_orders` at the centre, joined to `dim_date`, `dim_location`, `dim_restaurant`, and `dim_dish`. Designed for query performance and BI compatibility.

**SQL analytics layer** — 10+ queries using window functions, CTEs, and segmentation logic to answer specific business questions. Not SELECT *, actual analysis.

**Two Power BI dashboards** — Executive Summary for leadership, Business Operations for the ops team. Both filterable by month, city, food type, and rating.

---

## What the data says

**Bengaluru is a single point of failure.** 20,100 orders — nearly double every other city. Saturday peaks hit 29K. One bad weekend in Karnataka wipes 10% of monthly revenue.

**Revenue looks healthy. Concentration doesn't.** ₹53M total, but top 5 states drive 45% of it. Karnataka alone contributes ₹5.5M. The platform isn't diversified — it's dependent.

**Non-veg is the business.** 63.7% of revenue comes from non-veg orders. In a country with 300M+ vegetarians, that's a product gap, not just a preference signal.

**Premium orders are underserved.** Orders above ₹500 punch above their weight in revenue contribution. No loyalty mechanics, no retention strategy, no upsell path. Money left on the table.

**Ratings are useless.** 4.0 to 4.5, clustered, low variance. The feedback system is broken — can't tell a good restaurant from a bad one. Every insight built on ratings is noise.

---

## SQL highlights

All queries in [`sql/SQL_Query.sql`](./sql/SQL_Query.sql)

- Month-over-month revenue growth using `LAG()`
- Order value segmentation — budget / mid / premium with revenue share per tier
- Restaurant density vs revenue by state — finding supply gaps
- Price vs rating correlation using CTEs
- City-level revenue ranking with `RANK() OVER`
- Top restaurant contribution as % of total using `SUM() OVER()`

---

## Dashboards

![Executive Summary](./dashboard/excecutive.png)
![Business Operations](./dashboard/business.png)

Power BI template: [dashboard/Dashboard.pbit](./dashboard/Dashboard.pbit)

---

## Stack

- **Microsoft Fabric** — Lakehouse, Data Warehouse, Data Pipelines
- **T-SQL** — window functions, CTEs, aggregations
- **Power BI** — KPI cards, slicers, trend charts
- **Python** — EDA, data profiling, synthetic data simulation

---

## Repo structure

```
├── charts/              chart exports
├── dashboard/           Power BI template, PDF, screenshots
├── data/raw/            source datasets
├── notebooks/           EDA.ipynb
├── sql/                 SQL_Query.sql
└── warehouse/           data model screenshots
```

---

## What's next

- Demand forecasting on daily order volume
- Customer RFM segmentation to find high-LTV cohorts
- Real-time pipeline for live operational monitoring

---

Seema Kumari — [LinkedIn](https://www.linkedin.com/in/seema-kumari-375763308/) · [GitHub](https://github.com/seema-kri)
