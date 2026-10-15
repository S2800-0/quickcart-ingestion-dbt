#!/usr/bin/env bash
# Starts a local PostgreSQL, creates the source and warehouse databases and loads the CSVs.
set -euo pipefail
cd "$(dirname "$0")"
docker rm -f quickcart-pg >/dev/null 2>&1 || true
docker run -d --name quickcart-pg -p 5440:5432 \
  -e POSTGRES_USER=quickcart -e POSTGRES_PASSWORD=quickcart_demo \
  postgres:16-alpine -c wal_level=logical >/dev/null
until docker exec quickcart-pg pg_isready -U quickcart >/dev/null 2>&1; do sleep 1; done
sleep 2
docker exec quickcart-pg psql -U quickcart -d postgres -qc "CREATE DATABASE quickcart_source;" -c "CREATE DATABASE quickcart_warehouse;"
docker exec -i quickcart-pg psql -U quickcart -d quickcart_source -q < sql/01_source_schema.sql
for t in stores employees customers products orders order_items; do
  docker exec -i quickcart-pg psql -U quickcart -d quickcart_source -qc "\copy public.$t FROM STDIN WITH (FORMAT csv, HEADER true)" < "data/$t.csv"
done
docker exec quickcart-pg psql -U quickcart -d quickcart_source -c \
 "SELECT 'stores' t, count(*) FROM stores UNION ALL SELECT 'employees',count(*) FROM employees UNION ALL SELECT 'customers',count(*) FROM customers UNION ALL SELECT 'products',count(*) FROM products UNION ALL SELECT 'orders',count(*) FROM orders UNION ALL SELECT 'order_items',count(*) FROM order_items UNION ALL SELECT 'student_orders',count(*) FROM student_orders;"
