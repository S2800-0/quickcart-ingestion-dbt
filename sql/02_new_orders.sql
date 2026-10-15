-- New day, new orders in the production database (used to prove incremental sync)
INSERT INTO public.orders (order_id, order_date, customer_id, employee_id, store_id, status, shipping_fee) VALUES
  (101, '2026-01-05', 12, 30, 5, 'Delivered', 0),
  (102, '2026-01-05', 47, 18, 22, 'Shipped', 5.99),
  (103, '2026-01-06', 3, 44, 17, 'Pending', 5.99),
  (104, '2026-01-06', 88, 25, 42, 'Cancelled', 0),
  (105, '2026-01-07', 61, 72, 9, 'Delivered', 0);
INSERT INTO public.order_items (order_item_id, order_id, product_id, quantity, price_per_unit) VALUES
  (101, 101, 2, 1, 540.89),
  (102, 101, 14, 3, 25.50),
  (103, 102, 33, 2, 89.99),
  (104, 103, 7, 1, 150.00),
  (105, 104, 21, 4, 60.00),
  (106, 105, 2, 2, 540.89),
  (107, 105, 50, 1, 19.99);
