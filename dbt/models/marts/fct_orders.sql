-- One row per order, with what it was worth.
with items as (
    select
        order_id,
        sum(quantity) as units,
        count(*) as line_count,
        sum(line_revenue) as items_revenue
    from {{ ref('stg_order_items') }}
    group by 1
)

select
    o.order_id,
    o.order_date,
    date_trunc('month', o.order_date)::date as order_month,
    o.customer_id,
    o.employee_id,
    o.store_id,
    o.order_status,
    coalesce(i.line_count, 0) as line_count,
    coalesce(i.units, 0) as units,
    coalesce(i.items_revenue, 0) as items_revenue,
    o.shipping_fee,
    coalesce(i.items_revenue, 0) + o.shipping_fee as order_revenue
from {{ ref('stg_orders') }} o
left join items i using (order_id)
