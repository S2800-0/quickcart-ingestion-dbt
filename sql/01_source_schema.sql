-- Source database (stands in for the production PostgreSQL / Neon source)
CREATE TABLE IF NOT EXISTS public.stores (
  store_id INTEGER PRIMARY KEY, store_name TEXT, city TEXT, state TEXT, region TEXT, opening_date DATE);
CREATE TABLE IF NOT EXISTS public.employees (
  employee_id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, email TEXT, hire_date DATE,
  job_title TEXT, salary NUMERIC(10,2), store_id INTEGER, manager_id INTEGER);
CREATE TABLE IF NOT EXISTS public.customers (
  customer_id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, email TEXT, phone TEXT,
  city TEXT, state TEXT, registration_date DATE, loyalty_tier TEXT);
CREATE TABLE IF NOT EXISTS public.products (
  product_id INTEGER PRIMARY KEY, product_name TEXT, category TEXT, subcategory TEXT,
  unit_price NUMERIC(10,2), cost_price NUMERIC(10,2), supplier TEXT, stock_quantity INTEGER);
CREATE TABLE IF NOT EXISTS public.orders (
  order_id INTEGER PRIMARY KEY, order_date DATE, customer_id INTEGER, employee_id INTEGER,
  store_id INTEGER, status TEXT, shipping_fee NUMERIC(10,2));
CREATE TABLE IF NOT EXISTS public.order_items (
  order_item_id INTEGER PRIMARY KEY, order_id INTEGER, product_id INTEGER, quantity INTEGER,
  price_per_unit NUMERIC(10,2));
-- The demo table from the lab manuals
CREATE TABLE IF NOT EXISTS public.student_orders (
  order_id INTEGER PRIMARY KEY, customer_name TEXT NOT NULL, product TEXT NOT NULL,
  order_amount NUMERIC(10,2) NOT NULL, order_status TEXT NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW());
INSERT INTO public.student_orders (order_id, customer_name, product, order_amount, order_status) VALUES
  (1, 'Mona', 'Keyboard', 45.00, 'completed'),
  (2, 'Omar', 'Monitor', 180.00, 'completed'),
  (3, 'Salma', 'Mouse', 22.50, 'pending')
ON CONFLICT (order_id) DO NOTHING;
