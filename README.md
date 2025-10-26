# gold-sales-adv-sql-analytics

A small analytics project with SQL queries and views built on a simple gold sales dataset. The repository contains sample datasets (JSON) and a consolidated SQL script with queries for time-series analysis, performance benchmarking, segmentation, and customer reporting.

## Contents

- `gold-sales-sql-analytics_final.sql` — Main SQL script with schema operations, analytic queries and the `gold_report_customers` view.
- `Datasets/` — JSON files used by the project:
  - `gold_customers.json`
  - `gold_products.json`
  - `gold_sales.json`


## Main analyses included

The SQL script contains useful analytics examples and a reusable customer view:

- Basic data inspection: `SELECT *` from dimension tables and the facts table.
- Time-series aggregations: yearly and monthly sales, customers count and quantities.
- Cumulative and moving averages: running totals and moving average price over time.
- Product performance: compare yearly product sales to product averages and previous year (using window functions and `LAG`).
- Category contribution: share of total sales by product category (part-to-whole analysis).
- Product segmentation: bucket products into cost ranges and count per segment.
- Customer segmentation: classify customers into `VIP`, `Regular`, and `New` based on lifespan and spending.
- `gold_report_customers` view: prebuilt customer-level report with recency, frequency, monetary metrics, age groups, segments, and average order/monthly spend.


<img width="1414" height="2000" alt="7" src="https://github.com/user-attachments/assets/3d9c1e34-8ba8-478c-9d82-81bf24500c25" />

<img width="1414" height="2000" alt="8" src="https://github.com/user-attachments/assets/c093a8c0-c9e6-4ccc-9fff-3aeb0fb9fc34" />
