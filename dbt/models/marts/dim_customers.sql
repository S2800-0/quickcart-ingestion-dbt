select
    c.customer_id,
    c.customer_name,
    c.email,
    c.city,
    c.state,
    c.registration_date,
    c.loyalty_tier,
    count(distinct o.order_id) filter (where o.order_status <> 'cancelled') as orders_placed,
    coalesce(sum(o.order_revenue) filter (where o.order_status <> 'cancelled'), 0) as lifetime_revenue
from {{ ref('stg_customers') }} c
left join {{ ref('fct_orders') }} o using (customer_id)
group by 1, 2, 3, 4, 5, 6, 7
