# OrderIQ — Food Delivery Analytics Platform

> End-to-end data engineering pipeline built on **Microsoft Fabric** · **197,430 simulated orders** · Star schema data warehouse · 10 analytical SQL modules · Interactive Power BI dashboard

---

## Why This Project Exists

Food delivery platforms generate enormous volumes of operational data every day — but raw transactional logs don't answer the questions that actually drive business decisions:

- Which states and cities generate disproportionate revenue?
- Do premium orders (₹500+) correlate with higher customer satisfaction?
- Where is restaurant supply failing to meet demand?
- What does month-over-month revenue trend reveal about seasonality?

This project builds the complete infrastructure to answer those questions — **raw data ingestion → SQL transformation → star schema modeling → Power BI dashboard** — using Microsoft Fabric as the unified analytics platform.

> **Data Note:** All data in this project is synthetically generated to simulate realistic food delivery operations. It reflects plausible business patterns — order volumes, price distributions, geographic spread, rating behavior — while containing no real customer or business information. This approach is standard practice for portfolio projects where production data access is restricted.

---

## 📊 Dashboard Preview


![Executive Dashboard](executive.png)
![Business Dashboard](business.png)

---

## Architecture

```
Raw CSVs
   │
   ▼
Lakehouse (swiggylw)          ← raw storage layer, OneLake
   │
   ▼  [Fabric Data Pipeline — 5 parallel Copy activities, ~43s total]
   │
   ▼
Data Warehouse (swiggy_dw)    ← SQL cleaning, star schema modeling
   │
   ▼
Power BI Semantic Model       ← relationships, KPI measures defined
   │
   ▼
Power BI Report               ← interactive dashboards for stakeholders
```

| Layer | Tool | Purpose |
|---|---|---|
| Raw Storage | Fabric Lakehouse | Holds source files before processing |
| Ingestion | Fabric Data Pipelines | Parallel copy from Lakehouse → DW |
| Modeling | Fabric Data Warehouse | Star schema + SQL analytics |
| Semantic Layer | Power BI Semantic Model | Relationships, measures, KPIs |
| Visualization | Power BI Report | Business-facing interactive dashboards |

---

## Data Model — Star Schema

```
     dim_date              dim_location
   ┌──────────┐           ┌──────────────┐
   │ date_id  │           │ location_id  │
   │ order_date│           │ city         │
   │ order_date│           │ state        │
   │  _new    │           │ location     │
   └────┬─────┘           └──────┬───────┘
        │  1                     │  1
        │                        │
        ▼  *                     ▼  *
   ┌─────────────────────────────────────┐
   │              fact_orders            │
   │  order_id · price · rating          │
   │  rating_count · date_id             │
   │  location_id · restaurant_id        │
   │  food_id                            │
   └──────────────┬──────────────────────┘
                  │  *         *  │
        ┌─────────┘               └──────────┐
        ▼  1                              1  ▼
   ┌──────────┐                    ┌──────────────┐
   │ dim_dish │                    │dim_restaurant│
   │ dish_id  │                    │restaurant_id │
   │ dish_name│                    │restaurant    │
   │ category │                    │  _name       │
   └──────────┘                    └──────────────┘
```

**Data quality fix applied:** Source `order_date` field used European format (DD-MM-YYYY). Added `order_date_new` column via `TRY_CONVERT(date, order_date, 5)` and validated for NULLs before downstream use — a common real-world ingestion issue.

---

## SQL Analytics — 10 Business Questions

Every query was written around a decision a business stakeholder would actually need to make — not just to demonstrate SQL syntax.

### Revenue & Geography

**State-level revenue ranking**
```sql
SELECT dl.state,
       COUNT(fo.order_id)                                  AS total_orders,
       ROUND(SUM(fo.price), 0)                             AS total_revenue,
       ROUND(AVG(fo.price), 0)                             AS avg_order_value,
       COUNT(DISTINCT fo.restaurant_id)                    AS num_restaurants,
       RANK() OVER (ORDER BY SUM(fo.price) DESC)           AS revenue_rank
FROM swiggy_project.fact_orders fo
JOIN swiggy_project.dim_location dl ON fo.location_id = dl.location_id
GROUP BY dl.state
ORDER BY total_revenue DESC
```
*Business decision:* Where to concentrate marketing spend and restaurant acquisition.

**City-level breakdown (Top 15)**
Cross-dimension analysis at state + city granularity with `RANK()` window function — identifies cities driving outsized value within each state.

**Restaurant density vs. demand**
Computes `revenue_per_restaurant` and `orders_per_restaurant` per state — surfaces states where demand outpaces supply (expansion opportunity) vs. oversaturated markets.

---

### Customer & Order Behavior

**Order value segmentation**
```sql
SELECT CASE
         WHEN price < 200               THEN 'Budget (<₹200)'
         WHEN price BETWEEN 200 AND 500 THEN 'Mid (₹200-500)'
         WHEN price > 500               THEN 'Premium (>₹500)'
       END                                                          AS order_segment,
       COUNT(order_id)                                              AS total_orders,
       ROUND(COUNT(order_id) * 100.0 / SUM(COUNT(order_id)) OVER(), 1) AS order_share_pct,
       ROUND(SUM(price)      * 100.0 / SUM(SUM(price))      OVER(), 1) AS revenue_share_pct
FROM swiggy_project.fact_orders
WHERE price BETWEEN 10 AND 3000
GROUP BY CASE ... END
```
*Business decision:* Are budget orders subsidized by premium revenue? Should pricing strategy shift?

