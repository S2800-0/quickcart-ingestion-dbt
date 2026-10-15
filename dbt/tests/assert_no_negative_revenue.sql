-- No order may have negative revenue. The test fails if any rows come back.
select order_id from {{ ref('fct_orders') }} where order_revenue < 0
