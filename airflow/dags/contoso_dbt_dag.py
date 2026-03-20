from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator  # ✅

DBT_DIR = "/opt/airflow/dbt"
DBT_CMD = f"cd {DBT_DIR} && dbt"

default_args = {
    "owner": "moham",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
    "email_on_failure": False,
}

with DAG(
    dag_id="contoso_dbt_pipeline",
    default_args=default_args,
    description="Contoso Retail: S3 → Bronze → Silver → Gold via Snowflake + dbt",
    schedule="0 6 * * *",
    start_date=datetime(2026, 3, 1),
    catchup=False,
    tags=["contoso", "dbt", "snowflake"],
    template_searchpath="/opt/airflow/sql",
) as dag:

    bronze_ingest = SQLExecuteQueryOperator(   
        task_id="bronze_ingest",
        conn_id="snowflake_contoso",
        sql="bronze_ingest.sql",
    )
    
    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"{DBT_CMD} deps",
    )

    dbt_seed = BashOperator(
        task_id="dbt_seed",
        bash_command=f"{DBT_CMD} seed",
    )

    dbt_run_silver = BashOperator(
        task_id="dbt_run_silver",
        bash_command=f"{DBT_CMD} run --select silver",
    )

    dbt_run_gold = BashOperator(
        task_id="dbt_run_gold",
        bash_command=f"{DBT_CMD} run --select gold --full-refresh",
    )

    dbt_snapshot = BashOperator(
        task_id="dbt_snapshot",
        bash_command=f"{DBT_CMD} snapshot",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"{DBT_CMD} test",
    )

    dbt_docs = BashOperator(
        task_id="dbt_docs_generate",
        bash_command=f"{DBT_CMD} docs generate",
    )

    # Pipeline order
    bronze_ingest >>dbt_deps >> dbt_seed >> dbt_run_silver >> dbt_run_gold >> dbt_snapshot >> dbt_test >> dbt_docs
