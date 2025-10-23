# gold-sales-adv-sql-analytics

A small analytics project with SQL queries and views built on a simple gold sales dataset. The repository contains sample datasets (JSON) and a consolidated SQL script with queries for time-series analysis, performance benchmarking, segmentation, and customer reporting.

## Contents

- `gold-sales-sql-analytics_final.sql` — Main SQL script with schema operations, analytic queries and the `gold_report_customers` view.
- `Datasets/` — JSON files used by the project:
  - `gold_customers.json`
  - `gold_products.json`
  - `gold_sales.json`

## Requirements

- MySQL 8.x or MariaDB (queries use MySQL-compatible functions like `YEAR()`, `DATE_FORMAT()` and `TIMESTAMPDIFF`).
- Python 3.8+ (optional, recommended for loading JSON files into the database)
- pip packages (if using Python): `pandas`, `sqlalchemy`, `pymysql`

Install the Python packages:

```bash
python -m pip install pandas sqlalchemy pymysql
```

## Quick setup (recommended)

1. Start your MySQL server and create a user with privileges to create databases/tables.
2. Create the `Gold` database and run the main SQL file after loading data (the script contains DDL/analytics queries):

- Option A — Load JSON into MySQL using a short Python helper (recommended):

```bash
# from the repository root
python - <<'PY'
import pandas as pd
from sqlalchemy import create_engine

# Update this connection string with your MySQL user/password/host/port
engine = create_engine('mysql+pymysql://<user>:<password>@localhost:3306/Gold')

for path in ['Datasets/gold_customers.json','Datasets/gold_products.json','Datasets/gold_sales.json']:
    df = pd.read_json(path)
    table = path.split('/')[-1].replace('.json','')
    df.to_sql(table, engine, if_exists='replace', index=False)
print('Data loaded')
PY
```

Then run the SQL script (it creates/uses the `Gold` database and runs the queries):

```bash
mysql -u <user> -p < gold-sales-sql-analytics_final.sql
```

- Option B — Manually import JSON via a tool or convert to CSV and use `LOAD DATA LOCAL INFILE`.

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

## Notes

- The SQL uses MySQL-compatible date/time functions. If you run on another engine, adapt functions accordingly.
- The Python loader assumes the JSON files map directly to table columns. Adjust column names and types if necessary.
