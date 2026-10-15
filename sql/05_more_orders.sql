-- Three more orders arrive in Neon (used to prove the Airbyte Cloud incremental sync)
INSERT INTO public.orders (order_id, order_date, customer_id, employee_id, store_id, status, shipping_fee) VALUES
  (106, '2026-01-08', 15, 30, 5, 'Delivered', 0),
  (107, '2026-01-08', 52, 18, 22, 'Shipped', 5.99),
  (108, '2026-01-09', 7, 44, 17, 'Pending', 5.99);
INSERT INTO public.order_items (order_item_id, order_id, product_id, quantity, price_per_unit) VALUES
  (108, 106, 5, 2, 75.00),
  (109, 106, 12, 1, 310.50),
  (110, 107, 40, 3, 22.25),
  (111, 108, 9, 1, 99.99);