**Price vs. rating correlation**
4-tier price segmentation (Budget / Mid / Premium / Luxury) with avg rating, avg review count, and % orders that received a review per tier. Tests whether spend correlates with satisfaction — a key assumption in premium product strategy.

**Rating distribution**
Frequency analysis of all rating values with percentage of total. Detects rating clustering, scale compression, or submission bias.

---

### Growth & Trends

**Month-over-month revenue growth**
```sql
ROUND(
  (SUM(fo.price) - LAG(SUM(fo.price)) OVER (ORDER BY MONTH(dd.order_date_new)))
  / LAG(SUM(fo.price)) OVER (ORDER BY MONTH(dd.order_date_new)) * 100, 1
) AS mom_growth_pct
```
*Business decision:* Which months show negative growth? Is it seasonal or structural?

**Top restaurants by revenue share**
Uses `SUM(...) OVER ()` to compute each restaurant's % contribution to total platform revenue — not just raw revenue, which is inflated by high-volume, low-AOV restaurants.

**Average order value by food category**
Filtered to categories with ≥100 orders (statistical significance floor), then ranked by AOV. Identifies which food categories drive value vs. volume.

---

## Data Pipeline — Fabric Orchestration

Pipeline: `Pipeline_lakehouse_to_dw`
Design: 5 **parallel** Copy Data activities (not sequential — total runtime ≈ slowest single activity)

| Activity | Runtime | Result |
|---|---|---|
| Copy data dim_date | 41s | Succeeded |
| Copy data dim_location | 40s | Succeeded |
| Copy data dim_dish | 41s | Succeeded |
| Copy data dim_restaurant | 40s | Succeeded |
| Copy data fact_orders | 43s | Succeeded |

**Total pipeline runtime: ~43s** — bounded by slowest activity, not sum of all five.

---

## Analytical Findings (Simulated Data)

These patterns emerged from the synthetic dataset and are consistent with what real food delivery data typically shows:

- **197,430 orders** across all states — sufficient volume for statistically stable segment analysis
- Revenue follows a **power-law distribution** across states — top states generate the majority of platform revenue
- **High-value orders (>₹500)** are a minority of order count but contribute disproportionately to revenue — classic 80/20 dynamic
- **Rating distribution is left-skewed** — clustering at 4.0–4.5 suggests either genuine quality or selection bias (dissatisfied users may not submit ratings)
- **Restaurant density analysis** reveals asymmetry — some states show high revenue-per-restaurant (demand exceeds supply) while others show saturation
- **MoM trend** shows identifiable seasonality — consistent with known food delivery patterns (post-festival slowdowns, regional summer dips)

---

## Limitations & What I'd Do With Real Data

| Limitation (Simulated) | Approach With Real Data |
|---|---|
| No customer IDs → no cohort analysis | Add dim_customer, build RFM (Recency/Frequency/Monetary) segments |
| No delivery time data → no speed-satisfaction analysis | Join delivery partner logs, correlate ETA variance with ratings |
| Full reload pipeline → not production-ready | Implement watermark-based incremental loads on fact_orders |
| No access governance | Add Power BI row-level security scoped by state/region |
| No forecasting layer | Feed MoM trend into Prophet or statsmodels for demand forecasting |
| No data quality monitoring | Add NULL checks, referential integrity tests, freshness assertions as pipeline steps |

This section matters because it demonstrates the gap between a portfolio project and a production system — and shows I understand exactly how to close it.

---

## Repository Structure

```
OrderIQ-Food-Delivery-Analytics/
├── data/
│   └── raw/                    # Simulated source CSV files
├── warehouse/                  # DW schema screenshots, data model diagrams
├── charts/                     # EDA output visualizations
├── EDA.ipynb                   # Exploratory data analysis (Python)
├── SQL_Query.sql               # All 10 analytical queries
├── Dashboard.pbit              # Power BI template (connect your own DW)
└── README.md
```

---

## Tech Stack

| Tool | Usage |
|---|---|
| Microsoft Fabric (Lakehouse + DW + Pipelines + Semantic Model) | Unified analytics platform |
| T-SQL | Data cleaning, star schema modeling, window function analytics |
| Power BI | Semantic model + interactive report |
| Python / Jupyter | EDA, data simulation, statistical profiling |
| Git / GitHub | Version control, documentation |

---

## Why Microsoft Fabric

Traditional analytics stacks require stitching together: object storage + ETL tool + data warehouse + BI layer + orchestrator — each with its own auth, monitoring, and billing.

Fabric consolidates all five into one governed workspace sharing a single **OneLake** storage layer. No data copies between layers. No connector maintenance. This project demonstrates a complete production-grade analytics pipeline running entirely within Fabric — raw ingestion to published report — which reflects how modern analytics teams are actually building today.

---

## If I Were to Scale This

1. **Incremental loads** — replace full Copy activities with watermark-based incremental ingestion
2. **Customer dimension** — add RFM cohort analysis for retention and churn modeling
3. **Delivery performance layer** — correlate delivery speed with ratings to identify operational improvement areas
4. **Forecasting** — feed MoM trend into Prophet or statsmodels for demand forecasting by region
5. **Row-level security** — scope Power BI access by geography for regional stakeholder self-service
6. **Data quality framework** — automated NULL checks, referential integrity tests, freshness monitoring as pipeline steps

---

*Built by **Seema** · [github.com/seema-kri/OrderIQ-Food-Delivery-Analytics](https://github.com/seema-kri/OrderIQ-Food-Delivery-Analytics)*
