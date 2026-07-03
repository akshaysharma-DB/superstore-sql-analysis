# Superstore Sales Analysis (SQL)

An end-to-end SQL analysis of ~9,800 orders from the Superstore Sales dataset, uncovering revenue drivers, loss-making segments, regional efficiency, and customer behavior patterns.

## Tools Used
- **MySQL** — data querying and analysis
- **Python (pandas, mysql-connector)** — data cleaning and import

## Dataset
[Superstore Sales Dataset](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final) — ~9,800 rows across Orders, Customers, Products, Sales, Profit, Region.

## What This Project Covers
24 business questions across three difficulty tiers:
- **Beginner** — aggregations, grouping, basic filtering
- **Intermediate** — joins, subqueries, HAVING clauses
- **Advanced** — window functions (`RANK`, `ROW_NUMBER`, `LAG`), CTEs, cohort analysis

Full queries with inline insights: [`superstore_analysis.sql`](superstore_analysis.sql)

## Key Findings

**Regional Performance**
- West region drives the highest revenue (₹7.25L) *and* the best profit margin (14.94%)
- Central has the 2nd-highest sales volume but the weakest margin (7.92%) — signaling over-discounting or high costs
- West + East together account for over 61% of total company sales

**Category Insights**
- Furniture generates almost as much revenue as Technology (₹7.42L vs ₹8.36L) but converts only **2.49%** into profit vs ~17% for Technology and Office Supplies
- Technology has the highest average profit per order (₹94.21) with the *lowest* average discount — strong pricing power
- Furniture and Office Supplies both discount more and earn less per order than Technology

**Seasonality**
- November and December are consistently the strongest months every year (holiday season)
- February is consistently the weakest month every year
- Business grew ~51% from 2015 to 2018, despite a brief dip in 2016

**Customers**
- 793 unique customers; average order value is ₹458.61
- A small group of top-5 customers drives disproportionately high revenue — strong candidates for loyalty programs
- Cohort analysis shows early customers remain active up to 4 years later, indicating meaningful long-term retention

**Products**
- Canon imageCLASS 2200 Advanced Copier is the single best-selling product (₹61,599.83) — over 2x the runner-up
- 539 products are profitable in one region but loss-making in another — pointing to a structural/regional issue rather than isolated bad products

## How to Run
1. Import the dataset into MySQL (see comments in the `.sql` file for schema)
2. Run queries in `superstore_analysis.sql` sequentially — each includes its business question and resulting insight as comments
