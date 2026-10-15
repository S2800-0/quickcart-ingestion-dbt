#!/usr/bin/env bash
# One full run: extract and load with Airbyte, then transform and test with dbt.
set -euo pipefail
cd "$(dirname "$0")"
export DBT_PROFILES_DIR="$PWD/dbt"
echo "== 1. Airbyte sync: source -> warehouse (raw)"
python3 airbyte/sync.py
echo; echo "== 2. dbt build: staging, marts and tests"
cd dbt
../.venv/bin/dbt build --no-print 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep -E "Finished running|Completed|Done\.|ERROR|FAIL"
echo; echo "== 3. dbt source freshness"
../.venv/bin/dbt source freshness 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep -E "freshness of|Done\."
