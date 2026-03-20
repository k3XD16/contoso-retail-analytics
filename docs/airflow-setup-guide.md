# 🚀 Quick Setup: Airflow + dbt (Contoso Retail)

This guide will walk you through setting up Apache Airflow to orchestrate dbt (data build tool) workflows for a sample retail dataset. By the end of this guide, you'll have a working Airflow instance that can run dbt models on a schedule.

## 📋 1. Prerequisites

- 🐳 Docker & Docker Compose installed and running.

- 🐙 Git installed.

- ❄️ Snowflake Credentials ready (Account, User, Password, Role, WH, DB).

## 🛠️ 2. Installation & Setup

Clone the Repository:

```bash
git clone https://github.com/k3XD16/contoso-retail-analytics.git
cd contoso-retail-analytics/airflow
```

Create the .env File:
(⚠️ Security: Never commit this to Git)

```bash
# Airflow - Windows 11 Setup
AIRFLOW_UID=50000
AIRFLOW_IMAGE_NAME=apache/airflow:3.1.7
AIRFLOW_PROJ_DIR=.

# Admin UI credentials (change in production)
_AIRFLOW_WWW_USER_USERNAME=username
_AIRFLOW_WWW_USER_PASSWORD=passwrd

# dbt packages installed inside Airflow container
_PIP_ADDITIONAL_REQUIREMENTS=dbt-core dbt-snowflake apache-airflow-providers-snowflake apache-airflow-providers-common-sql

```

Boot Up Services:

```bash
docker compose up -d
```

## ▶️ 3. Running the Pipeline

- 🌐 Open your browser to `http://localhost:8080`

- 🔐 Log in with Username: `username` | Password: `passwrd`

- 🔍 Locate the `contoso_dbt_pipeline` DAG.

- 🚀 Click the Trigger DAG (▶️) button to start the run.


## 🐛 4. Essential Commands & Debugging

✅ Check running containers:

```bash
docker ps
```

🔌 Test Snowflake connection:

```bash
docker exec -it airflow-airflow-worker-1 bash -c "cd /opt/airflow/dbt && dbt debug"
```

📜 View real-time scheduler logs:

```bash
docker logs -f airflow-airflow-scheduler-1
```

🧹 Complete teardown & cleanup (removes data):

```bash
docker compose down -v
```