-- One row per order line, with product margin.
select
    i.order_item_id,
    i.order_id,
    o.order_date,
    o.order_status,
    i.product_id,
    p.product_name,
    p.category,
    i.quantity,
    i.price_per_unit,
    i.line_revenue,
    cast(i.quantity * p.cost_price as numeric(12, 2)) as line_cost,
    cast(i.line_revenue - i.quantity * p.cost_price as numeric(12, 2)) as line_margin
from {{ ref('stg_order_items') }} i
join {{ ref('stg_orders') }} o using (order_id)
join {{ ref('stg_products') }} p using (product_id)
