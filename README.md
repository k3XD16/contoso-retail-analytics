<div align="center">

<img width="1525" height="148" alt="image" src="https://github.com/user-attachments/assets/0b20f0e2-1d2e-4369-8210-3a73fbacbdc2" />


#### *End-to-end batch pipeline | dbt + Snowflake + AWS S3 + Apache Airflow | Medallion Architecture | 3.5M+ records*

![AWS S3](https://img.shields.io/badge/AWS_S3-Data_Lake-orange?style=for-the-badge&logo=amazon-aws&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-1.11.7-orange?style=for-the-badge&logo=getdbt&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-Cloud_DW-00BFFF?style=for-the-badge&logo=snowflake&logoColor=white)
![Apache Airflow](https://img.shields.io/badge/Apache_Airflow-Orchestration-brightgreen?style=for-the-badge&logo=apache-airflow&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED?style=for-the-badge&logo=docker&logoColor=white)

</div>

---

## Overview

An ELT pipeline implementing **Medallion Architecture (Bronze → Silver → Gold)** on the Microsoft Contoso dataset — a realistic multi-country retail dataset with intentional data quality issues, making it well-suited for building and testing production-style transformation patterns. The pipeline ingests raw CSVs from S3 into Snowflake, applies layered dbt transformations into a Kimball star schema, and is fully orchestrated with Apache Airflow running in Docker.

| Metric | Value |
|--------|-------|
| Records Processed | 3,537,806 |
| dbt Models | 15 (4 dims + 1 fact + 1 OBT + 7 staging + 2 intermediate) |
| Seeds | 2 (`seed_currency_lookup`, `seed_calendar`) |
| SCD Type 2 Snapshots | 3 (`snap_customers`, `snap_products`, `snap_stores`) |
| Data Quality Tests | 46 (41 generic + 5 singular) |
| Airflow Tasks | 8 |

---

## Architecture

```
AWS S3 (Raw CSVs)
    ↓  IAM Role + External Stage
Snowflake BRONZE  →  Raw ingestion via COPY INTO
    ↓  dbt
Snowflake SILVER  →  7 staging views + 2 ephemeral intermediate models
    ↓  dbt
Snowflake GOLD    →  Star Schema (4 dims + 1 fact) + One Big Table
    ↓
Apache Airflow DAG (Docker) — orchestrates all 8 tasks

    [Task 1] bronze_ingest      → Load raw CSVs from S3 into Snowflake BRONZE via IAM + External Stage
    [Task 2] dbt_deps           → Install dbt dependencies
    [Task 3] dbt_seed           → Load static seed data (currency lookup, calendar)
    [Task 4] dbt_run_silver     → BRONZE → SILVER (7 staging views + 2 ephemeral intermediate models)
    [Task 5] dbt_run_gold       → SILVER → GOLD (Star Schema + One Big Table)
    [Task 6] dbt_snapshot       → Run SCD Type 2 snapshots for customers, products, stores
    [Task 7] dbt_test           → Execute all 46 data quality tests
    [Task 8] dbt_docs_generate  → Auto-generate dbt lineage documentation
```

**Architecture Diagram**

![Architecture](/docs/screenshots/contoso_architecture_diagram.png)

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Storage | AWS S3 |
| Warehouse | Snowflake |
| Transformation | dbt Core 1.11.7 |
| Orchestration | Apache Airflow 3.1.7 |
| Containerization | Docker + Docker Compose |
| IAM | AWS IAM Roles |
| Language | SQL, Jinja, YAML, Python |

---

## Data Model (Gold Layer)

**Star Schema** — Kimball methodology

- **`fact_sales`** — 2,349,091 rows | grain: order line item | incremental load
- **`dim_customers`** — 104,990 rows | demographics, CLV, segmentation (A/B/C/D)
- **`dim_products`** — 2,517 rows | category hierarchy, cost & retail pricing
- **`dim_stores`** — 74 rows | 8 countries, open/closed/restructured status
- **`dim_date`** — 4,018 rows | calendar + fiscal attributes
- **`obt_sales`** — 2,349,091 rows | 50+ columns | same grain as `fact_sales`, denormalized with all dimension attributes for direct BI consumption (Power BI, Tableau, QuickSight)

check-out [`docs/data_dictionary.md`](./docs/data_dictionary.md) to know more about the data used here.

---

## Key Features

- **Incremental Loading** — `fact_sales` uses append-only strategy; no full-refresh on every run
- **SCD Type 2** — dbt snapshots track historical changes on customers, products, stores
- **Metadata-Driven Silver Layer** — new source tables onboarded via YAML config, zero SQL changes required
- **Reusable Macros** — `calculate_profit_margin`, `safe_divide`, `get_customer_segment`, `calculate_discount_pct`
- **46 Automated Tests** — generic (unique, not_null, relationships, accepted_values) + 5 custom singular tests
- **Full DAG Orchestration** — 8 tasks with retry logic, health checks, and task-level logging

### Raw Data — AWS S3

7 source CSVs staged in S3 (`contoso-dataset/source/`) — the pipeline entry point.
Snowflake reads directly from this bucket via IAM Role + External Stage, with no manual file movement.

![S3 Raw Data](/docs/screenshots/source_dataset_s3_bucket.png)



### dbt Lineage Graph

Full end-to-end lineage from Bronze tables through staging, intermediate, dimensions, facts, snapshots, and into `obt_sales`.
Every dependency is tracked and auto-documented by dbt — no black boxes in the transformation layer.

![dbt Lineage](/docs/screenshots/dbt_one_big_table_lineage_graph.png)

### Snowflake — Gold Layer Output

`obt_sales` materialised in Snowflake GOLD with 2,349,091 rows and over 50 columns, queryable directly by any BI tool.
The result of the full Bronze → Silver → Gold transformation chain, ready for consumption.

![Snowflake OBT](/docs/screenshots/snowflake_ui_obt_sales.png)

### DBT Test

46 automated tests validating uniqueness, nulls, referential integrity, and custom business rules across all Silver layer + Gold layer models. Executed as the final gate in the Airflow DAG before docs generation.

![dbt test](/docs/screenshots/test_results.png)

### Airflow DAG Schedule

```
bronze_ingest → dbt_deps → dbt_seed → dbt_run_silver → dbt_run_gold → dbt_snapshot → dbt_test → dbt_docs_generate
```

![Airflow DAG](/docs/screenshots/airflow_dag_schedule.png)

### Airflow DAG Run

![Airflow DAG Run](/docs/screenshots/airflow_dag_run.png)

---

## Design Decisions

- **Incremental over full-refresh on `fact_sales`**: With 2.3M+ rows, a full-refresh on every run is expensive and unnecessary. The append-only incremental strategy processes only new records, keeping run times under 3 minutes on subsequent executions.

- **Ephemeral models for intermediate layer**: `int_order_details` and `int_customer_metrics` are ephemeral — they exist only at query time and don't materialize in Snowflake. This avoids cluttering the warehouse with transitional tables that serve no direct analytical purpose.

- **Metadata-driven Silver layer**: Rather than writing a new staging SQL model for every source table, the Silver layer is driven by YAML config. Adding a new source is a config change, not a code change — easier to maintain and easier to onboard.

---

## Project Structure

```
contoso-retail-analytics/
├── airflow/
│   ├── docker-compose.yaml
│   ├── config/airflow.cfg
│   ├── sql/bronze_ingest.sql
│   ├── dags/contoso_dbt_dag.py
│   └── .env                            # Airflow environment variables (.gitignored)
│
├── contoso_retail/                     # dbt project
│   ├── models/
│   │   ├── sources.yml
│   │   ├── silver/
│   │   │   ├── staging/                # 7 stg_*.sql models
│   │   │   └── intermediate/           # int_order_details.sql, int_customer_metrics.sql
│   │   └── gold/
│   │       ├── dimensions/             # dim_customer.sql, dim_product.sql, dim_store.sql, dim_date.sql
│   │       ├── facts/                  # fact_sales.sql (incremental)
│   │       └── analytics/              # obt_sales.sql
│   ├── snapshots/                      # snap_customers.sql, snap_products.sql, snap_stores.sql
│   ├── macros/                         # 4 reusable Jinja macros
│   ├── seeds/                          # seed_currency_lookup.csv, seed_calendar.csv
│   ├── tests/                          # 5 singular SQL tests
│   ├── dbt_project.yml                 # dbt project complete setup
│   └── example_profiles.yml            # profiles.yml contains dbt to snowflake config
│
├── docs/
│   ├── screenshots/                    # Airflow DAGs, Architecture Diagram, dbt Lineage
│   ├── airflow-setup-guide.md          # Step-by-step Airflow setup instructions
│   ├── data_dictionary.md              # Detailed schema documentation for all tables
│   └── snowflake-setup-guide.md        # Snowflake account, warehouse, database, schema, IAM role setup
│
├── .gitignore
├── .python-version
├── LICENSE
├── pyproject.toml
├── README.md
├── requirements.txt
└── uv.lock
```

---

## Setup

**Prerequisites**: Docker Desktop, Snowflake account, AWS S3 bucket

```bash
# 1. Clone the repo
git clone https://github.com/k3XD16/contoso-retail-analytics.git
cd contoso-retail-analytics

# 2. Configure credentials
cp contoso_retail/profiles.yml.example contoso_retail/profiles.yml
# Edit profiles.yml with your Snowflake credentials
# Edit airflow/.env with your S3 + Snowflake env vars

# 3. Start Airflow
cd airflow
docker compose up -d

# 4. Trigger the pipeline
# UI: http://localhost:8080 → contoso_dbt_pipeline → Trigger DAG
```

> **First run**: ~5–7 min | **Subsequent runs**: ~2–3 min

Full setup guides available in [`docs/snowflake-setup-guide.md`](./docs/snowflake-setup-guide.md) and [`docs/airflow-setup-guide.md`](./docs/airflow-setup-guide.md).

---

## Known Limitations & Future Work

- **No streaming layer** — pipeline is batch-only; a streaming extension using Kafka + Spark Structured Streaming + Delta Lake is planned as a separate project
- **No CI/CD on dbt tests** — tests run inside the Airflow DAG but aren't gated in a CI pipeline (GitHub Actions integration is a planned improvement)
- **Local Airflow only** — currently runs on Docker locally; MWAA or Astronomer deployment would be the production path
- **Static seed data** — currency exchange rates and calendar are seeded as CSVs; a live API integration would be more realistic for production

---

## Resources

- [dbt Docs](https://docs.getdbt.com/) · [Snowflake Docs](https://docs.snowflake.com/) · [Airflow Docs](https://airflow.apache.org/)
- *The Data Warehouse Toolkit* — Ralph Kimball

---

<div align="center">

### ⭐ If you found this project helpful, please give it a star!

***Built with ❤️ by [Mohamed Khasim](https://x.com/k3XD16)***

![GitHub](https://img.shields.io/badge/GitHub-k3XD16-181717?style=flat-square&logo=github&logoColor=white)
![LinkedIn](https://img.shields.io/badge/LinkedIn-mohamedkhasim16-0077B5?style=flat-square&logo=linkedin&logoColor=white)
![Email](https://img.shields.io/badge/Email-mohamedkhasim.16%40gmail.com-D14836?style=flat-square&logo=gmail&logoColor=white)

</div>
