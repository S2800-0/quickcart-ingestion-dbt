-- Report table: what sells and what it earns, cancelled orders excluded.
select
    category,
    product_id,
    product_name,
    sum(quantity) as units_sold,
    sum(line_revenue) as revenue,
    sum(line_margin) as margin,
    round(100.0 * sum(line_margin) / nullif(sum(line_revenue), 0), 1) as margin_pct
from {{ ref('fct_order_items') }}
where order_status <> 'cancelled'
group by 1, 2, 3
