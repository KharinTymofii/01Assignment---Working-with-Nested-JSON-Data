from datetime import datetime, timedelta
import json
import os
import duckdb
from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator
from airflow.providers.mysql.hooks.mysql import MySqlHook
from airflow.models import Variable



default_args = {
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}

def detect_new_calls(ti):
    hook = MySqlHook(mysql_conn_id="support_mysql")

    last_loaded_call_time = Variable.get(
        "support_call_pipeline_last_loaded_call_time",
        default_var="2001-09-11 00:00:00",
    )

    query = """
        SELECT call_id, employee_id, call_time, phone, direction, status
        FROM calls
        WHERE call_time > %s
        ORDER BY call_time;
    """

    rows = hook.get_records(query, parameters=(last_loaded_call_time,))
    print(f"found {len(rows)} new calls")

    ti.xcom_push(key="new_calls", value=rows)


def load_telephony_details(ti):
    new_calls = ti.xcom_pull(task_ids="detect_new_calls", key="new_calls")

    telephony_records = []
    skipped_json = 0
    base_path = "/usr/local/airflow/include/telephony_json"

    for row in new_calls:
        call_id = row[0]
        file_path = os.path.join(base_path, f"call_{call_id}.json")

        if not os.path.exists(file_path):
            print(f"missing JSON for call_id={call_id}")
            continue

        with open(file_path, "r") as f:
            payload = json.load(f)

        required_fields = ["call_id", "duration_sec", "short_description"]
        if not all(field in payload for field in required_fields):
            print(f"invalid JSON schema for call_id={call_id}")
            skipped_json += 1
            continue

        if payload["duration_sec"] < 0:
            print(f"invalid duration for call_id={call_id}")
            skipped_json += 1
            continue


        telephony_records.append(payload)

    print(f"loaded {len(telephony_records)} telephony records")
    print(f"skipped {skipped_json} invalid or missing JSON files")


    ti.xcom_push(key="telephony_records", value=telephony_records)


def transform_and_load_duckdb(ti):
    new_calls = ti.xcom_pull(task_ids="detect_new_calls", key="new_calls")
    telephony_records = ti.xcom_pull(task_ids="load_telephony_details", key="telephony_records")

    hook = MySqlHook(mysql_conn_id="support_mysql")
    employees = hook.get_records(
        "SELECT employee_id, full_name, team, role, hire_date FROM employees"
    )

    employees_by_id = {row[0]: row for row in employees}
    telephony_by_call_id = {item["call_id"]: item for item in telephony_records}

    enriched_rows = []
    max_call_time = None
    skipped_json = 0

    seen_call_ids = set()

    



    for call_id, employee_id, call_time, phone, direction, status in new_calls:
        if call_id in seen_call_ids:
            skipped_rows += 1
            print(f"duplicate call_id detected: {call_id}")
            continue

        seen_call_ids.add(call_id)

        employee = employees_by_id.get(employee_id)
        telephony = telephony_by_call_id.get(call_id)

        if not employee or not telephony:
            skipped_json += 1
            continue

        enriched_rows.append((
            call_id,
            employee_id,
            employee[1],
            employee[2],
            employee[3],
            str(employee[4]),
            str(call_time),
            phone,
            direction,
            status,
            telephony["duration_sec"],
            telephony["short_description"],
        ))

        if max_call_time is None or call_time > max_call_time:
            max_call_time = call_time

    conn = duckdb.connect("/usr/local/airflow/data/support_calls.duckdb")

    conn.execute("""
        CREATE TABLE IF NOT EXISTS support_call (
            call_id INTEGER PRIMARY KEY,
            employee_id INTEGER,
            full_name VARCHAR,
            team VARCHAR,
            role VARCHAR,
            hire_date DATE,
            call_time TIMESTAMP,
            phone VARCHAR,
            direction VARCHAR,
            status VARCHAR,
            duration_sec INTEGER,
            short_description VARCHAR
        )
    """)

    if enriched_rows:
        conn.executemany("""
            INSERT OR REPLACE INTO support_call
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, enriched_rows)

    conn.close()

    print(f"loaded {len(telephony_records)} telephony records")
    print(f"skipped {skipped_json} invalid or missing JSON files")


    if max_call_time is not None:
        Variable.set("support_call_pipeline_last_loaded_call_time", str(max_call_time))



dag = DAG(
    dag_id="support_call_enrichment",
    start_date=datetime(2026, 3, 15),
    schedule="@hourly",
    catchup=False,
    default_args=default_args
)


task1 = PythonOperator(
    task_id="detect_new_calls",
    python_callable=detect_new_calls,
    dag=dag,
)

task2 = PythonOperator(
    task_id="load_telephony_details",
    python_callable=load_telephony_details,
    dag=dag,
)

task3 = PythonOperator(
    task_id="transform_and_load_duckdb",
    python_callable=transform_and_load_duckdb,
    dag=dag,
)

task1.set_downstream(task2)
task2.set_downstream(task3)
