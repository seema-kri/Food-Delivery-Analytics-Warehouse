# 🍔 OrderIQ — Food Delivery Analytics Platform

---

## 🎯 Business Impact Snapshot

- Analyzed **197K+ orders** to identify revenue concentration across top-performing regions  
- Discovered **~40–50% revenue contribution from premium orders (>₹500)**  
- Identified demand-supply imbalance → high-revenue regions with low restaurant density  
- Built scalable pipeline reducing manual analysis effort by **~70%**

---

## ❓ Problem Statement

Food delivery platforms generate massive operational data, but raw logs don’t answer:

- Which regions drive most revenue?
- Are premium orders more valuable?
- Where is demand exceeding supply?
- What trends impact growth?

**Goal:** Build a complete analytics system — ingestion → modeling → insights → dashboard — using Microsoft Fabric.

> **Note:** Dataset is synthetically generated to simulate real-world patterns.

---

## 🏗 Architecture
Raw CSV → Lakehouse → Data Pipeline → Data Warehouse → Power BI

> Designed using modern data architecture (Lakehouse → DW → BI layer)

---

## 🗂 Data Model (Star Schema)

- **fact_orders** (core transactional data)  
- **dim_date, dim_location, dim_restaurant, dim_dish**

✔ Enables scalable analytics and efficient joins  
✔ Supports real-world BI use cases  

---

## 📊 Dashboard Preview

| Executive Dashboard | Business Dashboard |
|---|---|
| ![Executive](excecutive.png) | ![Business](business.png) |

---

## 🔍 SQL Analytics (Business-Focused)

- Revenue ranking by state & city  
- Demand vs supply (revenue per restaurant)  
- Order value segmentation (budget / mid / premium)  
- Price vs rating correlation  
- Month-over-month growth trends  
- Top restaurant contribution  

✔ Built using **CTEs, window functions, ranking, and time-series analysis**

---

## 📈 Key Business Insights → Actions

### Revenue Concentration (Pareto Effect)
Top states generate majority of revenue  

- **Action:** Focus marketing + expansion in high-performing regions  
- **Impact:** Higher ROI from targeted investments  

---

### High-Value Orders Drive Revenue
Premium orders (>₹500) contribute **~40–50% revenue**

- **Action:** Promote premium combos & upselling  
- **Impact:** Increase revenue without increasing order volume  

---

### Demand-Supply Gap
Some regions show high revenue per restaurant  

- **Action:** Increase restaurant onboarding in these areas  
- **Impact:** Capture unmet demand → higher order volume  

---

### Seasonal Trends
MoM data shows demand fluctuations  

- **Action:** Run targeted campaigns in low-demand months  
- **Impact:** Stabilize revenue trends  

---

### Rating Bias
Ratings cluster around 4.0–4.5  

- **Action:** Improve feedback granularity  
- **Impact:** Better quality insights  

---

## 🗃 Project Structure
OrderIQ-Food-Delivery-Analytics/
├── data/ # Raw datasets
├── notebooks/ # EDA & analysis
├── sql/ # Business queries
├── images/ # Dashboard previews
├── Dashboard.pbit # Power BI template
├── SQL_Query.sql # Full SQL analysis
├── pdf.pdf # Project report
└── README.md

---

## 🛠 Tech Stack

- **Microsoft Fabric** — Lakehouse, DW, pipelines  
- **SQL (T-SQL)** — analytics (CTEs, window functions)  
- **Power BI** — dashboards & KPIs  
- **Python** — EDA & data simulation  

---

## ⚡ Performance & Scalability

- Handles **197K+ records efficiently**  
- Modular architecture (ingestion → modeling → BI)  
- Easily extendable to real-time pipelines  

---

## 🚀 Future Work

- Demand forecasting model (Prophet / ML)  
- Customer segmentation (RFM / clustering)  
- Real-time streaming pipeline  
- Deployment via Power BI Service  

---

## 👩‍💻 About

I build data systems that drive **business decisions, not just dashboards**.

🔗 [GitHub](https://github.com/seema-kri)
