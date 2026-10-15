-- Revenue in the order table must equal revenue in the order lines.
-- The test fails if any rows come back.
select 1
from (
    select
        (select sum(items_revenue) from {{ ref('fct_orders') }}) as orders_total,
        (select sum(line_revenue) from {{ ref('stg_order_items') }}) as lines_total
) t
where orders_total <> lines_total
